---
name: powerbi-certification
description: "Quality gate and certification checklist for Power BI deliverables, aligned to Microsoft PL-300 / DP-600 / DP-700 exam objectives and Best Practice Analyzer rules. Use before declaring any report/model done, for pre-delivery audits, or when the user wants 'enterprise-grade standard' output."
metadata:
  version: "1.0.0"
---

# Certification & Quality Gate (PL-300 / DP-600 / DP-700 aligned)

Run **every** section before declaring a deliverable complete. A deliverable that fails any item is not done.

## A. Model quality (DP-600-aligned)

- [ ] Star schema: facts per business process, conformed dimensions, no 1:1 junk relationships
- [ ] All relationships single-direction (exceptions documented), same-type keys, no orphan facts (row counts reconciled)
- [ ] Auto date/time disabled; real date dimension marked; contiguous dates
- [ ] No calculated columns duplicating Power Query work; no calculated fact tables
- [ ] Incremental refresh policy where fact > ~10M rows
- [ ] Unused columns removed; keys hidden; descriptions on all visible objects
- [ ] All measures in `_Measures` table; no implicit measures used anywhere

## B. DAX quality (PL-300-aligned)

- [ ] `DIVIDE` everywhere; no unguarded `/`
- [ ] Filter arguments are columns, not tables
- [ ] Multi-step logic uses `VAR ... RETURN`
- [ ] Explicit `formatString` on 100% of measures
- [ ] Time intelligence against the marked date dimension; incomplete-period handling documented
- [ ] Non-additive measures safe at grand total
- [ ] No `EVALUATEANDLOG`, no dead measures, no duplicate definitions

## C. ETL quality (M)

- [ ] Staged queries; connection-only staging; outputs reference
- [ ] Explicit types at source; no `any`
- [ ] Parameters for server/db/paths; zero hardcoded environment values
- [ ] Schema-drift-safe column selection; error trapping with visible audit path
- [ ] Query folding preserved where it matters (View Native Query checked)

## D. Security (PL-300-aligned)

- [ ] RLS roles defined in the model; tested via View As for every role + simulated UPN
- [ ] Dynamic RLS mapping table hidden and normalized
- [ ] No `USERELATIONSHIP` + RLS conflict on the same table
- [ ] OLS on PII columns; sensitivity label plan documented
- [ ] No secrets in TMDL/M files

## E. Report & UX

- [ ] Theme applied; consistent color semantics
- [ ] Titles answer business questions; 5-second overview page
- [ ] Alt text, tab order, contrast ≥ 4.5:1
- [ ] Drillthrough + back button; mobile layout for primary page
- [ ] Every visual driven by explicit measures

## F. Performance

- [ ] Performance Analyzer run on all pages; no visual > 2s DAX
- [ ] VertiPaq scan: no unused columns, no high-cardinality text keys
- [ ] Refresh tested end-to-end (including gateway path if applicable) with timing recorded

## G. Delivery (PBIP)

- [ ] Deliverable is a PBIP folder, opens in Desktop without sign-in
- [ ] Committed to Git with `.gitignore` (localSettings/cache excluded)
- [ ] README in repo: sources, refresh cadence, RLS roles, KPI owners
- [ ] Acceptance criteria from the spec verified against the reference system

## Certification knowledge map (study/reference anchor)

- **PL-300** (Power BI Data Analyst): model, visualize, transform, deploy, secure — this checklist mirrors its skills-measured sections.
- **DP-600** (Fabric Analytics Engineer): semantic model optimization, version control (PBIP/Git), deployment pipelines.
- **DP-700** (Fabric Data Engineer): ingestion, orchestration, governance around the model.
- **Best Practice Analyzer** (Microsoft): the rule catalog encoded in this plugin's rules.
