@{
    RootModule           = 'AzureLocal.Maproom.psm1'
    ModuleVersion        = '0.2.0'
    CompatiblePSEditions = @('Core')
    GUID                 = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author               = 'Azure Local'
    CompanyName          = 'AzureLocal'
    Copyright            = '(c) 2026 Azure Local. MIT License.'
    Description          = 'Platform testing framework for AzureLocal repos. Provides fixture loading, fixture schema validation, IIC canon path resolution, and MAPROOM testing conventions. Consumers import this module to access shared test infrastructure.'
    PowerShellVersion    = '7.2'

    FunctionsToExport    = @(
        'Import-MaproomFixture',
        'Get-IICCanonPath',
        'Test-MaproomFixture'
    )
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()

    PrivateData          = @{
        PSData = @{
            Tags       = @('AzureLocal', 'Testing', 'MAPROOM', 'Pester', 'IIC', 'InfrastructureTesting')
            ProjectUri = 'https://github.com/AzureLocal/platform'
            LicenseUri = 'https://github.com/AzureLocal/platform/blob/main/LICENSE'
        }
    }
}
