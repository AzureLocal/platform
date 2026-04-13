Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Script:RequiredFiles = @(
    'CHANGELOG.md'
    'mkdocs.yml'
    '.github/workflows/deploy-docs.yml'
    '.github/workflows/drift-check.yml'
    '.azurelocal-platform.yml'
)

$Script:IICIdentityPath = Join-Path $PSScriptRoot '..\..\..\testing\iic-canon\iic-azure-local-01.json'

# ---------------------------------------------------------------------------
# Write-AzureLocalLog
# ---------------------------------------------------------------------------
function Write-AzureLocalLog {
    <#
    .SYNOPSIS
        Consistent, timestamped, colored log output for all AzureLocal org scripts.
    .PARAMETER Level
        Log level: INFO (default), PASS, FAIL, WARN, SKIP.
    .PARAMETER Message
        The message to log.
    #>
    [CmdletBinding()]
    param(
        [ValidateSet('INFO', 'PASS', 'FAIL', 'WARN', 'SKIP')]
        [string]$Level = 'INFO',

        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Message
    )
    process {
        $ts    = Get-Date -Format 'HH:mm:ss'
        $color = switch ($Level) {
            'PASS' { 'Green'   }
            'FAIL' { 'Red'     }
            'WARN' { 'Yellow'  }
            'SKIP' { 'DarkGray'}
            default{ 'Cyan'    }
        }
        $prefix = "[$ts] [$Level]"
        Write-Host "$prefix $Message" -ForegroundColor $color
    }
}

# ---------------------------------------------------------------------------
# Resolve-IICIdentity
# ---------------------------------------------------------------------------
function Resolve-IICIdentity {
    <#
    .SYNOPSIS
        Returns the IIC canonical identity fixture as a PSCustomObject.
    .PARAMETER Path
        Override the default path to iic-azure-local-01.json.
    #>
    [CmdletBinding()]
    param(
        [string]$Path = $Script:IICIdentityPath
    )

    $resolved = Resolve-Path $Path -ErrorAction Stop
    $raw      = Get-Content $resolved -Raw -Encoding UTF8
    return $raw | ConvertFrom-Json -Depth 20
}

# ---------------------------------------------------------------------------
# Get-AzureLocalRepoInventory
# ---------------------------------------------------------------------------
function Get-AzureLocalRepoInventory {
    <#
    .SYNOPSIS
        Lists every active repository in the AzureLocal GitHub org with platform metadata.
    .PARAMETER Org
        GitHub organisation name. Defaults to AzureLocal.
    .PARAMETER IncludeArchived
        Include archived repositories.
    .OUTPUTS
        Array of PSCustomObjects: Name, Description, Visibility, HtmlUrl, UpdatedAt,
        PlatformVersion, RepoType, LastAudited, PlatformYmlPresent
    #>
    [CmdletBinding()]
    param(
        [string]$Org             = 'AzureLocal',
        [switch]$IncludeArchived
    )

    Write-AzureLocalLog -Message "Querying repos in $Org..."

    $reposJson = gh repo list $Org --json name,description,visibility,url,updatedAt,isArchived --limit 200 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "gh repo list failed: $reposJson"
    }
    $repos = $reposJson | ConvertFrom-Json

    if (-not $IncludeArchived) {
        $repos = $repos | Where-Object { -not $_.isArchived }
    }

    $inventory = foreach ($repo in $repos) {
        $platformMeta = $null
        $platformYmlPresent = $false

        $raw = gh api "repos/$Org/$($repo.name)/contents/.azurelocal-platform.yml" --jq '.content' 2>$null
        if ($LASTEXITCODE -eq 0 -and $raw) {
            try {
                $decoded = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String(($raw -replace '\s','')))
                if (Get-Module -Name 'powershell-yaml' -ListAvailable) {
                    $platformMeta = $decoded | ConvertFrom-Yaml
                } else {
                    # Minimal YAML parse for simple key: value lines
                    $platformMeta = @{}
                    foreach ($line in $decoded -split "`n") {
                        if ($line -match '^\s*(\w[\w-]*):\s*(.+?)\s*$') {
                            $platformMeta[$Matches[1]] = $Matches[2]
                        }
                    }
                }
                $platformYmlPresent = $true
            } catch {
                Write-AzureLocalLog -Level WARN -Message "$($repo.name): failed to parse .azurelocal-platform.yml — $_"
            }
        }

        [PSCustomObject]@{
            Name                = $repo.name
            Description         = $repo.description
            Visibility          = $repo.visibility
            HtmlUrl             = $repo.url
            UpdatedAt           = $repo.updatedAt
            PlatformYmlPresent  = $platformYmlPresent
            PlatformVersion     = if ($platformMeta) { $platformMeta['platformVersion'] } else { $null }
            RepoType            = if ($platformMeta) { $platformMeta['repoType'] }        else { $null }
            LastAudited         = if ($platformMeta) { $platformMeta['lastAudited'] }     else { $null }
        }
    }

    return $inventory
}

# ---------------------------------------------------------------------------
# Test-RepoConformance
# ---------------------------------------------------------------------------
function Test-RepoConformance {
    <#
    .SYNOPSIS
        Validates a single repo against the AzureLocal platform required-file standard.
    .PARAMETER Org
        GitHub organisation name.
    .PARAMETER RepoName
        Name of the repository to validate.
    .PARAMETER RequiredFiles
        Override the default list of required files.
    .OUTPUTS
        PSCustomObject: Repo, Passed, DriftCount, DriftItems[]
    #>
    [CmdletBinding()]
    param(
        [string]  $Org           = 'AzureLocal',
        [Parameter(Mandatory)]
        [string]  $RepoName,
        [string[]]$RequiredFiles = $Script:RequiredFiles
    )

    $driftItems = [System.Collections.Generic.List[string]]::new()

    foreach ($file in $RequiredFiles) {
        $exists = gh api "repos/$Org/$RepoName/contents/$file" 2>$null
        if ($LASTEXITCODE -ne 0) {
            $driftItems.Add("MISSING: $file")
        }
    }

    # Check deploy-docs.yml references the platform reusable workflow
    $deployDocs = gh api "repos/$Org/$RepoName/contents/.github/workflows/deploy-docs.yml" --jq '.content' 2>$null
    if ($LASTEXITCODE -eq 0 -and $deployDocs) {
        $decoded = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String(($deployDocs -replace '\s','')))
        if ($decoded -notmatch 'AzureLocal/platform/.github/workflows/reusable-mkdocs-deploy\.yml') {
            $driftItems.Add("DRIFT: deploy-docs.yml does not call reusable-mkdocs-deploy.yml")
        }
    }

    return [PSCustomObject]@{
        Repo       = $RepoName
        Passed     = ($driftItems.Count -eq 0)
        DriftCount = $driftItems.Count
        DriftItems = $driftItems.ToArray()
    }
}
