<#
.SYNOPSIS
    Bootstrap a new AzureLocal organisation repository from the platform template scaffolds.

.DESCRIPTION
    New-AzureLocalRepo.ps1 creates a new GitHub repository under the AzureLocal organisation,
    scaffolds it from the platform's canonical templates, applies branch protection, and syncs
    the canonical label set. Everything that takes more than 10 minutes manually becomes a
    single command.

    Process:
      1. Validate inputs
      2. Merge templates/_common/ + templates/<Type>/ into a temp directory
      3. Substitute {{TOKEN}} placeholders with supplied values
      4. gh repo create AzureLocal/<Name> (public, MIT)
      5. git push the scaffolded tree
      6. Apply branch protection via Sync-BranchProtection.ps1
      7. Apply canonical labels via Sync-Labels.ps1

.PARAMETER Type
    Template variant to use. One of: ps-module, ts-web-app, iac-solution, migration-runbook, training-site.

.PARAMETER Name
    Repository name, including the azurelocal- prefix (e.g., azurelocal-foo).

.PARAMETER Description
    Short description for the GitHub repo and template substitution.

.PARAMETER ModuleName
    For ps-module type: the PowerShell module name (e.g., AzureLocalFoo).
    Defaults to PascalCase of the Name without the 'azurelocal-' prefix.

.PARAMETER DryRun
    Scaffold the template into a temp directory and show what would be created,
    without creating the GitHub repo or pushing anything.

.PARAMETER SkipBranchProtection
    Skip applying branch protection rules after repo creation.

.PARAMETER SkipLabels
    Skip syncing canonical labels after repo creation.

.PARAMETER PlatformRoot
    Path to the local platform clone. Defaults to two levels up from this script.

.EXAMPLE
    # Create a new PS module repo
    ./New-AzureLocalRepo.ps1 -Type ps-module -Name azurelocal-surveyor2 -Description "Next gen surveyor"

.EXAMPLE
    # Dry run a new IaC solution
    ./New-AzureLocalRepo.ps1 -Type iac-solution -Name azurelocal-aks -Description "AKS on Azure Local" -DryRun

.NOTES
    Requires: gh CLI authenticated with org:write scope, git in PATH.
    See: docs/templates/overview.md
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('ps-module', 'ts-web-app', 'iac-solution', 'migration-runbook', 'training-site')]
    [string]$Type,

    [Parameter(Mandatory)]
    [ValidatePattern('^azurelocal-[a-z0-9][a-z0-9-]{1,40}$')]
    [string]$Name,

    [Parameter(Mandatory)]
    [string]$Description,

    [string]$ModuleName,

    [Parameter(HelpMessage='GUID for the matching option on the AzureLocal Solutions project board (Solution field). Look up via: gh api graphql -f query=''{ organization(login: "AzureLocal") { projectV2(number: 3) { fields(first: 30) { nodes { ... on ProjectV2SingleSelectField { name options { id name } } } } } } }''')]
    [string]$SolutionOptionId = '',

    [switch]$DryRun,
    [switch]$SkipBranchProtection,
    [switch]$SkipLabels,

    [string]$PlatformRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$commonModule = Join-Path $PlatformRoot 'modules\powershell\AzureLocal.Common\AzureLocal.Common.psd1'
if (Test-Path $commonModule) { Import-Module $commonModule -Force }

function Log($level, $msg) {
    if (Get-Command Write-AzureLocalLog -ErrorAction SilentlyContinue) {
        Write-AzureLocalLog -Level $level -Message $msg
    } else {
        Write-Host "[$level] $msg"
    }
}

# ---------------------------------------------------------------------------
# Derive module name if not supplied
# ---------------------------------------------------------------------------
if (-not $ModuleName) {
    # azurelocal-s2d-cartographer -> S2DCartographer
    $parts = ($Name -replace '^azurelocal-','') -split '-'
    $ModuleName = ($parts | ForEach-Object { $_.Substring(0,1).ToUpper() + $_.Substring(1) }) -join ''
}

# ---------------------------------------------------------------------------
# Build token map
# ---------------------------------------------------------------------------
$tokens = @{
    '{{REPO_NAME}}'        = $Name
    '{{MODULE_NAME}}'      = $ModuleName
    '{{DESCRIPTION}}'      = $Description
    '{{REPO_TYPE}}'        = $Type
    '{{YEAR}}'             = (Get-Date).Year.ToString()
    '{{AUDIT_DATE}}'       = (Get-Date -Format 'yyyy-MM-dd')
    '{{MODULE_GUID}}'      = [guid]::NewGuid().ToString()
    '{{ID_PREFIX}}'        = $ModuleName.ToUpper()
    '{{MAPROOM}}'          = if ($Type -eq 'ps-module') { 'true' } else { 'false' }
    '{{SOLUTION_OPTION_ID}}' = $SolutionOptionId
}

if (-not $SolutionOptionId) {
    Log 'WARN' "No -SolutionOptionId supplied. add-to-project.yml will need a manual edit before the workflow runs successfully."
    Log 'INFO' "Look up the GUID with: gh api graphql -f query='{ organization(login: \"AzureLocal\") { projectV2(number: 3) { fields(first: 30) { nodes { ... on ProjectV2SingleSelectField { name options { id name } } } } } } }'"
}

