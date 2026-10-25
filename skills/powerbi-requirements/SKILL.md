---
name: powerbi-requirements
description: "Business integration for Power BI: requirements gathering, translating operational requests into technical specifications, KPI/metric definition with formulas and grain, stakeholder management between engineering and end users, and delivery scoping. Use at the start of any report project, when the request is vague, or when KPI definitions need to be pinned down."
metadata:
  version: "1.0.0"
---

# Requirements & Stakeholder Management

## Phase 1 — Discovery (ask before building)

Minimum viable question set (max 5, adapt):

1. **Business questions:** "What decision will this report change?" (not "what charts do you want")
2. **KPIs:** "Which 3-5 numbers, exactly, with how each is computed today?" (get the Excel formula if one exists)
3. **Grain & time:** "Daily/weekly/monthly? What period comparisons matter (YoY, MoM, vs target)?"
4. **Audience & security:** "Who sees this, and does anyone see less than others?"
5. **Source & cadence:** "Where does the data live, how fresh must it be, who owns it?"

## Phase 2 — Specification (sign-off artifact)

Produce a one-page spec before modeling:

```
Report name / owner / date
Business questions: Q1..Qn
KPIs:
  - [KPI name] = <formula in business words> ; grain: <per X per day> ; source columns: <t>
  - Owner sign-off: yes/no
Dimensions: [Date, Customer, Product, Region...]
Security tiers: [role → visibility]
Refresh: [source, cadence, gateway?]
Acceptance criteria: [numbers that must match the current system + where]
Out of scope: [...]
```

**Acceptance criteria are numbers, not vibes**: "October revenue on the new report equals October revenue in Finance's ledger ± 0.5%, reconciled per region."

## KPI definition discipline

- Every KPI gets: name, formula (business + eventual DAX), grain, allowed filter dimensions, comparison basis, and an owner who signs off.
- Separate **metric definition** (finance-approved) from **report presentation** (rankings, RAG colors).
- Flag conflicting definitions between stakeholders — resolve at spec time, not after the first steering meeting.
- Record known data quality caveats (late-arriving orders, restatements) in the spec and in measure descriptions.

## Stakeholder management

- **Executives:** talk decisions and KPIs, not tech; demo early with sample data; never present model internals.
- **End users:** walkthrough of interactions (slicers, drillthrough, export); capture their "where's the number I check every morning" and reproduce it.
- **Engineering/data teams:** agree on contract — views/tables they expose, refresh windows, gateway ownership; never join their raw tables directly when a curated view exists.
- Change requests: re-issue the one-page spec with a version bump; small changes ship fast, definitional changes (KPI formulas) always get owner re-sign-off.

## Anti-patterns

- Building from a screenshot of a report someone liked.
- "Just pull everything" scoping — every column costs memory and governance.
- Accepting "the number is wrong" without the reference number and its source.
- Skipping acceptance criteria because "it's just a dashboard."
