---
title: Framework architecture
---

# MAPROOM framework architecture

MAPROOM is the AzureLocal offline testing framework — it lets you assert that a
deployment matches an expected shape *without* needing a live cluster. Tests run
entirely from fixture JSON files using Pester 5.

## Platform layout

```text
platform/testing/
├── maproom/
│   ├── AzureLocal.Maproom.psd1   ← PS module manifest
│   ├── AzureLocal.Maproom.psm1   ← module source
│   └── schema/
│       └── fixture.schema.json   ← JSON Schema (draft-07) for all fixture files
├── iic-canon/
│   └── iic-azure-local-01.json   ← canonical IIC Azure Local cluster
└── trailhead/
    └── scripts/
        ├── TrailheadLog-Helpers.ps1
        └── Start-TrailheadRun.ps1
```

Each consumer repo keeps its own tests. The platform supplies the shared module,
schema, and canonical IIC fixture data.

```text
<consumer-repo>/tests/
└── maproom/
    ├── Fixtures/     ← per-repo fixture JSON files (must conform to platform schema)
    ├── unit/         ← Pester tests (InModuleScope <ConsumerModule>)
    └── scripts/      ← helper scripts (New-*SyntheticCluster, Test-*FromSyntheticManifest)
```

## Authority model

| Layer | Owner | What lives there |
|-------|-------|-----------------|
| Schema | platform | `fixture.schema.json` — every fixture must conform |
| IIC canon | platform | `iic-canon/iic-*.json` — canonical per-type fixtures |
| Framework module | platform | `AzureLocal.Maproom` — shared PS functions |
| Consumer fixtures | consumer repo | `tests/maproom/Fixtures/*.json` — per-repo test data |
| Consumer unit tests | consumer repo | `tests/maproom/unit/*.Tests.ps1` — Pester tests |

## Infrastructure type discriminator

Every fixture declares `infrastructure_type`. This selects which type-specific
property set applies and which IIC canon covers it.

| `infrastructure_type` | Describes | IIC canon |
|-----------------------|-----------|-----------|
| `azure_local` | S2D cluster fabric | `iic-azure-local-01.json` ✓ (v0.2.0) |
| `avd_azure_local` | AVD on Azure Local | v0.3.0 |
| `sofs_azure_local` | SOFS / FSLogix | v0.3.0 |
| `aks_azure_local` | AKS on Azure Local | v0.3.0 |
| `avd_azure` | AVD on Azure (cloud-only) | v0.3.0 |

## Reserved schema sections

Four top-level sections are reserved for deferred toolsets. They **must be present
as empty objects** (`{}`) in v0.2.0 fixtures and will be populated by deferred
toolsets in v0.3.0:

| Section | Reserved for | Ships in |
|---------|-------------|----------|
| `compliance` | COMPASS policy assertions | v0.3.0 |
| `performance` | PULSE load-profile expectations | v0.3.0 |
| `user_journey` | STORYBOARD scenario expectations | v0.3.0 |
| `iac` | BLUEPRINT pre-deploy template assertions | v0.3.0 |

## Module functions

### `Import-MaproomFixture -Path <path>`

Loads a fixture JSON file and returns a `PSCustomObject`. No schema validation.

```powershell
$fixture = Import-MaproomFixture -Path './tests/maproom/Fixtures/my-cluster.json'
```

### `Test-MaproomFixture -Path <path>`

Loads and validates a fixture — checks `infrastructure_type`, `_metadata`, and that
reserved sections are empty. Throws on validation failure.

```powershell
$fixture = Test-MaproomFixture -Path './tests/maproom/Fixtures/my-cluster.json'
```

### `Get-IICCanonPath -InfrastructureType <type>`

Returns the platform-managed path to the canonical IIC fixture for the given type.

```powershell
$path    = Get-IICCanonPath -InfrastructureType azure_local
$fixture = Import-MaproomFixture -Path $path
```

## Referencing the platform module in CI

In v0.2.0, consumers reference the platform module via git checkout:

```yaml
- name: Checkout platform repo
  uses: actions/checkout@v4
  with:
    repository: AzureLocal/platform
    path: _platform
    ref: main

- name: Import AzureLocal.Maproom
  shell: pwsh
  run: Import-Module .\_platform\testing\maproom\AzureLocal.Maproom.psd1 -Force
```

PSGallery publication is deferred until the module surface stabilizes (v1.0.0 target).
