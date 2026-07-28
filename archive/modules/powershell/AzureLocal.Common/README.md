# AzureLocal.Common

Shared PowerShell helpers used by platform scripts, product repo CI, and (eventually) product code.

## Status

Module implementation scheduled for Phase 2 alongside `AzureLocal.Maproom`. This README is a placeholder describing intended public surface.

## Intended public surface

| Function | Purpose |
|---|---|
| `Get-AzureLocalRepoInventory` | Lists every active repo in the AzureLocal org with metadata (type, platform version, last audited) |
| `Test-RepoConformance` | Validates a repo's structure and files against canonical standards |
| `Write-AzureLocalLog` | Consistent, timestamped, colored log output for all org scripts |
| `Resolve-IICIdentity` | Helper to load IIC canonical identity data from `../../../testing/iic-canon/` |

## Consumer pattern

```powershell
Import-Module ./modules/powershell/AzureLocal.Common/AzureLocal.Common.psd1

Get-AzureLocalRepoInventory | Where-Object { $_.PlatformVersion -lt 1 }
```

## Distribution

Git-sourced for v1 (consumers clone platform or reference by path). PSGallery publishing deferred — will reassess after Phase 2.

## Documentation

See [`../../../docs/modules/AzureLocal.Common.md`](../../../docs/modules/AzureLocal.Common.md).
