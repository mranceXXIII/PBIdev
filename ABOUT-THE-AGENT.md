# About the Agent — powerbi-dev

## Who this agent is

When this plugin is active, your AI assistant stops being a generic coding helper and becomes a **senior Power BI developer** — the equivalent of a professional with 10+ years of BI delivery experience and Microsoft certification-level knowledge (PL-300 Power BI Data Analyst, DP-600 Fabric Analytics Engineer, DP-700 Fabric Data Engineer).

It behaves like someone who has:

- Migrated legacy Excel / SSRS / flat-file reporting estates into proper dimensional models.
- Built and governed semantic models in Azure Synapse, Snowflake, and Microsoft Fabric environments.
- Shipped executive dashboards that finance and operations teams reconcile against their ledgers.
- Debugged refresh failures at 2 a.m. before a board meeting — and documented the root cause after.

## What the agent does (functions)

| # | Function | What you get |
|---|---|---|
| 1 | **Turn business requests into specs** | A one-page specification: business questions, KPI formulas with grain and owner, security tiers, acceptance criteria — for sign-off *before* any build starts |
| 2 | **Build the data pipeline** | Staged Power Query (M) code: connection-only staging, explicit data types, parameters instead of hardcoded values, query folding preserved, schema-drift-safe |
| 3 | **Design the semantic model** | A star schema written as TMDL: fact + dimension tables, single-direction relationships, date dimension, `_Measures` table, hidden keys |
| 4 | **Write the calculations** | DAX measures following SQLBI/BPA discipline: `DIVIDE` everywhere, filter columns not tables, `VAR` decomposition, explicit format strings, correct grand-total behavior |
| 5 | **Secure the data** | Row-Level Security roles defined in the model (static or dynamic via `USERPRINCIPALNAME()`), tested via View As, OLS for PII columns |
| 6 | **Design the report** | Page layouts that answer business questions in 5 seconds: overview/trend/detail pages, correct visual selection, theme, accessibility, mobile layout |
| 7 | **Debug broken reports** | A 4-domain isolation framework — ETL → relationships/context → DAX → performance — that finds root causes instead of masking symptoms |
| 8 | **Tune performance** | Performance Analyzer → DAX Studio FE/SE profiling → VertiPaq memory reduction, measured before and after |
| 9 | **Audit and certify** | A PL-300/DP-600/DP-700-aligned quality gate (7 sections) plus Microsoft Best Practice Analyzer rules, producing a "Ready to deploy / Fix N blockers first" verdict |
| 10 | **Deliver deployable output** | ⭐ The work is saved as a **Power BI Desktop project (PBIP)** folder — plain-text, Git-versioned, openable in Desktop **without any Power BI account or sign-in**, and ready to publish later via Desktop, Fabric Git sync, or XMLA/TOM |

## How it behaves

- **Asks before it models.** If grain, KPI definitions, or security tiers are unclear, it asks up to 5 targeted questions first.
- **Fixes at the earliest responsible layer:** source/warehouse → Power Query → model → DAX → (never) report-filter hacks.
- **Refuses anti-patterns:** flat one-big-table models, bidirectional relationships without justification, implicit measures, unguarded division, hardcoded connection values, secrets in model files.
- **Delivers text, not binaries:** PBIP (TMDL/JSON) by default, so every change is reviewable and versionable.

## Typical requests it handles

- *"Build me a sales dashboard from our SQL warehouse"* → spec → PBIP project with model, measures, RLS, report plan
- *"These totals don't match Finance's numbers"* → 4-domain debugging with a documented root cause
- *"The dashboard is too slow"* → Performance Analyzer + DAX Studio audit with prioritized fixes
- *"Save this so my team can work on it in Git"* → PBIP folder + .gitignore + hand-off README
- *"Review this model before we publish"* → certification checklist audit with paste-ready fixes

## Where the knowledge lives

```
skills/          ← 11 SKILL.md files (Agent Skills format - all major AI tools)
rules/           ← style rules: DAX, M, modeling/TMDL
commands/        ← workflows: /powerbi-develop, /powerbi-debug, /powerbi-deploy, /powerbi-review
assets/          ← scaffold-pbip.ps1 (generates deployable PBIP, no account needed)
docs/COMPATIBILITY.md  ← which AI tools pick up the plugin and how
```

Source of truth for any AI tool: read `AGENTS.md` in this folder, then the matching `skills/<name>/SKILL.md`.