# Workflows adopted
$workflowMap = @{
    'ps-module'        = "['mkdocs-deploy', 'ps-module-ci', 'drift-check', 'release-please', 'validate-structure', 'add-to-project']"
    'ts-web-app'       = "['mkdocs-deploy', 'ts-web-ci', 'drift-check', 'release-please', 'validate-structure', 'add-to-project']"
    'iac-solution'     = "['mkdocs-deploy', 'iac-validate', 'drift-check', 'release-please', 'validate-structure', 'add-to-project']"
    'migration-runbook'= "['mkdocs-deploy', 'drift-check', 'release-please', 'validate-structure', 'add-to-project']"
    'training-site'    = "['mkdocs-deploy', 'drift-check', 'release-please', 'validate-structure', 'add-to-project']"
}
$tokens['{{WORKFLOWS_ADOPTED}}'] = $workflowMap[$Type]

# ---------------------------------------------------------------------------
# Merge _common + variant into temp directory
# ---------------------------------------------------------------------------
$tempRoot = Join-Path ([IO.Path]::GetTempPath()) "azl-new-repo-$Name-$(Get-Date -Format 'yyyyMMddHHmmss')"
New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

Log INFO "Scaffolding from templates/_common + templates/$Type"

# Copy _common first, then overlay variant (variant wins)
$commonDir  = Join-Path $PlatformRoot "templates\_common"
$variantDir = Join-Path $PlatformRoot "templates\$Type"

foreach ($sourceDir in @($commonDir, $variantDir)) {
    if (-not (Test-Path $sourceDir)) {
        Log WARN "Template directory not found: $sourceDir — skipping"
        continue
    }
    Get-ChildItem $sourceDir -Recurse -File | ForEach-Object {
        $rel  = $_.FullName.Substring($sourceDir.Length).TrimStart('\/')
        $dest = Join-Path $tempRoot $rel
        $destDir = Split-Path $dest -Parent
        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }

        # Handle template filenames that contain tokens (e.g., {{MODULE_NAME}}.psd1)
        $destName = $dest
        foreach ($kv in $tokens.GetEnumerator()) {
            $destName = $destName -replace [regex]::Escape($kv.Key), $kv.Value
        }

        Copy-Item $_.FullName $destName -Force
    }
}

# ---------------------------------------------------------------------------
# Substitute tokens in all text files
# ---------------------------------------------------------------------------
$textExtensions = @('.md','.yml','.yaml','.json','.psd1','.psm1','.ps1','.ts','.tsx','.js','.html','.css','.toml','.txt','.gitignore','.editorconfig')
Get-ChildItem $tempRoot -Recurse -File | ForEach-Object {
    if ($textExtensions -contains $_.Extension -or $_.Name -match '^\.(gitignore|editorconfig|codeowners)$') {
        $content = Get-Content $_.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
        if ($content) {
            $newContent = $content
            foreach ($kv in $tokens.GetEnumerator()) {
                $newContent = $newContent -replace [regex]::Escape($kv.Key), $kv.Value
            }
            if ($newContent -ne $content) {
                Set-Content -Path $_.FullName -Value $newContent -Encoding UTF8 -NoNewline
            }
        }
    }
}

Log INFO "Scaffold written to: $tempRoot"

if ($DryRun) {
    Log WARN "DRY RUN — listing scaffold contents:"
    Get-ChildItem $tempRoot -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($tempRoot.Length).TrimStart('\/')
        Log INFO "  $rel"
    }
    Log WARN "DRY RUN complete — no GitHub repo created."
    Remove-Item $tempRoot -Recurse -Force
    return
}

# ---------------------------------------------------------------------------
# Create GitHub repo
# ---------------------------------------------------------------------------
Log INFO "Creating GitHub repo AzureLocal/$Name..."
$createResult = gh repo create "AzureLocal/$Name" `
    --public `
    --description $Description `
    --license MIT `
    2>&1

if ($LASTEXITCODE -ne 0) {
    throw "gh repo create failed: $createResult"
}
Log PASS "Repo created: https://github.com/AzureLocal/$Name"

# ---------------------------------------------------------------------------
# Initial push
# ---------------------------------------------------------------------------
Push-Location $tempRoot
try {
    git init --initial-branch=main --quiet
    git config user.email 'github-actions[bot]@users.noreply.github.com'
    git config user.name  'github-actions[bot]'
    git remote add origin "https://github.com/AzureLocal/$Name.git"

    # gh repo create --license MIT seeds remote main with a LICENSE commit.
    # Pull it in so the scaffold push isn't rejected as non-fast-forward.
    git fetch origin main --quiet 2>$null
    if ($LASTEXITCODE -eq 0) {
        git reset --soft FETCH_HEAD --quiet
    }

    git add -A
    git commit -m "chore: scaffold $Name from platform template ($Type)" --quiet
    git push -u origin main --quiet
    if ($LASTEXITCODE -ne 0) {
        throw "git push to AzureLocal/$Name failed (exit $LASTEXITCODE) — scaffold not on remote."
    }
    Log PASS "Initial commit pushed."
} finally {
    Pop-Location
    Remove-Item $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

# ---------------------------------------------------------------------------
# Branch protection + labels
# ---------------------------------------------------------------------------
if (-not $SkipBranchProtection) {
    Log INFO "Applying branch protection..."
    & (Join-Path $PSScriptRoot 'Sync-BranchProtection.ps1') -Repos $Name
}

if (-not $SkipLabels) {
    Log INFO "Syncing canonical labels..."
    & (Join-Path $PSScriptRoot 'Sync-Labels.ps1') -Repos $Name
}

Log PASS "=============================="
Log PASS "  $Name is ready."
Log PASS "  https://github.com/AzureLocal/$Name"
Log PASS "=============================="
