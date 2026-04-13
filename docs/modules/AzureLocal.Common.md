---
title: AzureLocal.Common
---

# AzureLocal.Common

`AzureLocal.Common` is the shared PowerShell module used by platform org-scripts, CI
pipelines, and product-repo automation. It provides the foundational helpers that all
other platform scripts depend on.

**Module version:** 0.2.0
**Location:** `modules/powershell/AzureLocal.Common/`
**Distribution:** Git-sourced. Import from a local platform clone or via the CI checkout pattern.

## Importing

```powershell
Import-Module ./modules/powershell/AzureLocal.Common/AzureLocal.Common.psd1 -Force
```

In CI (platform workflow):

```yaml
- shell: pwsh
  run: |
    Import-Module ./modules/powershell/AzureLocal.Common/AzureLocal.Common.psd1 -Force
```

## Functions

### `Write-AzureLocalLog`

Consistent, timestamped, colored log output for all AzureLocal org scripts.

```powershell
Write-AzureLocalLog -Level PASS -Message "Sync complete"
Write-AzureLocalLog -Level FAIL -Message "Repo missing CHANGELOG.md"
Write-AzureLocalLog -Level WARN -Message "deploy-docs.yml doesn't call platform workflow"
```

**Levels:** `INFO` (default), `PASS`, `FAIL`, `WARN`, `SKIP`

---

### `Get-AzureLocalRepoInventory`

Lists every non-archived repository in the AzureLocal GitHub org with platform metadata.
Reads each repo's `.azurelocal-platform.yml` to populate `PlatformVersion`, `RepoType`,
and `LastAudited`.

```powershell
$inventory = Get-AzureLocalRepoInventory -Org AzureLocal
$inventory | Where-Object { -not $_.PlatformYmlPresent }
```

**Returns:** `PSCustomObject[]` with properties: `Name`, `Description`, `Visibility`,
`HtmlUrl`, `UpdatedAt`, `PlatformYmlPresent`, `PlatformVersion`, `RepoType`, `LastAudited`

**Requires:** `gh` CLI authenticated.

---

### `Test-RepoConformance`

Validates a single repository against the required-file standard. Checks that all
canonical required files exist and that `deploy-docs.yml` references the platform
reusable workflow.

```powershell
$result = Test-RepoConformance -Org AzureLocal -RepoName azurelocal-ranger
if (-not $result.Passed) {
    $result.DriftItems | ForEach-Object { Write-Host "DRIFT: $_" }
}
```

**Returns:** `PSCustomObject` with `Repo`, `Passed`, `DriftCount`, `DriftItems`

---

### `Resolve-IICIdentity`

Returns the IIC canonical identity fixture as a `PSCustomObject`. Used by platform
scripts that need to reference the standard test data (cluster name, node names,
subscription ID, etc.).

```powershell
$iic = Resolve-IICIdentity
Write-Host "IIC cluster: $($iic.clusterName)"    # azlocal-iic-s2d-01
Write-Host "IIC nodes  : $($iic.nodeCount)"       # 4
```

## Required files (canonical list)

The following files are required in every AzureLocal consumer repo. `Test-RepoConformance`
checks for their presence:

| File | Purpose |
|------|---------|
| `CHANGELOG.md` | Release history |
| `mkdocs.yml` | Documentation site config |
| `.github/workflows/deploy-docs.yml` | Docs deployment |
| `.github/workflows/drift-check.yml` | Weekly drift self-check |
| `.azurelocal-platform.yml` | Platform metadata descriptor |
