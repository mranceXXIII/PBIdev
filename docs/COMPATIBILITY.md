# AI Tool Compatibility Matrix

The plugin is authored in **two open standards**, which is what makes it portable:

1. **Agent Skills format** (`skills/<name>/SKILL.md`) — the de-facto skill standard (Claude, Cline, and compatible agents).
2. **AGENTS.md format** (this plugin's `AGENTS.md` + the per-tool wiring done by `install.ps1`) — the open agent-instructions standard stewarded by the Linux Foundation.

## Adapter coverage (wired by `install.ps1`)

| AI Tool | What `install.ps1` does | Scope |
|---|---|---|
| **Cline** | Copies rule to `~/.cline/rules/` **and** is auto-discovered as a plugin from `~/.agents/plugins/powerbi-dev` | Global + plugin skills |
| **Claude Code / Claude Desktop** | Copies all 11 skill folders to `~/.claude/skills/` | Global |
| **Codex (OpenAI)** | Marker block in `~/.codex/AGENTS.md` | Global |
| **Antigravity** | Reads `AGENTS.md` (Google's agent reads repo/global AGENTS.md) | Global + workspace |
| **Cursor** | Rule file `~/.cursor/rules/powerbi-dev.mdc`, auto-applies on `.tmdl/.pbip/.m/.pbir` files | Global + workspace |
| **Gemini CLI** | Marker block in `~/.gemini/GEMINI.md` | Global |
| **Windsurf** | Marker block in `~/.codeium/windsurf/memories/global_rules.md`; workspace rule in `.windsurf/rules/` | Global + workspace |
| **GitHub Copilot (VS Code / github.com)** | `.github/copilot-instructions.md` in the workspace | Workspace |
| **Aider** | Conventions file `~/.aider/powerbi-dev-conventions.md` + `read:` entry in `~/.aider.conf.yml` | Global |
| **RooCode** | `.roo/rules/powerbi-dev.md` in the workspace | Workspace |
| **Kilo Code** | Reads `AGENTS.md` natively; also gets the Roo-style workspace rule | Workspace |

## Native AGENTS.md readers (zero extra wiring needed)

These tools automatically read the `AGENTS.md` that `install.ps1 -Workspace` (or you) places in a repository root:

Codex, **Zed**, **Warp**, **OpenCode**, **Goose (Block)**, **Jules (Google)**, **Devin (Cognition)**, **Factory**, **Amp**, **Phoenix**, **Semgrep agent**, **Augment Code**, **Windsurf**, **Aider** (with `--read`), **GitHub Copilot** (workspace mode), **Kilo Code**, **RooCode**.

## Install commands

```powershell
# All global adapters (Claude, Cline, Codex, Cursor, Gemini, Windsurf, Aider)
powershell -ExecutionPolicy Bypass -File "C:\Users\Josh\.agents\plugins\powerbi-dev\install.ps1"

# Also wire a specific repository (AGENTS.md, Cursor, Copilot, Windsurf, Roo, Aider)
powershell -ExecutionPolicy Bypass -File "C:\Users\Josh\.agents\plugins\powerbi-dev\install.ps1" -Workspace "C:\path\to\repo"

# Remove every adapter (plugin folder itself stays)
powershell -ExecutionPolicy Bypass -File "C:\Users\Josh\.agents\plugins\powerbi-dev\install.ps1" -Uninstall
```

## Any other AI tool

If a tool isn't listed, it almost certainly reads one of the two open standards. Either:

- point it at `C:\Users\Josh\.agents\plugins\powerbi-dev\AGENTS.md` as its instruction file, or
- copy the `skills/` folder into whatever directory the tool uses for skills/rules (they are plain `SKILL.md` folders).

All wiring is **marker-delimited and idempotent** — re-running never duplicates, and `-Uninstall` removes only plugin blocks, never touching your own content.
