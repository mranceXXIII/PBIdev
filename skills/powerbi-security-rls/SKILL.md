---
name: powerbi-security-rls
description: "Row-Level and Object-Level Security in Power BI: static and dynamic RLS roles, USERPRINCIPALNAME mapping patterns, security dimension design, RLS testing with View As, OLS for sensitive columns, workspace/governance practices, and sensitivity labels. Use when defining roles, restricting data by user/region/tier, or auditing security before publication."
metadata:
  version: "1.0.0"
---

# Security & Governance (RLS / OLS)

## Rules

1. Security lives in the **model**, never in report-level filters or page hiding. If data must be invisible to a role, it must be RLS/OLS — anything else is cosmetic.
2. Roles filter **dimension tables**, never fact tables directly (filter propagates dim→fact through relationships).
3. **Dynamic RLS** via a security/mapping dimension for multi-tier orgs; **static RLS** only for a handful of fixed roles.
4. Never combine `USERELATIONSHIP` activation with RLS on the same table without explicit review (BPA error-prevention rule — breaks the security filter path).
5. Keep RLS DAX minimal — it executes per query for every user; complex logic belongs in the mapping dimension.
6. Test with **View As** (Desktop → Modeling → View As) for every role + "Other person" (`USERPRINCIPALNAME` simulation) before publishing.

## Static role example

```
Role "Regional Manager - West" on dim_region:
  [Region] = "West"
```

## Dynamic RLS pattern (preferred)

Model: `dim_security ( user_email, region_key )` bridging users to allowed regions, related to `dim_region`.

```dax
// Role "Dynamic Region" filter on dim_security:
[User Email] = USERPRINCIPALNAME()
```

- `USERPRINCIPALNAME()` returns UPN in the Service and in Desktop "View As → Other person".
- Mapping table hidden; consider `LOWER()`/`TRIM()` normalization at load, not in the filter.
- For hierarchy scenarios (manager sees subtree), use a path-based dimension (`PATH`/`PATHCONTAINS`) computed upstream in the warehouse or mapping table.

## Many-to-many variant (user ↔ region)

If a user can see multiple regions and a region multiple users: bridge `dim_security(user_email, region_key)` with bidirectional filtering **only between dim_security and dim_region**, or better, filter via `TREATAS` inside measures to avoid bi-directional blast radius. Document whichever is chosen.

## Object-Level Security (OLS)

- Hide sensitive columns/tables per role via TMDL `metadataPermission`:
```tmdl
role HR_Restricted
	modelPermission: read

	tablePermission PII_Column = none
```
- OLS applies to whole tables or columns (not rows); combine with RLS for row + column restrictions.

## Governance checklist (pre-publication)

- [ ] Every role tested with View As; screenshots/notes recorded
- [ ] Members not hard-assigned in dev (assign in Service via AD groups)
- [ ] `USERPRINCIPALNAME()` casing handled at load
- [ ] No RLS on tables filtered with `USERELATIONSHIP`
- [ ] OLS for PII columns (national IDs, salary, health fields)
- [ ] Sensitivity labels applied at workspace/publish level; tenant settings verified with your admin
- [ ] Workspace roles documented: Viewer/Contributor/Member split; write access is not data access (RLS still enforced)
