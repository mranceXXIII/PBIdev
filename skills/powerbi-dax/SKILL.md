---
name: powerbi-dax
description: "Write, review, and optimize DAX: measures, evaluation context, context transition, CALCULATE discipline, time intelligence, CALCULATETABLE/TREATAS, variables, calculation groups, and common error patterns (wrong totals, many-to-many inflation, RLS+USERELATIONSHIP conflicts). Use for any measure creation, DAX debugging, or performance work in Power BI."
metadata:
  version: "1.0.0"
---

# DAX Mastery

## Mental model (always apply)

1. **Evaluation context = filter context + row context.** Every measure runs in a filter context coming from visuals/slicers/RLS/relationships.
2. **Context transition:** wrapping a measure or invoking a measure inside a row-context iterator converts the row to an equivalent filter context.
3. **`CALCULATE` is the only function that modifies filter context** — read every `CALCULATE` as "what does this change?"
4. **Filter columns, not tables**, in `CALCULATE` filter arguments. Table filters replace the whole context on that table's dimension; column filters intersect.
5. **Variables are evaluated once, where defined** (in their surrounding context). Use `VAR ... RETURN` for readability, single evaluation, and debugging (return a VAR to inspect it).

## Non-negotiable style (BPA + SQLBI)

- Division → always `DIVIDE(numer, denom [, alternative])`, never `/` unguarded.
- Fully qualify column refs `'Table'[Column]`; measures referenced bare (no table prefix) — this distinguishes measures from columns at a glance.
- No two measures with the same definition; no `EVALUATEANDLOG` in production.
- Percentages: compute via `DIVIDE` then format string, not `*100` with number format.
- Avoid `1-(x/y)` syntax; avoid `IFERROR` as a business-logic mask.
- Prefer measures over calculated columns (calculated columns consume RAM and are evaluated during refresh).
- Calculated tables only for static/structural needs (e.g., disconnected slicer tables), not for facts.

## Canonical patterns

**YTD / MTD / SOTP (time intelligence):**
```dax
Sales YTD =
CALCULATE(
    [Sales Amount],
    DATESYTD( 'Date'[Date] )
)

Sales PY =
CALCULATE(
    [Sales Amount],
    DATEADD( 'Date'[Date], -1, YEAR )
)

Sales YoY % =
VAR CurrentValue = [Sales Amount]
VAR PreviousValue = [Sales PY]
RETURN DIVIDE( CurrentValue - PreviousValue, PreviousValue )
```

**Period-over-period with month granularity guard:**
```dax
Sales MoM % =
VAR CurrentValue = [Sales Amount]
VAR PreviousValue =
    CALCULATE( [Sales Amount], DATEADD( 'Date'[Date], -1, MONTH ) )
RETURN DIVIDE( CurrentValue - PreviousValue, PreviousValue )
```

**Filter by another table's values (TREATAS):**
```dax
Budget Allocated =
CALCULATE(
    [Budget Amount],
    TREATAS( VALUES( 'Date'[Date] ), Budget[Date] )
)
```

**Semi-additive (last non-empty / closing balance):**
```dax
Inventory Closing Balance =
CALCULATE(
    LASTNONBLANKVALUE( 'Date'[Date], SUM( Inventory[Qty] ) ),
    LASTDATE( 'Date'[Date] )
)
```

**New/returning customers:**
```dax
New Customers =
VAR CurrentCustomers = VALUES( Sales[customer_key] )
VAR PriorCustomers =
    CALCULATETABLE( VALUES( Sales[customer_key] ),
        DATEADD( 'Date'[Date], -1, YEAR ) )
RETURN COUNTROWS( EXCEPT( CurrentCustomers, PriorCustomers ) )
```

**RANKX done right:**
```dax
Product Sales Rank =
IF(
    NOT ISBLANK( [Sales Amount] ),
    RANKX( ALLSELECTED( 'Product'[Product Name] ), [Sales Amount] )
)
```

## Common bugs → diagnosis

| Symptom | Likely cause |
|---|---|
| Total ≠ sum of rows | Non-additive measure (ratio/rank) rendered at grand total; wrap with `SUMX` over the grain or `HASONEVALUE` guard |
| Numbers explode after model change | New bidirectional / many-to-many relationship inflating context |
| Measure blank for some months | Date dimension not contiguous, or relationship inactive (`USERELATIONSHIP` missing) |
| Slicer has no effect | Filter applied on a disconnected table or `ALL`/`ALLSELECTED` misuse |
| Slow visual with DirectQuery | Iterator + context transition over large cardinality; check `powerbi-performance` skill |
| RLS users see wrong totals | `USERELATIONSHIP` used against an RLS-secured table (BPA error-prevention rule) or `ALL` removing the security filter |

## Debugging technique

1. Deconstruct into `VAR`s; temporarily `RETURN` each var to isolate where the number diverges.
2. Materialize virtual tables to inspect: `EVALUATE` in DAX Studio, or `CONCATENATEX` debug measure inside the report.
3. Check filter context with `ALLSELECTED()`/`SELECTEDVALUE()` probes on a card visual.
4. Only then re-optimize (avoid `FILTER` over whole tables, prefer column filters, cache-friendly patterns).
