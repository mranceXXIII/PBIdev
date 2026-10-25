---
name: powerbi-report-design
description: "Report design, data storytelling, and UX for Power BI: visual selection hierarchy, page layouts (overview/trend/detail), executive KPI design, minimal-ink principles, theme JSON, accessibility, tooltips, bookmarks, drillthrough, and mobile layout. Use when building or reviewing report pages, choosing visuals, designing themes, or improving dashboard readability."
metadata:
  version: "1.0.0"
---

# Data Storytelling & Report UX

## Design principles

1. **Answer-first hierarchy:** each page answers one business question. Top-left = the headline (title + KPI cards with sparkline), middle = trend/composition, bottom/side = detail table.
2. **5-second rule:** an executive must answer "how are we doing?" within 5 seconds. If a page needs a paragraph to explain, split it.
3. **Minimal ink:** max ~5-7 visuals per page; remove borders, gridlines, and backgrounds that don't inform; no pie charts > 3 slices (use bar); no dual axes without a legend story.
4. **Consistent color semantics:** green = good, red = bad, brand color = neutral/actual; one accent color for highlights; conditional formatting drives the "bad" states, not the reader.
5. **Numbers formatted for scanning:** display units (K/M), explicit format strings everywhere, no more than 2 decimals, percentages formatted as %.

## Visual selection hierarchy

| Question | Visual |
|---|---|
| Single important number + context | Card / KPI with goal + sparkline |
| Change over time | Line (continuous x-axis), area for volume |
| Composition | Stacked bar (not pie) |
| Ranking | Horizontal bar, sorted, top N |
| Contribution | Waterfall / decomposition tree |
| Distribution | Histogram / box plot |
| Relationship | Scatter with play axis |
| Detail / audit | Table with conditional formatting + row-level drillthrough |

## Page templates

- **Overview page:** 3-5 KPI cards, 1 trend line, 1 breakdown bar, slicer panel (year/region) docked left; cross-highlight, minimal scroll.
- **Trend page:** time series with period comparison toggle (YoY/MoM), small multiples per segment.
- **Detail page:** drillthrough target (right-click from any visual), full table with export enabled, back button.
- **Mobile layout:** separate mobile canvas for the overview page only; KPIs stacked, one chart, key slicer on top.

## Interactivity

- Drillthrough over separate detail pages; tooltips with mini-charts for context-on-hover.
- Bookmarks for view toggles (chart switcher) — name them; avoid bookmarking filter states users can't see.
- Slicers: dropdown for >10 items; use a dedicated disconnected table for custom toggles.

## Accessibility (WCAG-aligned, PL-300 tested)

- Tab order set logically; alt text on every visual; page/bookmark names are screen-reader friendly.
- Contrast ≥ 4.5:1 for text; never color alone to convey meaning (pair color + icon/label).
- Mark decorative images; support keyboard navigation; test high-contrast mode.

## Theme JSON (deliver a theme with every report)

Deliver `theme.json` (View → Themes → Browse) defining: data colors, foreground/background, text classes (callout ≈ 45pt, title 12pt semibold, label 10pt), visual styles (border radius, shadows off). Never rely on default palette for a branded deliverable.

## Review checklist

- [ ] Every page has a title stating the question it answers
- [ ] KPIs use explicit measures (no implicit aggregations)
- [ ] All visuals have alt text and formatted numbers
- [ ] Filters/interactions audited (no hidden page filters surprising users)
- [ ] Drillthrough + back button on detail pages
- [ ] Theme applied, no default colors
- [ ] Mobile layout for the primary page
