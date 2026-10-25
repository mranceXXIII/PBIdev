# Power Query / M Style Rules (powerbi-dev)

Apply when writing or reviewing M code.

- Stage queries: connection-only Source/Staging layer; outputs reference staging.
- One concern per query; meaningful step names; no `Changed Type1`, `Renamed Columns1` chains left uncleaned.
- Explicit data types at the source step; `any` is a bug.
- Parameters for all environment values (server, db, paths, dates); no hardcoded values.
- Preserve query folding: filter/remove columns early; verify with View Native Query; justify any `Table.Buffer`.
- Schema-drift safety: `Table.SelectColumns(..., MissingField.UseNull)` over `Table.RemoveColumns`; filtered navigation instead of positional `{0}` / hardcoded sheet names.
- Trap conversion errors with `try ... otherwise`; maintain a visible error-audit query; a delivered model must not contain unhandled `#Error`.
- `RangeStart`/`RangeEnd` incremental-refresh filter must fold and use `>= start and < end`.
- No secrets in M text; secrets belong in credentials/gateway, never in the mashup.
