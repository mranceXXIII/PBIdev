---
name: powerbi-pbip-deploy
description: "Save Power BI work directly as a Power BI Desktop project (PBIP) folder from the AI agent, with no Power BI Service account or sign-in required: scaffold the full PBIP structure (pbip, definition.pbir, definition.pbism, TMDL semantic model, report.json, .platform, .gitignore) via the plugin's scaffold-pbip.ps1, write TMDL tables/measures/RLS by hand, keep it Git-versioned, and hand off ready-to-open/ready-to-publish. Use when the user wants reports 'saved to Power BI', PBIP/PBIX output, Git integration, or deployment-ready deliverables."
metadata:
  version: "1.0.0"
---

# Deploy as PBIP — no account required

Power BI Desktop projects (**PBIP**) save the report and semantic model as plain text (TMDL/JSON) in a documented folder structure. That makes the deliverable: openable in Power BI Desktop **without any sign-in**, Git-versionable, diffable, and hand-off ready. Publishing to the Service is an *optional later step* — nothing here requires a tenant or account.

## When to use

- "Save this workflow/report to Power BI" / "make it deployable"
- "I don't want to connect an account" — PBIP is authored as text; Desktop opens it locally
- Team/Git workflows, code review of models, CI/CD

## 1. Scaffold a new project (scripted)

```powershell
powershell -ExecutionPolicy Bypass -File "<plugin>\assets\scaffold-pbip.ps1" `
    -Name "Sales Analytics" -Out "C:\repos" [-WithSampleTable]
```

Produces:

```
SalesAnalytics/
├── SalesAnalytics.pbip                  ← double-click to open in Desktop
├── .gitignore
├── SalesAnalytics.SemanticModel/
│   ├── .platform                        ← Fabric item metadata (type: SemanticModel)
│   ├── definition.pbism
│   └── definition/
│       ├── database.tmdl                ← compatibilityLevel: 1567
│       ├── model.tmdl                   ← culture, defaultPowerBIDataSourceVersion
│       ├── expressions.tmdl             ← shared M expressions / parameters
│       ├── relationships.tmdl
│       └── tables/                      ← one .tmdl per table
└── SalesAnalytics.Report/
    ├── .platform                        ← (type: Report)
    ├── definition.pbir                  ← datasetReference byPath → sibling SemanticModel
    └── definition/
        └── report.json
```

## 2. Author the model in TMDL (text-first)

Follow the exact TMDL rules in `../powerbi-modeling/SKILL.md` (tabs for indentation, UTF-8 **without BOM**, `lineageTag` GUIDs on every object, `sourceColumn` matching partition output). Per table one file under `definition/tables/`. Measures with explicit `formatString`. RLS roles as `role` blocks with `tablePermission`.

Add a data source partition (SQL example) or use an empty/inline M partition while prototyping. Desktop detects external edits and prompts **Apply changes** with one click.

## 3. Validate locally (no account)

1. Open the `.pbip` (or the Report's `definition.pbir`) in **Power BI Desktop** — Developer mode / PBIP preview enabled.
2. Desktop regenerates any missing optional files and prompts to apply external edits.
3. Model → refresh/preview; Model view → verify relationships; View As → test RLS.
4. Save (Ctrl+S) — changes land back in the same text files; commit to Git.

## 4. Optional deployment paths (only when ready)

| Path | Requirement | Notes |
|---|---|---|
| Manual publish from Desktop | User sign-in at publish time | File → Publish → workspace |
| Git sync to Fabric workspace | Fabric Git integration | Connect workspace to the same repo; PBIP is the native format |
| Tabular Editor / TOM deploy | XMLA endpoint + credentials | Semantic model only; scripts via C#/TMSL |
| Deployment pipelines (Dev→Test→Prod) | Premium/Fabric capacity | Post-publish promotion |

## Rules

- Never emit PBIX from text — PBIX is a zip binary; PBIP is the text-native format. Conversions both ways are Desktop-only (File → Save As).
- Encode files UTF-8 without BOM; CRLF is Desktop's default — configure Git `autocrlf` accordingly.
- Keep paths short (< 260 chars total); don't scaffold into OneDrive/SharePoint-synced folders.
- `.pbip` is just a shortcut; the openable unit is the Report's `definition.pbir`.
- Commit `.gitignore` that excludes `.pbi/localSettings.json`, `.pbi/cache.abf`, `*.abf`.
- Secrets (connection strings) do not belong in TMDL — use parameterized expressions and document expected values outside the repo.
