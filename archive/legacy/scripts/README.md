# Platform Scripts

Automation that operates on `platform` itself. Scripts that operate on every repo in the AzureLocal org live in [`../repo-management/org-scripts/`](../repo-management/org-scripts).

## Files

| Script | Purpose |
|---|---|
| `Build-PlatformSite.ps1` | Wraps `mkdocs build` with platform defaults; used by CI |
| `Test-PlatformStructure.ps1` | Validates this repo against its own rules (used by `platform-ci.yml`) |
| `Update-StandardsIndex.ps1` | Regenerates navigation / TOCs after standards edits |

## Running locally

```powershell
./scripts/Test-PlatformStructure.ps1
./scripts/Build-PlatformSite.ps1 -OutputDir ./site
```
