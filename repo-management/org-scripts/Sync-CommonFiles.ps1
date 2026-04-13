<#
.SYNOPSIS
    Propagates canonical common files from the platform repo to every AzureLocal repo.

.DESCRIPTION
    Compares the platform's canonical versions of shared files (LICENSE, .editorconfig,
    .gitignore) against each consumer repo's copy, then either reports the diff or opens
    a pull request with the updated content.

    Files with per-repo customisation (CODEOWNERS, CHANGELOG.md) are reported but
    never overwritten automatically.

.PARAMETER Org
    GitHub organisation name. Defaults to AzureLocal.

.PARAMETER PlatformRoot
    Path to the local platform clone. Defaults to two levels up from this script.

.PARAMETER Repos
    Explicit list of repo names to target. If omitted, targets all non-archived repos
    excluding 'platform' itself.

.PARAMETER Files
    List of file paths (relative to repo root) to sync. Defaults to the canonical set.

.PARAMETER CreatePR
    When specified, creates a pull request in repos where drift is detected.
    Without this switch, the script reports drift but makes no changes.

.PARAMETER DryRun
    Print what would change without making any GitHub API or git operations.

.EXAMPLE
    # Report drift only
    ./Sync-CommonFiles.ps1

.EXAMPLE
    # Open PRs in drifted repos
    ./Sync-CommonFiles.ps1 -CreatePR

.EXAMPLE
    # Single repo, dry run
    ./Sync-CommonFiles.ps1 -Repos azurelocal-ranger -DryRun

.NOTES
    Requires: gh CLI authenticated, git in PATH.
    Files that don't exist in a consumer repo are created (not skipped).
#>
[CmdletBinding()]
param(
    [string]  $Org          = 'AzureLocal',
    [string]  $PlatformRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')),
    [string[]]$Repos,
    [string[]]$Files        = @('LICENSE', '.editorconfig', '.gitignore'),
    [switch]  $CreatePR,
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
# Resolve target repos
# ---------------------------------------------------------------------------
if (-not $Repos) {
    $repoListJson = gh repo list $Org --json name,isArchived --limit 200 2>&1
    if ($LASTEXITCODE -ne 0) { throw "gh repo list failed: $repoListJson" }
    $Repos = ($repoListJson | ConvertFrom-Json) |
             Where-Object { -not $_.isArchived -and $_.name -ne 'platform' } |
             Select-Object -ExpandProperty name
}

Log INFO "Checking $($Files.Count) file(s) across $($Repos.Count) repo(s)"

$totalDrift = 0; $totalSynced = 0; $totalErrors = 0
$tempDir    = New-Item -ItemType Directory -Path (Join-Path ([IO.Path]::GetTempPath()) "azl-sync-$(Get-Date -Format 'yyyyMMddHHmmss')") -Force

try {
    foreach ($repoName in $Repos) {
        Log INFO "--- $repoName ---"
        $repoDrift = [System.Collections.Generic.List[string]]::new()

        foreach ($file in $Files) {
            # Read canonical file from platform
            $canonPath = Join-Path $PlatformRoot $file
            if (-not (Test-Path $canonPath)) {
                Log SKIP "  $file — not in platform root, skipping"
                continue
            }
            $canonContent = Get-Content $canonPath -Raw -Encoding UTF8

            # Read consumer's copy via API
            $encoded = gh api "repos/$Org/$repoName/contents/$($file -replace '\\','/')" --jq '.content' 2>$null
            if ($LASTEXITCODE -eq 0 -and $encoded) {
                $consumerContent = [System.Text.Encoding]::UTF8.GetString(
                    [Convert]::FromBase64String(($encoded -replace '\s',''))
                )
                if ($canonContent.TrimEnd() -eq $consumerContent.TrimEnd()) {
                    Log SKIP "  $file — in sync"
                    continue
                }
                $repoDrift.Add($file)
                Log WARN "  $file — DRIFT detected"
                $totalDrift++
            } else {
                $repoDrift.Add($file)
                Log WARN "  $file — MISSING in $repoName"
                $totalDrift++
            }
        }

        if ($repoDrift.Count -eq 0) { continue }

        if ($DryRun) {
            Log WARN "  [DRY] Would open PR for: $($repoDrift -join ', ')"
            continue
        }

        if (-not $CreatePR) { continue }

        # Clone repo, apply changes, push branch, open PR
        $cloneDir = Join-Path $tempDir $repoName
        Log INFO "  Cloning $repoName..."
        git clone "https://github.com/$Org/$repoName.git" $cloneDir --depth 1 --quiet 2>&1 | Out-Null

        $branchName = "platform/sync-common-files-$(Get-Date -Format 'yyyyMMdd')"
        Push-Location $cloneDir
        try {
            git checkout -b $branchName --quiet 2>&1 | Out-Null
            foreach ($file in $repoDrift) {
                $dest      = Join-Path $cloneDir $file
                $canonPath = Join-Path $PlatformRoot $file
                $destDir   = Split-Path $dest -Parent
                if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }
                Copy-Item $canonPath $dest -Force
                git add $file 2>&1 | Out-Null
            }
            git config user.email 'github-actions[bot]@users.noreply.github.com'
            git config user.name  'github-actions[bot]'
            git commit -m "chore: sync common platform files

Files updated by Sync-CommonFiles.ps1 from AzureLocal/platform@main.
Affected: $($repoDrift -join ', ')" --quiet 2>&1 | Out-Null
            git push origin $branchName --quiet 2>&1 | Out-Null

            $prResult = gh pr create `
                --repo "$Org/$repoName" `
                --title "chore: sync common platform files" `
                --body "Automated sync of $(($repoDrift).Count) file(s) from platform canonical versions.``n``nFiles: $($repoDrift -join ', ')``n``n---``n*Created by Sync-CommonFiles.ps1*" `
                --head $branchName `
                --base main 2>&1

            if ($LASTEXITCODE -eq 0) {
                Log PASS "  PR created: $prResult"
                $totalSynced++
            } else {
                Log FAIL "  PR creation failed: $prResult"
                $totalErrors++
            }
        } finally {
            Pop-Location
        }
    }
} finally {
    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}

Log INFO "=============================="
Log INFO "Drift detected : $totalDrift file(s)"
Log INFO "PRs created    : $totalSynced"
if ($totalErrors -gt 0) { Log FAIL "Errors         : $totalErrors" } else { Log PASS "Errors         : 0" }
Log INFO "=============================="
if ($DryRun)     { Log WARN "DRY RUN — no changes were made" }
if (-not $CreatePR -and -not $DryRun -and $totalDrift -gt 0) {
    Log WARN "Re-run with -CreatePR to open pull requests for the $totalDrift drifted file(s) above."
}
