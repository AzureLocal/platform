<#
.SYNOPSIS
    Drift detection — audits every AzureLocal repo against platform canonical standards.

.DESCRIPTION
    Invoke-RepoAudit.ps1 iterates every non-archived repository in the AzureLocal GitHub
    organisation and reports drift against the canonical standards defined in the platform
    repo. Drift is any missing required file, any workflow that still uses an inline
    implementation instead of the platform reusable workflow, or any repo missing a
    .azurelocal-platform.yml descriptor.

    Run this script from a local clone of the platform repo. It requires the GitHub CLI
    (gh) to be authenticated.

.PARAMETER Org
    GitHub organisation name. Defaults to AzureLocal.

.PARAMETER EmitIssue
    When specified, creates a GitHub Issue on the platform repo labelled 'drift-report'
    with the audit summary. Requires 'issues: write' permission.

.PARAMETER OutputPath
    Optional path to write the drift report as a JSON file.

.PARAMETER FailOnDrift
    Exit with code 1 if any repos have drift. Useful for CI.

.EXAMPLE
    # Local run — print report to terminal
    ./Invoke-RepoAudit.ps1

.EXAMPLE
    # CI mode — emit issue and fail the run if drift found
    ./Invoke-RepoAudit.ps1 -EmitIssue -FailOnDrift

.NOTES
    Called by .github/workflows/drift-audit.yml on a monthly schedule.
    Requires: gh CLI authenticated, AzureLocal.Common module loaded.
#>
[CmdletBinding()]
param(
    [string]$Org        = 'AzureLocal',
    [switch]$EmitIssue,
    [string]$OutputPath,
    [switch]$FailOnDrift
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Bootstrap AzureLocal.Common
# ---------------------------------------------------------------------------
$commonModule = Join-Path $PSScriptRoot '..\..\modules\powershell\AzureLocal.Common\AzureLocal.Common.psd1'
if (Test-Path $commonModule) {
    Import-Module $commonModule -Force
} else {
    throw "AzureLocal.Common not found at '$commonModule'. Run from a full platform clone."
}

# ---------------------------------------------------------------------------
# Collect inventory
# ---------------------------------------------------------------------------
Write-AzureLocalLog -Message "======================================================"
Write-AzureLocalLog -Message "  AzureLocal Drift Audit — $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
Write-AzureLocalLog -Message "  Org: $Org"
Write-AzureLocalLog -Message "======================================================"

$inventory = Get-AzureLocalRepoInventory -Org $Org

$results = [System.Collections.Generic.List[object]]::new()

foreach ($repo in $inventory) {
    Write-AzureLocalLog -Message "Auditing $($repo.Name)..."
    $conformance = Test-RepoConformance -Org $Org -RepoName $repo.Name

    if (-not $repo.PlatformYmlPresent) {
        $conformance.DriftItems = @($conformance.DriftItems) + @('MISSING: .azurelocal-platform.yml')
        $conformance.DriftCount = $conformance.DriftItems.Count
        $conformance.Passed     = $false
    }

    if ($conformance.Passed) {
        Write-AzureLocalLog -Level PASS -Message "  $($repo.Name) — OK"
    } else {
        foreach ($item in $conformance.DriftItems) {
            Write-AzureLocalLog -Level FAIL -Message "  $($repo.Name) — $item"
        }
    }

    $results.Add([PSCustomObject]@{
        Repo        = $repo.Name
        RepoType    = $repo.RepoType
        Passed      = $conformance.Passed
        DriftCount  = $conformance.DriftCount
        DriftItems  = $conformance.DriftItems
        LastAudited = $repo.LastAudited
        HtmlUrl     = $repo.HtmlUrl
    })
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
$totalRepos  = $results.Count
$passedRepos = @($results | Where-Object { $_.Passed }).Count
$driftRepos  = $totalRepos - $passedRepos

Write-AzureLocalLog -Message "======================================================"
Write-AzureLocalLog -Message "  SUMMARY"
Write-AzureLocalLog -Message "  Total repos  : $totalRepos"
if ($passedRepos -eq $totalRepos) {
    Write-AzureLocalLog -Level PASS -Message "  Repos clean  : $passedRepos / $totalRepos"
} else {
    Write-AzureLocalLog -Level FAIL -Message "  Repos clean  : $passedRepos / $totalRepos"
    Write-AzureLocalLog -Level WARN -Message "  Repos drifted: $driftRepos"
}
Write-AzureLocalLog -Message "======================================================"

# ---------------------------------------------------------------------------
# Optional: write JSON report
# ---------------------------------------------------------------------------
if ($OutputPath) {
    $results | ConvertTo-Json -Depth 10 | Set-Content -Path $OutputPath -Encoding UTF8
    Write-AzureLocalLog -Message "Report written to $OutputPath"
}

# ---------------------------------------------------------------------------
# Optional: file a GitHub issue on the platform repo
# ---------------------------------------------------------------------------
if ($EmitIssue -and $driftRepos -gt 0) {
    $driftLines = $results |
        Where-Object { -not $_.Passed } |
        ForEach-Object {
            "### $($_.Repo)`n" + ($_.DriftItems | ForEach-Object { "- $_" } | Join-String -Separator "`n")
        }

    $body = @"
## Drift Audit Report — $(Get-Date -Format 'yyyy-MM-dd')

**$driftRepos of $totalRepos repositories** have drifted from platform standards.

$($driftLines -join "`n`n")

---
*Generated by Invoke-RepoAudit.ps1. Review and action items in [docs/repo-management/drift-audit.md](https://azurelocal.github.io/platform/repo-management/drift-audit/).*
"@

    gh issue create `
        --repo "$Org/platform" `
        --title "Drift report — $driftRepos repo(s) out of standard ($(Get-Date -Format 'yyyy-MM-dd'))" `
        --body $body `
        --label "drift-report"

    Write-AzureLocalLog -Level WARN -Message "Drift issue created on $Org/platform."
}

# ---------------------------------------------------------------------------
# Exit code
# ---------------------------------------------------------------------------
if ($FailOnDrift -and $driftRepos -gt 0) {
    exit 1
}
