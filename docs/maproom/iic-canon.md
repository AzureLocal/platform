---
title: IIC canon
---

# IIC canon

The **IIC (Infinite Improbability Corp)** canon is the fictional company dataset
used as canonical test data across all AzureLocal repos. Platform-managed IIC
fixtures live under `testing/iic-canon/` and are the authoritative reference
for contract tests.

## Why a shared fictional company?

Using a shared fictional company identity ensures that:

- All repos test against the same named nodes, cluster names, and IP ranges.
- No real customer data is ever committed to test fixtures.
- "Does this assertion target the IIC cluster?" is answerable by looking at one file.

## IIC identity reference

| Field | Value |
|-------|-------|
| Company | Infinite Improbability Corp |
| Abbreviation | IIC |
| AD domain | `iic.local` |
| NetBIOS | `IMPROBABLE` |
| Public domain | `improbability.cloud` |
| Subscription ID | `33333333-3333-3333-3333-333333333333` |
| Resource Group | `rg-iic-compute-01` |
| Tenant ID | `00000000-0000-0000-0000-000000000000` |

## Cluster — `iic-azure-local-01.json`

The canonical Azure Local cluster. Used by `azurelocal-s2d-cartographer` and
`azurelocal-ranger` contract tests.

| Property | Value |
|----------|-------|
| Cluster name | `azlocal-iic-s2d-01` |
| FQDN | `azlocal-iic-s2d-01.iic.local` |
| Nodes | 4 × `azl-iic-n01` — `azl-iic-n04` |
| Node IPs | `10.0.0.11` — `10.0.0.14` |
| Hardware | Dell PowerEdge R760 |
| Disks | 4 × 3.84 TB NVMe per node (all-NVMe, no separate cache tier) |
| Resiliency | 3-way mirror |
| Reserve status | Adequate |

## Canon naming convention

Fixtures follow the pattern `iic-<infrastructure-type-with-hyphens>-<NN>.json`:

| Fixture | Infrastructure type | Status |
|---------|-------------------|--------|
| `iic-azure-local-01.json` | `azure_local` | ✓ v0.2.0 |
| `iic-avd-azure-local-01.json` | `avd_azure_local` | v0.3.0 |
| `iic-sofs-azure-local-01.json` | `sofs_azure_local` | v0.3.0 |

## Accessing the canon in tests

```powershell
BeforeAll {
    Import-Module (Join-Path $env:PLATFORM_ROOT 'testing\maproom\AzureLocal.Maproom.psd1') -Force
    $canonPath = Get-IICCanonPath -InfrastructureType azure_local
    $script:fixture = Import-MaproomFixture -Path $canonPath
}

Describe 'Contract tests against IIC canon' {
    It 'has 4 nodes' {
        $script:fixture.nodeCount | Should -Be 4
    }
    It 'cluster name matches IIC standard' {
        $script:fixture.clusterName | Should -Be 'azlocal-iic-s2d-01'
    }
}
```

## Treating the canon as frozen

IIC canon fixtures are **frozen after publication** — treat them like a public API:

- Consumer tests pin to a specific canon file by name.
- Breaking changes to a canon require an ADR and a major-version bump.
- New scenarios get a new canon file (`iic-azure-local-02.json`), not edits to an existing one.

This freeze contract is what makes `Get-IICCanonPath -InfrastructureType azure_local` reliable.
