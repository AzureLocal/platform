<#
.SYNOPSIS
    Applies the canonical AzureLocal GitHub label set to every org repository.

.DESCRIPTION
    Reads label definitions from labels.json and ensures every non-archived repository
    in the AzureLocal org has those labels (correct name, color, and description).
    Labels not in the canonical set are left untouched — this script only adds/updates.

.PARAMETER Org
    GitHub organisation name. Defaults to AzureLocal.

.PARAMETER LabelsPath
    Path to the canonical labels.json. Defaults to labels.json alongside this script.

.PARAMETER Repos
    Explicit list of repo names to target. If omitted, targets all non-archived repos.

.PARAMETER DryRun
    Print what would change without making any GitHub API calls.

.EXAMPLE
    # Apply to all repos
    ./Sync-Labels.ps1

.EXAMPLE
    # Dry run on a single repo
    ./Sync-Labels.ps1 -Repos azurelocal-ranger -DryRun

.NOTES
    Requires: gh CLI authenticated with org:write scope.
#>
[CmdletBinding()]
param(
    [string]  $Org        = 'AzureLocal',
    [string]  $LabelsPath = "$PSScriptRoot/labels.json",
    [string[]]$Repos,
    [switch]  $DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$commonModule = Join-Path $PSScriptRoot '..\..\modules\powershell\AzureLocal.Common\AzureLocal.Common.psd1'
if (Test-Path $commonModule) { Import-Module $commonModule -Force }

function Log($level, $msg) {
    if (Get-Command Write-AzureLocalLog -ErrorAction SilentlyContinue) {
        Write-AzureLocalLog -Level $level -Message $msg
    } else {
        Write-Host "[$level] $msg"
    }
}

# ---------------------------------------------------------------------------
# Load canonical labels
# ---------------------------------------------------------------------------
if (-not (Test-Path $LabelsPath)) {
    throw "labels.json not found at '$LabelsPath'"
}
$canonicalLabels = Get-Content $LabelsPath -Raw | ConvertFrom-Json

Log INFO "Loaded $($canonicalLabels.Count) canonical labels from $LabelsPath"

# ---------------------------------------------------------------------------
# Resolve target repos
# ---------------------------------------------------------------------------
if (-not $Repos) {
    $repoListJson = gh repo list $Org --json name,isArchived --limit 200 2>&1
    if ($LASTEXITCODE -ne 0) { throw "gh repo list failed: $repoListJson" }
    $Repos = ($repoListJson | ConvertFrom-Json) |
             Where-Object { -not $_.isArchived } |
             Select-Object -ExpandProperty name
}

Log INFO "Targeting $($Repos.Count) repo(s)"

# ---------------------------------------------------------------------------
# Apply labels
# ---------------------------------------------------------------------------
$synced = 0; $skipped = 0; $errors = 0

foreach ($repoName in $Repos) {
    Log INFO "--- $repoName ---"

    # Get existing labels
    $existingJson = gh label list --repo "$Org/$repoName" --json name,color,description --limit 200 2>&1
    $existing = if ($LASTEXITCODE -eq 0) { ($existingJson | ConvertFrom-Json) } else { @() }
    $existingMap = @{}
    foreach ($l in $existing) { $existingMap[$l.name] = $l }

    foreach ($label in $canonicalLabels) {
        $name  = $label.name
        $color = $label.color
        $desc  = $label.description

        if ($existingMap.ContainsKey($name)) {
            $ex = $existingMap[$name]
            $needsUpdate = ($ex.color -ne $color) -or ($ex.description -ne $desc)
            if (-not $needsUpdate) {
                Log SKIP "  $name (unchanged)"
                $skipped++
                continue
            }
            if ($DryRun) {
                Log WARN "  [DRY] Would update: $name"
            } else {
                gh label edit $name --repo "$Org/$repoName" --color $color --description $desc 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) { Log PASS "  Updated: $name"; $synced++ }
                else { Log FAIL "  Failed to update: $name"; $errors++ }
            }
        } else {
            if ($DryRun) {
                Log WARN "  [DRY] Would create: $name"
            } else {
                gh label create $name --repo "$Org/$repoName" --color $color --description $desc 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) { Log PASS "  Created: $name"; $synced++ }
                else { Log FAIL "  Failed to create: $name"; $errors++ }
            }
        }
    }
}

Log INFO "=============================="
Log INFO "Labels synced  : $synced"
Log INFO "Labels skipped : $skipped"
if ($errors -gt 0) { Log FAIL "Errors         : $errors" } else { Log PASS "Errors         : 0" }
Log INFO "=============================="
if ($DryRun) { Log WARN "DRY RUN — no changes were made" }
