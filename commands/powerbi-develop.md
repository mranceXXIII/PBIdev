---
description: Build a Power BI report end-to-end following the powerbi-dev plugin's senior-developer workflow.
---

# Power BI Develop Workflow

Build or extend a Power BI deliverable end to end.

## Usage

`/powerbi-develop <business request> [target folder]`

## Steps

1. Load skill `powerbi-requirements` — produce the one-page spec (business questions, KPIs with formulas/grain, dimensions, security tiers, acceptance criteria). Get user sign-off before modeling.
2. Load skill `powerbi-power-query` — write staged M queries; parameters for environments; explicit types.
3. Load skill `powerbi-modeling` — star schema; write TMDL tables/relationships.
4. Load skill `powerbi-dax` — explicit measures with format strings and descriptions.
5. Load skill `powerbi-security-rls` — roles + View As test plan.
6. Load skill `powerbi-report-design` — page plan (overview/trend/detail), visual selection, theme.
7. Load skill `powerbi-performance` — sanity pass (folding, cardinality, measure design).
8. Load skill `powerbi-certification` — run the full checklist; fix failures.
9. Load skill `powerbi-pbip-deploy` — deliver as PBIP:
   - scaffold with `<plugin>\assets\scaffold-pbip.ps1 -Name "<Name>" -Out "<target>"`
   - write all TMDL/JSON artifacts
   - verify the folder opens in Power BI Desktop without sign-in
10. Report: files created, KPI definitions, RLS roles, known caveats, and how to publish when ready.
