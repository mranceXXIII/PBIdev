# DAX Style Rules (powerbi-dev)

Apply when writing or reviewing any DAX expression.

- Always `DIVIDE(a, b)` — never bare `/` for potentially zero denominators.
- Filter **columns**, not tables, in `CALCULATE` filter arguments.
- Fully qualify column references (`'Table'[Column]`); reference measures bare (`[Measure]`).
- Multi-step logic → `VAR ... RETURN`; return variables one at a time when debugging.
- Every measure: explicit `formatString` + description.
- Prefer measures over calculated columns; prefer Power Query over calculated columns for row-level logic.
- No `EVALUATEANDLOG` in production; no two measures with identical definitions.
- Non-additive measures (ratios, ranks, distinct counts) must be safe at the grand total (SUMX over grain or HASONEVALUE guard).
- Time intelligence only against a marked, contiguous date dimension.
- Avoid `FILTER(<table>, ...)` as a filter argument when a column filter or `KEEPFILTERS` works; avoid `ALL()` where `ALLSELECTED()` or `REMOVEFILTERS()` is meant.
- Never use `USERELATIONSHIP` to activate a path into an RLS-filtered table.
