---
name: powerbi-performance
description: "Power BI performance tuning: Performance Analyzer workflow, DAX Studio server timings (FE/SE), VertiPaq memory optimization, column cardinality reduction, DirectQuery vs Import decisions, aggregations, and Tabular Editor Best Practice Analyzer review. Use when reports are slow, refresh times are high, memory is excessive, or a pre-delivery performance audit is requested."
metadata:
  version: "1.0.0"
---

# Performance Tuning

## Method: measure → locate → fix → re-measure. Never tune blind.

### 1. Performance Analyzer (Desktop)

- View → Performance Analyzer → Start Recording → Refresh Visuals.
- Read per visual: **DAX Query**, **Visual Display**, **Other**. Copy the slowest visual's DAX query into DAX Studio for server timings.
- Fix order: worst DAX query time first, then visual rendering (too many visuals/labels), then `Other` (excess on-page objects, bookmarks).

### 2. DAX Studio server timings

- Focus on **Storage Engine (SE) vs Formula Engine (FE)** time: SE parallel and cacheable; FE single-threaded.
- Red flags: FE % > ~50% (iterator/context-transition heavy), high **SE Queries** count (callbackdataid / `FILTER` over tables), repeated identical scans (missing `VAR` reuse), `xm_sql` with `TOPN` loops.
- Clear cache (both) for cold timings; run twice for warm readings.

### 3. VertiPaq (Import memory)

- Tabular Editor / DAX Studio → VertiPaq Analyzer metrics: table size, column size, cardinality.
- Remove unused columns (BPA "Remove unused columns" maintenance rule) — every column is compressed RAM.
- Reduce cardinality: split datetime → separate date (int) + time or decimal seconds; hash/encode low-value long text; avoid float keys.
- Prefer `int64` keys over text keys in relationships; disable "Auto date/time" (saves a hidden date table per date column).
- Calculated columns are memory — replace with Power Query or measures.

### 4. Import vs DirectQuery decision

| Factor | Import | DirectQuery |
|---|---|---|
| Model size / RAM | Any | Source-bound |
| Time intelligence | Full | Limited (no auto time-intel patterns) |
| M transformations | Rich | Must fold to source |
| Latency | Refresh cadence | Near-real-time |
| RLS + USERELATIONSHIP | OK | Costly per query |

Composite models: Import dimension + DirectQuery facts + user-defined aggregations is the standard large-model architecture.

### 5. Refresh performance

- Fold heavy reductions (see `powerbi-power-query` skill); non-folded pulls push full tables through the gateway.
- Parallel loading: check table-level parallelism; staging queries that fan out references may serialize.
- Incremental refresh for large facts (rangeStart/RangeEnd) — see modeling skill.

## Best Practice Analyzer (Tabular Editor 2/3)

Run Microsoft's BPA rules (`https://github.com/microsoft/Analysis-Services/blob/master/BestPracticeRules/BPARules.json`) before any delivery. Categories and top rules:

- **DAX Expressions:** use `DIVIDE`; filter by columns not tables; fully qualified column refs; avoid `USERELATIONSHIP`+RLS same table; no two measures with same definition; no `EVALUATEANDLOG` in production; inactive relationships that are never activated.
- **Error Prevention:** expression-reliant objects must have expression; relationship columns same data type; data columns must have source column.
- **Formatting:** every measure has format string; date columns format string; percentages as percentage; provide `Data Category` for address/URL/latitude columns.
- **Naming:** visible objects never start with `_` unless internal; partition name = table name for single-partition tables; no reserved words as names.
- **Performance:** minimize Power Query transformations; reduce calculated columns using `RELATED`; limit RLS logic; avoid dynamic formats where static works; check if dynamic RLS is necessary; remove auto-generated date tables.
- **Maintenance:** remove unused columns/measures/roles; objects with no description (visible); fix referential integrity violations.

## Delivery targets (rule of thumb)

- Interactive visuals: DAX query < 1s; dashboard page < 3s fully rendered.
- Import model: < 1GB unless documented; refresh windows met with margin.
- No visual with > 2 DAX queries when one composite measure suffices.
