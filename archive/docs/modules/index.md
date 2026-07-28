---
title: Modules
---

# Modules

`AzureLocal/platform` ships two PowerShell modules consumed by org-scripts, reusable workflows, and product-repo test suites.

## Published modules

| Module | Version | Location | Purpose |
|---|---|---|---|
| [AzureLocal.Common](AzureLocal.Common.md) | 0.2.0 | `modules/powershell/AzureLocal.Common/` | Shared helpers: logging, repo inventory, conformance checks, IIC identity |
| [AzureLocal.Maproom](../maproom/framework-architecture.md) | 0.2.0 | `testing/maproom/` | Fixture-based testing framework — fixture loading, schema validation, canon path resolution |

## Distribution

Modules are **git-sourced** — imported from a local clone or via the reusable-workflow checkout pattern. PSGallery publication is deferred until platform hits v1.0.0.

Import pattern in CI (handled automatically by `reusable-ps-module-ci.yml` and `reusable-maproom-run.yml`):

```powershell
Import-Module "$env:PLATFORM_ROOT/modules/powershell/AzureLocal.Common/AzureLocal.Common.psd1" -Force
Import-Module "$env:PLATFORM_ROOT/testing/maproom/AzureLocal.Maproom.psd1" -Force
```

Local dev import:

```powershell
Import-Module ./modules/powershell/AzureLocal.Common/AzureLocal.Common.psd1 -Force
Import-Module ./testing/maproom/AzureLocal.Maproom.psd1 -Force
```

## Version policy

Modules follow the platform version (same SemVer, same tag). Breaking changes to exported functions require a major bump. See [governance/breaking-changes](../governance/breaking-changes.md).

## Planned modules

| Module | Target version | ADR |
|---|---|---|
| `AzureLocal.Compass` (COMPASS — compliance/policy assertions) | v0.3.0 | [ADR-0004](https://github.com/AzureLocal/platform/blob/main/decisions/0004-testing-toolset-classification.md) |
| `AzureLocal.Ledger` (LEDGER — migration inventory diff) | v0.3.0 | [ADR-0004](https://github.com/AzureLocal/platform/blob/main/decisions/0004-testing-toolset-classification.md) |
| `AzureLocal.Pulse` (PULSE — synthetic workload harness) | v0.3.0 | [ADR-0004](https://github.com/AzureLocal/platform/blob/main/decisions/0004-testing-toolset-classification.md) |
| `AzureLocal.Muster` (MUSTER — repo conformance engine) | v0.3.0+ | [ADR-0004](https://github.com/AzureLocal/platform/blob/main/decisions/0004-testing-toolset-classification.md) |

MUSTER is effectively implemented today inside `AzureLocal.Common` via `Test-RepoConformance` — it's extracted as a standalone module when its surface stabilises.

## Contributing a new module

1. ADR required.
2. Module directory under `modules/powershell/<ModuleName>/`.
3. Manifest (`.psd1`) with `ModuleVersion`, `FunctionsToExport`, `PowerShellVersion = '7.2'`.
4. Public functions under `Public/*.ps1`; private helpers under `Private/*.ps1`.
5. Pester tests under `modules/powershell/<ModuleName>/tests/`.
6. Documentation page under `docs/modules/<ModuleName>.md` and add to `mkdocs.yml` nav.
