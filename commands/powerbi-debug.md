---
description: Debug a broken, mismatched, or slow Power BI report using the 4-domain isolation framework.
---

# Power BI Debug Workflow

## Usage

`/powerbi-debug <symptom description> [path to PBIP/PBIX]`

## Steps

1. Load skill `powerbi-debugging`. Classify the symptom into one of four domains:
   - **Domain 1 — Data pipeline/ETL:** refresh failures, #Error, truncated text, wrong row counts.
   - **Domain 2 — Relationships/context:** totals inflate, slicers ignored, RLS differences.
   - **Domain 3 — DAX logic:** consistent-but-wrong numbers, total ≠ sum of rows, time shifts.
   - **Domain 4 — Performance:** slow visuals/refresh.
2. Gather evidence before touching anything: refresh history errors, Performance Analyzer export, applied-steps divergence point, model relationships.
3. Apply the domain's procedure (variable isolation, cardinality trap check, View As simulation, DAX Studio timings).
4. Fix at the earliest responsible layer: source/warehouse → Power Query → model → DAX.
5. Re-run the failing scenario + `powerbi-certification` checklist items affected by the change.
6. Document root cause and fix in the project changelog.
