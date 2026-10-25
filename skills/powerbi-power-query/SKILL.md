---
name: powerbi-power-query
description: "Power Query / M language for Power BI ETL: staged queries, query folding, explicit data types, parameters, error handling (try/otherwise), Advanced Editor patterns, custom functions, schema-drift resilience, and mashup engine mechanics for refresh reliability. Use when loading/transforming data, fixing refresh errors, writing M code, or reviewing Power Query steps."
metadata:
  version: "1.0.0"
---

# Power Query & M (ETL)

## Architecture: stage everything

```
Staging (Source + minimal reshape, connection-only)
  → Transform (business rules, typed, one concern per step)
    → Reference for each dimension/fact output
```

- Staging queries are **connection-only** (uncheck Enable load); outputs reference them.
- One concern per query; group applied steps logically; rename steps meaningfully (M step names are code).
- Parameters for every environment-specific value: server, database, file paths, relative dates. Never hardcode.

## Query folding

- Folding = M steps translated to the source (SQL) engine. Preserve it: filter and remove columns **as early as possible**; do native transforms before adding computed columns that break folding.
- Verify: right-click last step → **View Native Query** (greyed out = folded). Unfoldable landmarks: `Table.Buffer`, custom functions, index columns, most merges across different sources, `Table.Distinct` on some connectors.
- If a late step breaks folding, restructure so the heavy reduction happens before the breaking step.

## Data types & errors

- Set types **explicitly at the source step** (`Table.TransformColumnTypes`) — never rely on inference; explicit type ascription (`type nullable number`) avoids extra transformation steps.
- `any` type = a bug in a delivered model.
- Guard risky conversions:
```m
Value.Is( [Amount], type number )  // or
try Number.From( [RawAmount] ) otherwise null
```
- Replace `#Error` values deliberately (`Table.ReplaceErrorValues`) or route to an error-audit query; a delivered model must not refresh with unhandled errors.

## Schema-drift resilience (production models)

- Remove columns by **selection** (`Table.SelectColumns` with `MissingField.UseNull`) instead of `Table.RemoveColumns` so new/removed source columns don't brick refresh.
- For structural path changes (file names, sheet indexes), rewrite hardcoded `{[Name="Sheet1"]}` navigations into filtered queries by name/kind.
- Validate row counts against source after structural changes.

## M essentials

```m
let
    Source = Sql.Database(paramServer, paramDatabase),
    dbo_Sales = Source{[Schema = "dbo", Item = "FactSales"]}[Data],
    SelectedCols = Table.SelectColumns(
        dbo_Sales,
        {"order_id", "order_line", "order_date", "customer_key", "amount"},
        MissingField.UseNull
    ),
    Typed = Table.TransformColumnTypes(SelectedCols, {
        {"order_id", Int64.Type},
        {"order_line", Int64.Type},
        {"order_date", type date},
        {"customer_key", Int64.Type},
        {"amount", type nullable number}
    }),
    Filtered = Table.SelectRows(Typed, each [order_date] >= RangeStart and [order_date] < RangeEnd),
    Renamed = Table.RenameColumns(Filtered, {{"amount", "sales_amount", MissingField.Ignore}})
in
    Renamed
```

- `Table.Buffer` only with a measured reason (e.g., protecting a small lookup from being re-evaluated); it disables folding — document it.
- Prefer `Table.NestedJoin` + expand vs `Table.Join` semantics awareness; join keys must be same type.
- Custom functions: define with typed parameters, keep pure (no environment access), unit-test on edge rows (nulls, empty strings).

## Incremental refresh plumbing

- Create `RangeStart`/`RangeEnd` datetime parameters (exact names, hidden).
- Filter on a foldable datetime column with `>= RangeStart and < RangeEnd`.
- RangeStart inclusive / RangeEnd exclusive; policy window partitions must align to day boundaries (floor RangeEnd to day).

## Gateway / refresh diagnostics

- Refresh failures: check dataset refresh history first (error code), then whether the failing query folds (non-folded source pulls full table through the gateway).
- Credential/privacy: unify privacy levels per data source; `Privacy.None` silencing is a smell — fix isolation instead.
- Timeouts on large non-folded queries → push the reduction to a view in the source when folding can't be preserved.
