# Modeling & TMDL Style Rules (powerbi-dev)

Apply when creating tables, relationships, or editing TMDL in PBIP projects.

- Star schema: fact per business process; denormalized dimensions; conformed across facts.
- Single-direction `1:*` relationships by default; bidirectional/many-to-many require written justification.
- Mark a real date dimension; disable auto date/time; no auto hierarchies in deliverables.
- All measures live in a `_Measures` display folder/table; keys and fact FKs hidden; descriptions on visible objects.
- TMDL: tab indentation; UTF-8 without BOM; `lineageTag` GUIDs stable across edits; `sourceColumn` must match partition output columns.
- Partition name = table name for single-partition tables; columns projected explicitly (no `SELECT *` drift).
- Relationship columns: identical data types, no float keys.
- Incremental refresh: `RangeStart`/`RangeEnd` exact names, foldable datetime filter.
- Every visible object has a description; every measure has a format string.
