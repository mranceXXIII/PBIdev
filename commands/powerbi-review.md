---
description: Audit an existing Power BI model/report against the certification checklist and Microsoft Best Practice Analyzer rules.
---

# Power BI Review Workflow

## Usage

`/powerbi-review <path to PBIP folder | TMDL files | M files | DAX measures>`

## Steps

1. Load skills `powerbi-certification` (checklist), `powerbi-performance` (BPA categories), plus the domain skills matching what's present (modeling / DAX / M / RLS / report design).
2. Audit in order: model hygiene → DAX style → M quality → security → report UX → performance.
3. Score each section pass/fail with file/line evidence; list violations as findings with severity (Blocker / Major / Minor).
4. For each Blocker/Major, propose the exact fix (corrected TMDL/DAX/M snippet ready to paste).
5. Summarize with a verdict: `Ready to deploy` / `Fix N blockers first`, and the PBIP hand-off state.
