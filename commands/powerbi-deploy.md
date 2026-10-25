---
description: Save Power BI work as a deployable PBIP project without connecting any account.
---

# Power BI Deploy Workflow (accountless PBIP)

## Usage

`/powerbi-deploy <project name> [output folder]`

## Steps

1. Load skill `powerbi-pbip-deploy`.
2. Scaffold:
   ```powershell
   powershell -ExecutionPolicy Bypass -File "<plugin>\assets\scaffold-pbip.ps1" -Name "<name>" -Out "<folder>" -WithSampleTable
   ```
3. Replace sample artifacts with the real deliverable: TMDL tables (modeling skill), measures (DAX skill), RLS roles (security skill), report definition as needed.
4. Verify structure: `.pbip` + `<name>.SemanticModel` (definition.pbism, definition/*.tmdl) + `<name>.Report` (definition.pbir, definition/report.json) + `.platform` files with distinct logicalIds.
5. Confirm no account dependency: no tenant URLs required to author; publishing steps documented as optional (Desktop publish, Fabric Git sync, XMLA/TOM).
6. Init Git in the folder, ensure `.gitignore` excludes `.pbi/` local state, commit.
7. Report what the user must do to open (double-click `.pbip` in Power BI Desktop) and the optional publish paths.
