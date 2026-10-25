---
name: powerbi-debugging
description: "Systematic Power BI debugging framework isolating bugs across four domains: (1) data pipeline/ETL, (2) relationships & evaluation context, (3) DAX logic, (4) performance. Use when numbers mismatch the source, reports break, refreshes fail, visuals show errors like #Error or blanks, or dashboards slow down after changes."
metadata:
  version: "1.0.0"
---

# Report Debugging & Maintenance Framework

Never fix by guessing. Isolate the domain first, then apply the domain's procedure. Ask: *"Is the data wrong, the model wrong, the calculation wrong, or is it just slow?"*

## Domain 1 — Data Pipeline & ETL debugging

**Symptoms:** refresh failures, `#Error` in visuals, truncated text, wrong row counts, nulls appearing after a change.

- **Step-by-step query audit:** open Power Query Editor → Applied Steps; click each step from Source down; find the first step where row count, column set, or sample values diverge from expectation.
- **Type mismatches:** the #1 cause of dropped/mangled rows — `type text` loaded into an `int64` model column fails refresh; check all `Changed Type` steps for locale issues (`"1.234" → 1234` under wrong locale).
- **M code inspection (Advanced Editor):** rewrite hardcoded structural paths (`Source{[Item="Sheet1"]}`) and file names into filtered lookups or parameters; see `powerbi-power-query` schema-drift rules.
- **Error trapping:** `try ... otherwise null` + a parallel error-audit query (`Table.SelectRowsWithErrors`) so errors are visible, not silently swallowed.
- **Gateway diagnostics:** refresh history error codes; token expirations (re-auth data source); network timeouts on non-folded queries (pulling full tables through the gateway); privacy-level mismatches combining sources.

## Domain 2 — Relationships & evaluation context debugging

**Symptoms:** totals inflate/deflate after model edits, slicers ignore filters, blanks for some slices, RLS behaving differently per user.

- **Cardinality trapping:** many-to-many or bidirectional cross-filter configs inflate outputs (fan-out: one dim row matching multiple fact rows multiplied). Fix: bridge tables, `CROSSFILTER` in measures, or `DISTINCTCOUNT` of the correct grain.
- **Relationship sanity:** both columns same data type; no blank-key mismatches (blank dim keys silently group unmatched facts under blank member); active path exists for every measure's filter flow.
- **Evaluation-context audit:** check hidden page filters, report-level filters, interacting slicers (Format → Edit interactions), visual-level filters, and explicit `CALCULATE` overrides inside measures. Build a filter-flow diagram: slicer → visual filter → measure CALCULATE → relationship direction.
- **RLS simulation:** Modeling → **View As** → test every role and "Other person" (`user@domain`) — verify row visibility matches the mapping table; check for `ALL()`/`REMOVEFILTERS()` patterns that bypass security filters.

## Domain 3 — DAX logic debugging

**Symptoms:** measure returns wrong number but consistent; total ≠ sum of visible rows; time intelligence off by one period.

- **Variable isolation:** rewrite the measure into `VAR` blocks; `RETURN` one variable at a time (start with the innermost), comparing each against expected value.
- **Virtual table materialization:** inspect what a filter argument actually produces — `EVALUATE` in DAX Studio, or a temporary debug measure using `CONCATENATEX( <table-var>, [col] )` bound to a card visual.
- **Total-row semantics:** if rows are right but total is wrong, the measure is non-additive; either re-aggregate at grain (`SUMX(VALUES(...), [measure])`) or guard display logic with `HASONEVALUE`.
- **Time intelligence:** confirm date table is marked and contiguous; confirm `DATEADD`/`SAMEPERIODLASTYEAR` get the *column* not the table; check incomplete periods (e.g., compare MoM when last month is partial — use a "period complete to same date" pattern).

## Domain 4 — Performance debugging

**Symptoms:** visuals take seconds, report feels slower after changes, refresh window exceeded.

- **Performance Analyzer** → export per-visual timings → take the slowest DAX query into **DAX Studio** → read FE/SE split and SE query count.
- **External profiling:** Tabular Editor for schema-level issues (unused columns, cardinality, partition design) and DAX tracking; see `powerbi-performance` for the full tuning method.
- Only optimize after reproduction: record baseline numbers before/after each change.

## Escalation discipline

Fix in this order of preference: **source/warehouse** (best) → **Power Query** → **model (TMDL/relationships)** → **DAX workaround** → (never) report-level filter hacks. Document the root cause, not just the fix, in the project's changelog.
