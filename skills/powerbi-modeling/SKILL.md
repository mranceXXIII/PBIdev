---
name: powerbi-modeling
description: "Design Power BI semantic models: star schemas, snowflake vs star, relationship cardinality and cross-filter direction, date dimensions, TMDL authoring, incremental refresh, aggregations, and migration from flat/one-big-table models. Use when creating tables/relationships, fixing many-to-many traps, converting PBIX to PBIP model folders, or reviewing model hygiene."
metadata:
  version: "1.0.0"
---

# Data Modeling (Dimensional / Star Schema)

## Core principles

1. **One fact table per business process.** Sales orders, invoices, inventory snapshots are separate facts joined through conformed dimensions.
2. **Star schema by default.** Dimensions denormalized (one table per entity); only snowflake when source enforces it and then flatten in Power Query.
3. **Single-direction relationships** (one side filters many side). Bidirectional only with documented justification (e.g., shared dimension across two facts with `CROSSFILTER` in specific measures is usually better).
4. **Cardinality:** `1:*` for dim→fact; `*:*` only for bridge scenarios (e.g., bank account ↔ customer) via a bridge table; `1:1` signals modeling debt.
5. **No relationships on floating-point or computed columns.** Relationship columns must share identical data type.
6. **Active vs inactive:** multiple paths to a dimension → keep one active, activate others with `USERELATIONSHIP` inside `CALCULATE`. Never activate an RLS filter path with `USERELATIONSHIP` on the same table (BPA error-prevention rule).

## Required artifacts

- **Date dimension:** contiguous dates spanning min→max fact dates (or calendar boundaries), columns: Date, Year, Quarter, Month, MonthName, MonthIndex (for sorting), DayOfWeek, IsCurrent flags. Mark as date table. Never rely on Power BI auto date/time hierarchies in delivered models (disable `Auto date/time`).
- **`_Measures` table:** dedicated empty table holding all measures (Tabular Editor: new table with a dummy column, hidden; measures live here).
- **Hide keys:** all surrogate/business keys and fact FK columns hidden; descriptions on every visible object.

## Grain discipline

State the grain of each fact table out loud before modeling: "one row per order line per day." Aggregation of facts happens in measures, never by pre-summing unless there is a documented performance reason.

## TMDL authoring (PBIP SemanticModel/definition)

Model skeleton:

```tmdl
// model.tmdl
model Model
	culture: en-US

	defaultPowerBIDataSourceVersion: powerBI_V3
	sourceQueryCulture: en-US
```

```tmdl
// database.tmdl
database
	compatibilityLevel: 1567
```

```tmdl
// tables/dim_customer.tmdl
table dim_customer
	lineageTag: <guid>

	measure 'Customers (Distinct)' =
		DISTINCTCOUNT( dim_customer[customer_key] )
			formatString: #,0
			lineageTag: <guid>

	column customer_key
		dataType: int64
		isHidden
		summarizeBy: none
		sourceColumn: customer_key
		lineageTag: <guid>

	partition dim_customer = m
		mode: import
		source =
				let
					Source = Sql.Database("server", "db"),
					Data = Source{[Schema="dbo",Item="dim_customer"]}[Data]
				in
					Data
```

Rules: TMDL indents with **tabs**; files saved **UTF-8 without BOM**; every object needs a `lineageTag` (stable GUID); `sourceColumn` must match the partition output column name.

## Incremental refresh

- `RangeStart`/`RangeEnd` datetime parameters (must be named exactly that), filter the fact query on a datetime column using them (query-foldable filter required).
- Configure policy: e.g., archive 3 years, refresh last 7 days, detect deletions only if source supports it.

## Aggregations

For big Import models over big sources: build agg table at higher grain (e.g., month × product × region), set agg table to Import, fact to DirectQuery, define aggregation mappings on the agg table, let engine route queries automatically.

## Migration review checklist (flat model → star)

1. Identify grain → split into fact + dimensions in Power Query.
2. Remove repeated descriptive attributes from facts.
3. Create/adopt date dimension; connect all date-like columns.
4. Rebuild measures against dimensions (filters flow dim→fact).
5. Verify no orphan rows: check row counts before/after (referential integrity violations get silently dropped).

## Anti-patterns to reject

- One big flat table "for simplicity."
- Bidirectional relationships to "make slicers work" (fix with `CROSSFILTER` in the specific measure or a bridge).
- Calculated columns that copy Power Query work.
- Floating `SELECT *`-style partitions without column projection on wide tables.
- Relationships built on text keys that could be int (sort/perf cost).
