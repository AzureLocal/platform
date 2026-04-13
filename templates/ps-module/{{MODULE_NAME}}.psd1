@{
    RootModule        = '{{MODULE_NAME}}.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = '{{MODULE_GUID}}'
    Author            = 'AzureLocal'
    CompanyName       = 'AzureLocal'
    Copyright         = '(c) {{YEAR}} AzureLocal. All rights reserved.'
    Description       = '{{DESCRIPTION}}'
    PowerShellVersion = '7.2'

    FunctionsToExport = @()

    PrivateData = @{
        PSData = @{
            Tags        = @('AzureLocal')
            ProjectUri  = 'https://github.com/AzureLocal/{{REPO_NAME}}'
            LicenseUri  = 'https://github.com/AzureLocal/{{REPO_NAME}}/blob/main/LICENSE'
        }
    }
}
