# powerbi-dev scaffold script
# Creates a valid Power BI Desktop project (PBIP) folder - no Power BI account or sign-in required.
# Usage: powershell -ExecutionPolicy Bypass -File scaffold-pbip.ps1 -Name "Sales Analytics" -Out "C:\repos" [-WithSampleTable]
param(
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][string]$Out,
    [switch]$WithSampleTable
)

$ErrorActionPreference = "Stop"
$Base = $Name -replace '[^\w]', ''
$Root = Join-Path $Out $Base
if (Test-Path $Root) { throw "Target already exists: $Root" }

$Guid1 = [guid]::NewGuid().ToString()
$Guid2 = [guid]::NewGuid().ToString()

$smDir = Join-Path $Root "$Base.SemanticModel"
$smDef = Join-Path $smDir "definition"
$rpDir = Join-Path $Root "$Base.Report"
$rpDef = Join-Path $rpDir "definition"
New-Item -ItemType Directory -Path (Join-Path $smDef "tables") -Force | Out-Null
New-Item -ItemType Directory -Path $rpDef -Force | Out-Null

$utf8nb = New-Object System.Text.UTF8Encoding($false)
function Write-TextFile([string]$path, [string]$content) {
    [System.IO.File]::WriteAllText($path, $content, $script:utf8nb)
}

# .pbip shortcut
$pbip = @'
{
  "$schema": "https://developer.microsoft.com/json-schemas/fabric/pbip/pbipProperties/1.0.0/schema.json",
  "artifacts": [ { "report": { "path": "__BASE__.Report" } } ]
}
'@
$pbip = $pbip.Replace("__BASE__", $Base)
Write-TextFile (Join-Path $Root "$Base.pbip") $pbip

# .gitignore (Desktop default essentials)
Set-Content -Encoding UTF8 -Path (Join-Path $Root ".gitignore") -Value @"
# Power BI Desktop project artifacts
**/.pbi/localSettings.json
**/.pbi/cache.abf
**/.pbi/unappliedChanges.json
**/DiagramLayout.json
*.abf
"@

function New-Platform([string]$path, [string]$type, [string]$logicalId) {
    $json = @'
{
  "$schema": "https://developer.microsoft.com/json-schemas/fabric/gitIntegration/platformProperties/2.0.0/schema.json",
  "metadata": { "type": "__TYPE__", "displayName": "__NAME__" },
  "config": { "version": "2.0", "logicalId": "__ID__" }
}
'@
    $json = $json.Replace("__TYPE__", $type).Replace("__NAME__", $Name).Replace("__ID__", $logicalId)
    Write-TextFile $path $json
}

New-Platform (Join-Path $smDir ".platform") "SemanticModel" $Guid1
New-Platform (Join-Path $rpDir ".platform") "Report" $Guid2

$pbism = @'
{
  "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/semanticModel/definitionProperties/1.0.0/schema.json",
  "settings": {}
}
'@
Write-TextFile (Join-Path $smDir "definition.pbism") $pbism

$pbir = @'
{
  "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definitionProperties/1.0.0/schema.json",
  "datasetReference": { "byPath": { "path": "../__BASE__.SemanticModel" } }
}
'@
$pbir = $pbir.Replace("__BASE__", $Base)
Write-TextFile (Join-Path $rpDir "definition.pbir") $pbir

$reportJson = @'
{
  "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/report/1.0.0/schema.json",
  "pages": []
}
'@
Write-TextFile (Join-Path $rpDef "report.json") $reportJson

# --- TMDL files (tabs for indentation, UTF-8 without BOM) ---
function Write-Tmdl([string]$path, [string]$content) {
    [System.IO.File]::WriteAllText($path, $content.Replace("`r`n", "`n"), $script:utf8nb)
}

Write-Tmdl (Join-Path $smDef "database.tmdl") @"
database
	compatibilityLevel: 1567
"@

Write-Tmdl (Join-Path $smDef "model.tmdl") @"
model Model
	culture: en-US

	defaultPowerBIDataSourceVersion: powerBI_V3
	sourceQueryCulture: en-US
"@

Write-Tmdl (Join-Path $smDef "expressions.tmdl") @"
// Shared M expressions (parameters) go here, e.g.:
// expression paramServer = "my-server" meta [IsParameterQuery = true, Type = type text]
"@

Write-Tmdl (Join-Path $smDef "relationships.tmdl") @"
// Relationships go here, e.g.:
// relationship <guid>
// 	fromColumn: dim_customer.customer_key
// 	toColumn: fact_sales.customer_key
"@

if ($WithSampleTable) {
    Write-Tmdl (Join-Path $smDef "tables\dim_customer.tmdl") @"
table dim_customer
	lineageTag: $([guid]::NewGuid())

	column customer_key
		dataType: int64
		isHidden
		summarizeBy: none
		sourceColumn: customer_key
		lineageTag: $([guid]::NewGuid())

	column customer_name
		dataType: string
		summarizeBy: none
		sourceColumn: customer_name
		lineageTag: $([guid]::NewGuid())
		annotation SummarizationSetBy = Automatic

	measure 'Customers (Distinct)' =
		DISTINCTCOUNT( dim_customer[customer_key] )
			formatString: #,0
			lineageTag: $([guid]::NewGuid())

	partition dim_customer = m
		mode: import
		source =
				let
					Source = #table({"customer_key", "customer_name"}, {{1, "Contoso"}, {2, "Fabrikam"}})
				in
					Source
"@
}

Write-Host "PBIP scaffolded at: $Root"
Write-Host "Next: open '$Base.pbip' in Power BI Desktop (Developer mode), or author TMDL under definition/tables/."
