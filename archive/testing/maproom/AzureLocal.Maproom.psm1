# AzureLocal.Maproom v0.2.0
# Platform testing framework — fixture loading, IIC canon access, MAPROOM conventions.
# https://github.com/AzureLocal/platform/tree/main/testing/maproom

Set-StrictMode -Version Latest

$Script:SchemaPath  = Join-Path $PSScriptRoot 'schema\fixture.schema.json'
$Script:IICCanonDir = Join-Path $PSScriptRoot '..\iic-canon'

# ── Public functions ───────────────────────────────────────────────────────────

function Import-MaproomFixture {
    <#
    .SYNOPSIS
        Loads a MAPROOM fixture JSON file and returns the parsed object.

    .DESCRIPTION
        Reads the fixture file at the given path, parses it as JSON, and returns
        a PSCustomObject. Does not perform schema validation — call
        Test-MaproomFixture for validated loading.

    .PARAMETER Path
        Path to the fixture JSON file.

    .EXAMPLE
        $fixture = Import-MaproomFixture -Path './tests/maproom/Fixtures/my-cluster.json'
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)][string]$Path
    )

    $resolved = Resolve-Path $Path -ErrorAction SilentlyContinue
    if (-not $resolved) {
        throw "Fixture file not found: $Path"
    }

    $content = Get-Content $resolved.Path -Raw -Encoding UTF8
    try {
        return $content | ConvertFrom-Json -Depth 20
    } catch {
        throw "Failed to parse fixture JSON at '$($resolved.Path)': $_"
    }
}

function Test-MaproomFixture {
    <#
    .SYNOPSIS
        Validates a MAPROOM fixture file against the platform fixture schema.

    .DESCRIPTION
        Loads the fixture and verifies that:
          1. 'infrastructure_type' is present and is a known value.
          2. '_metadata.fixture' and '_metadata.description' are present.
          3. Reserved sections (compliance, performance, user_journey, iac) are
             empty objects in v0.2.0 fixtures.
        Returns the parsed fixture object if valid; throws on validation failure.

    .PARAMETER Path
        Path to the fixture JSON file.

    .EXAMPLE
        $fixture = Test-MaproomFixture -Path './tests/maproom/Fixtures/my-cluster.json'
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)][string]$Path
    )

    $fixture = Import-MaproomFixture -Path $Path

    # Required field: infrastructure_type
    if (-not $fixture.infrastructure_type) {
        throw "Fixture '$Path' is missing required field 'infrastructure_type'."
    }

    $knownTypes = @('azure_local', 'avd_azure', 'avd_azure_local', 'sofs_azure_local',
                    'aks_azure_local', 'loadtools', 'vm_conversion', 'copilot')
    if ($fixture.infrastructure_type -notin $knownTypes) {
        throw "Fixture '$Path' has unknown infrastructure_type '$($fixture.infrastructure_type)'. Known values: $($knownTypes -join ', ')."
    }

    # Required field: _metadata
    if (-not $fixture._metadata) {
        throw "Fixture '$Path' is missing required '_metadata' section."
    }
    if (-not $fixture._metadata.fixture) {
        throw "Fixture '$Path' is missing '_metadata.fixture'."
    }
    if (-not $fixture._metadata.description) {
        throw "Fixture '$Path' is missing '_metadata.description'."
    }

    # Reserved sections must be empty objects in v0.2.0
    foreach ($section in @('compliance', 'performance', 'user_journey', 'iac')) {
        $val = $fixture.$section
        if ($null -ne $val) {
            $propCount = ($val | Get-Member -MemberType NoteProperty).Count
            if ($propCount -gt 0) {
                throw "Fixture '$Path' has a non-empty '$section' section. Reserved sections must be empty objects ({}) in v0.2.0 fixtures."
            }
        }
    }

    return $fixture
}

function Get-IICCanonPath {
    <#
    .SYNOPSIS
        Returns the path to the canonical IIC fixture for a given infrastructure type.

    .DESCRIPTION
        IIC (Infinite Improbability Corp) fixtures are the canonical test data
        for AzureLocal platform contract tests. This function resolves the path
        to the platform-managed IIC canon fixture for a given infrastructure type.

        Canon fixtures follow the naming pattern:
            iic-<infrastructure-type-with-hyphens>-<NN>.json

        Example: iic-azure-local-01.json for infrastructure_type 'azure_local'.

    .PARAMETER InfrastructureType
        The infrastructure_type value (e.g., 'azure_local', 'avd_azure_local').

    .PARAMETER Index
        Which numbered canon fixture to return (default: 1).

    .EXAMPLE
        $canonPath = Get-IICCanonPath -InfrastructureType azure_local
        $fixture   = Import-MaproomFixture -Path $canonPath

    .EXAMPLE
        # Use in a Pester test:
        BeforeAll {
            $fixture = Import-MaproomFixture -Path (Get-IICCanonPath -InfrastructureType azure_local)
        }
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('azure_local', 'avd_azure', 'avd_azure_local', 'sofs_azure_local',
                     'aks_azure_local', 'loadtools', 'vm_conversion', 'copilot')]
        [string]$InfrastructureType,

        [int]$Index = 1
    )

    $hyphenType = $InfrastructureType -replace '_', '-'
    $fileName   = "iic-{0}-{1:D2}.json" -f $hyphenType, $Index
    $path       = Join-Path $Script:IICCanonDir $fileName

    if (-not (Test-Path $path)) {
        throw "IIC canon fixture not found: $path. The '$InfrastructureType' canon has not been authored yet (scheduled for v0.3.0). Only 'azure_local' is available in v0.2.0."
    }

    return (Resolve-Path $path).Path
}
