---
title: "Template: ps-module"
---

# Template: ps-module

Scaffold for a PowerShell module that exports cmdlets or functions. Used by `azurelocal-ranger`, `azurelocal-s2d-cartographer`, `azurelocal-toolkit`, `azurelocal-vm-conversion-toolkit`.

## When to pick this variant

- The repo's primary output is a `.psd1` + `.psm1` module.
- Consumers are other PS scripts, runbooks, or CI pipelines.
- PSScriptAnalyzer + Pester are the expected test tools.

## What's in the template

```text
templates/ps-module/
├── .github/workflows/
│   ├── deploy-docs.yml           # Calls reusable-mkdocs-deploy.yml
│   ├── validate.yml              # Calls reusable-ps-module-ci.yml
│   └── publish-psgallery.yml     # Publishes to PSGallery on tag (optional)
├── {{MODULE_NAME}}.psd1          # Manifest, token-substituted
├── {{MODULE_NAME}}.psm1          # Module code, token-substituted
├── mkdocs.yml                    # Docs site config
└── README.md                     # Token-substituted
```

Filename token `{{MODULE_NAME}}` is replaced at scaffold time — e.g., `azurelocal-foo` → `AzureLocalFoo.psd1`.

## `.psd1` manifest defaults

```powershell
@{
    RootModule           = '{{MODULE_NAME}}.psm1'
    ModuleVersion        = '0.1.0'
    CompatiblePSEditions = @('Core')
    GUID                 = '{{MODULE_GUID}}'
    Author               = 'Azure Local'
    CompanyName          = 'AzureLocal'
    Copyright            = '(c) {{YEAR}} Azure Local. MIT License.'
    Description          = '{{DESCRIPTION}}'
    PowerShellVersion    = '7.2'
    FunctionsToExport    = @()       # ← fill in after authoring
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()
    PrivateData          = @{
        PSData = @{
            Tags       = @('AzureLocal')
            ProjectUri = 'https://github.com/AzureLocal/{{REPO_NAME}}'
            LicenseUri = 'https://github.com/AzureLocal/{{REPO_NAME}}/blob/main/LICENSE'
        }
    }
}
```

## CI caller — `validate.yml`

```yaml
name: Validate

on:
  pull_request: {}
  push:
    branches: [main]

jobs:
  ci:
    uses: AzureLocal/platform/.github/workflows/reusable-ps-module-ci.yml@main
    with:
      module-manifest: ./{{MODULE_NAME}}.psd1
      run-psscriptanalyzer: true
      psscriptanalyzer-path: .
      run-pester: true
      pester-test-path: tests
      pester-result-format: NUnitXml
      validate-maproom: false           # flip to true if MAPROOM consumer
      maproom-fixture-path: tests/maproom/fixtures
```

## Docs — `mkdocs.yml`

Includes `navigation.tabs`, Material theme, GitHub edit icon, code-copy buttons.

## PSGallery publish

`publish-psgallery.yml` triggers on tag push and requires `NUGET_API_KEY` repo secret. Ships empty — authoring the `Publish-Module` call is a one-time per-repo step.

## Tokens used in this variant

| Token | Usage |
|---|---|
| `{{REPO_NAME}}` | `mkdocs.yml`, `README.md`, `.psd1` ProjectUri/LicenseUri |
| `{{MODULE_NAME}}` | Filenames and in-file references |
| `{{DESCRIPTION}}` | Manifest `Description`, README, mkdocs site description |
| `{{YEAR}}` | Copyright lines |
| `{{MODULE_GUID}}` | Manifest `GUID` |
| `{{AUDIT_DATE}}` | `.azurelocal-platform.yml` `lastAudited` |

## Post-scaffold steps

1. Add actual source to `{{MODULE_NAME}}.psm1` or split into `Public/`, `Private/`, `Classes/` subfolders.
2. Populate `FunctionsToExport` in the manifest.
3. Add Pester tests under `tests/`.
4. If publishing to PSGallery: set `NUGET_API_KEY` secret.
5. Author `docs/index.md` (mkdocs will fail without one).

## Example consumers

- [`azurelocal-ranger`](https://github.com/AzureLocal/azurelocal-ranger) — reference implementation
- [`azurelocal-s2d-cartographer`](https://github.com/AzureLocal/azurelocal-s2d-cartographer) — also consumes MAPROOM
- [`azurelocal-vm-conversion-toolkit`](https://github.com/AzureLocal/azurelocal-vm-conversion-toolkit)

## Related

- [Reusable workflow: ps-module-ci](../reusable-workflows/ps-module-ci.md)
- [MAPROOM overview](../maproom/overview.md) — if the module produces cluster-shaped output
