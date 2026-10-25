# Power BI Developer Plugin (powerbi-dev)

A portable, cross-AI plugin that turns any AI coding agent (Claude, Codex, Cursor, Antigravity, Gemini CLI, Windsurf, Copilot, Cline, and anything that reads the Agent Skills or AGENTS.md formats) into a **senior Power BI developer** with certification-aligned standards (PL-300, DP-600, DP-700), Microsoft Best Practice Analyzer rules, and SQLBI-grade DAX discipline.

> **📄 What this agent does:** read [`ABOUT-THE-AGENT.md`](ABOUT-THE-AGENT.md) — persona, the 10 functions it performs, and typical requests it handles.
> **🔌 Which AI tools it works with:** read [`docs/COMPATIBILITY.md`](docs/COMPATIBILITY.md) — full adapter matrix and install commands.

## What's inside

| Skill | Purpose |
|---|---|
| `powerbi-developer` | Orchestrator persona + end-to-end delivery workflow |
| `powerbi-modeling` | Star schema, TMDL, cardinality, incremental refresh, aggregations |
| `powerbi-dax` | DAX patterns, evaluation context, CALCULATE discipline, calculation groups |
| `powerbi-power-query` | M language, ETL staging, mashup engine, error handling |
| `powerbi-security-rls` | Static/dynamic RLS, OLS, governance, sensitivity labels |
| `powerbi-performance` | Performance Analyzer, DAX Studio, VertiPaq tuning, BPA |
| `powerbi-debugging` | 4-domain debugging framework (ETL, relationships/context, DAX, performance) |
| `powerbi-report-design` | Data storytelling, visual hierarchy, UX, accessibility, themes |
| `powerbi-requirements` | Requirements translation, KPI/metric definition, stakeholder management |
| `powerbi-pbip-deploy` | **Save work directly as a Power BI project (PBIP) with no account or sign-in** |
| `powerbi-certification` | PL-300 / DP-600 / DP-700 aligned standards checklist for enterprise-grade output |

## Cross-AI compatibility

The skills are authored in the open **Agent Skills** format (`SKILL.md` with YAML frontmatter). The plugin ships with `install.ps1`, an idempotent adapter script that wires the skills into every major agent:

- **Claude Code / Claude Desktop** → copies skill folders to `~/.claude/skills/`
- **Cline** → discovered automatically from `~/.agents/plugins/powerbi-dev` (like ECC)
- **Codex / Antigravity / Amp / Jules** → `AGENTS.md` block appended to `~/.codex/AGENTS.md` and repo `AGENTS.md`
- **Cursor** → writes `~/.cursor/rules/powerbi-dev.mdc` (auto-applies on TMDL/PBIP/M files)
- **Gemini CLI** → `GEMINI.md` block appended
- **Windsurf** → global memories rules + workspace `.windsurf/rules/`
- **GitHub Copilot (VS Code)** → workspace `.github/copilot-instructions.md`
- **Aider** → conventions file wired into `~/.aider.conf.yml`
- **RooCode / Kilo Code** → workspace `.roo/rules/` + native AGENTS.md
- Anything else → point the agent at this folder's `AGENTS.md` / `skills/` directory

Full matrix: [`docs/COMPATIBILITY.md`](docs/COMPATIBILITY.md).

Run from anywhere:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\Josh\.agents\plugins\powerbi-dev\install.ps1"
```

Add `-Uninstall` to remove every adapter. Add `-Workspace "C:\path\to\repo"` to also wire a specific repository.

## Deployment without an account

`skills/powerbi-pbip-deploy` + `assets/scaffold-pbip.ps1` generate a fully valid **Power BI Desktop project (PBIP)** folder — semantic model (TMDL) + report definition — that opens directly in Power BI Desktop and is Git-ready. No Power BI Service account, tenant, or sign-in is required to author, version, or hand off. Publish/deploy steps (XMLA/TOM, deployment pipelines) are documented as opt-in follow-ups.

## Standards baked in

- Microsoft [Best Practice Analyzer](https://github.com/microsoft/Analysis-Services/tree/master/BestPracticeRules) rule categories (naming, DAX expressions, error prevention, performance, formatting, maintenance)
- Star schema guidance from the [Power BI implementation planning](https://learn.microsoft.com/en-us/power-bi/guidance/) documentation
- SQLBI DAX patterns (DIVIDE, variables, filter columns not tables, TREATAS, calculation groups)
- Tabular Editor 2/3 scripting + TMDL authoring
