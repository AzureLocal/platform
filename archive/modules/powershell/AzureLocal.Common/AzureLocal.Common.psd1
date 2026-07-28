@{
    RootModule        = 'AzureLocal.Common.psm1'
    ModuleVersion     = '0.2.0'
    GUID              = 'd4e5f6a7-b8c9-4d0e-af2a-3b4c5d6e7f80'
    Author            = 'AzureLocal Platform'
    CompanyName       = 'AzureLocal'
    Copyright         = '(c) 2026 AzureLocal. All rights reserved.'
    Description       = 'Shared PowerShell helpers for AzureLocal platform scripts and CI'
    PowerShellVersion = '7.2'

    FunctionsToExport = @(
        'Get-AzureLocalRepoInventory'
        'Test-RepoConformance'
        'Write-AzureLocalLog'
        'Resolve-IICIdentity'
    )

    PrivateData = @{
        PSData = @{
            Tags        = @('AzureLocal', 'Platform', 'CI')
            ProjectUri  = 'https://github.com/AzureLocal/platform'
            LicenseUri  = 'https://github.com/AzureLocal/platform/blob/main/LICENSE'
        }
    }
}
