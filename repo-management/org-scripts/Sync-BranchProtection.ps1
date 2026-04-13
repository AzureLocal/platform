<#
.SYNOPSIS
    Applies uniform branch protection rules to every AzureLocal org repository.

.DESCRIPTION
    Sets canonical branch protection on the default branch (main) of every non-archived
    repo in the organisation. The canonical rules are:

    - 1 required pull-request approval
    - Admins are NOT forced to obey the rules (enforce_admins: false)
    - Force-pushes disabled
    - Branch deletions disabled
    - No required status checks imposed here (repos own their own check gates)

.PARAMETER Org
    GitHub organisation name. Defaults to AzureLocal.

.PARAMETER Branch
    Branch name to protect. Defaults to main.

.PARAMETER Repos
    Explicit list of repo names to target. If omitted, targets all non-archived repos.

.PARAMETER DryRun
    Print what would change without making any GitHub API calls.

.EXAMPLE
    ./Sync-BranchProtection.ps1

.EXAMPLE
    ./Sync-BranchProtection.ps1 -Repos azurelocal-ranger,azurelocal-s2d-cartographer -DryRun

.NOTES
    Requires: gh CLI authenticated with admin:org scope (or repo admin rights on each repo).
#>
[CmdletBinding()]
param(
    [string]  $Org    = 'AzureLocal',
    [string]  $Branch = 'main',
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

# Canonical protection payload
$protection = @{
    required_status_checks        = $null
    enforce_admins                = $false
    required_pull_request_reviews = @{
        required_approving_review_count = 1
        dismiss_stale_reviews           = $false
        require_code_owner_reviews      = $false
    }
    restrictions                  = $null
    allow_force_pushes            = $false
    allow_deletions               = $false
    required_conversation_resolution = $true
} | ConvertTo-Json -Depth 5 -Compress

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

Log INFO "Applying branch protection ($Branch) to $($Repos.Count) repo(s)"

$applied = 0; $errors = 0

foreach ($repoName in $Repos) {
    if ($DryRun) {
        Log WARN "[DRY] Would set protection on $Org/$repoName branch:$Branch"
        continue
    }

    $result = $protection | gh api `
        --method PUT `
        "repos/$Org/$repoName/branches/$Branch/protection" `
        --input - 2>&1

    if ($LASTEXITCODE -eq 0) {
        Log PASS "$repoName — protection applied"
        $applied++
    } else {
        Log FAIL "$repoName — FAILED: $result"
        $errors++
    }
}

Log INFO "=============================="
Log INFO "Applied : $applied"
if ($errors -gt 0) { Log FAIL "Errors  : $errors" } else { Log PASS "Errors  : 0" }
Log INFO "=============================="
if ($DryRun) { Log WARN "DRY RUN — no changes were made" }
