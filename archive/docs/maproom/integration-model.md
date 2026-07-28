---
title: MAPROOM integration model
---

# MAPROOM integration model

Three integration patterns exist for a consumer repo. Pick the one that matches how your test suite is structured.

## Pattern A — Pester consumes MAPROOM directly

The most common pattern. Your Pester suite imports `AzureLocal.Maproom` and uses `Import-MaproomFixture` + `Get-IICCanonPath` inline.

Used by: `azurelocal-s2d-cartographer`, `azurelocal-ranger`.

```powershell
# tests/maproom/unit/cluster.Tests.ps1
BeforeAll {
    Import-Module (Join-Path $env:PLATFORM_ROOT 'testing\maproom\AzureLocal.Maproom.psd1') -Force

    $canonPath    = Get-IICCanonPath -InfrastructureType azure_local
    $script:canon = Import-MaproomFixture -Path $canonPath
}

Describe 'Canon invariants' {
    It 'has 4 nodes' { $script:canon.nodeCount | Should -Be 4 }
}
```

CI side: the [`reusable-ps-module-ci.yml`](../reusable-workflows/ps-module-ci.md) workflow handles platform checkout when `validate-maproom: true`:

```yaml
jobs:
  ci:
    uses: AzureLocal/platform/.github/workflows/reusable-ps-module-ci.yml@main
    with:
      module-manifest: ./src/MyModule.psd1
      validate-maproom: true
      maproom-fixture-path: ./tests/maproom/fixtures
```

## Pattern B — Dedicated MAPROOM job via `reusable-maproom-run`

When MAPROOM assertions are heavy and you want them as a separate CI job. Used when the primary CI job is about TypeScript or IaC, not PowerShell.

```yaml
jobs:
  maproom:
    uses: AzureLocal/platform/.github/workflows/reusable-maproom-run.yml@main
    with:
      fixture-path: tests/maproom/Fixtures
      exclude-synthetic: true
```

The reusable workflow checks out both consumer and platform, then loops `Test-MaproomFixture` over every fixture.

## Pattern C — Schema validation only (no assertions)

Minimal adoption. The consumer produces fixtures but does not write assertions — platform validates the fixtures against `fixture.schema.json` at PR time, and the consumer writes its own assertions later.

```yaml
- name: Validate fixtures against MAPROOM schema
  shell: pwsh
  run: |
    Import-Module ./testing/maproom/AzureLocal.Maproom.psd1 -Force
    Get-ChildItem tests/maproom/fixtures/*.json -Recurse |
      ForEach-Object { Test-MaproomFixture -Path $_.FullName }
```

Pattern C is the right starting point for a repo that doesn't yet have unit tests. Once Pester lands, upgrade to Pattern A.

## Consumer fixture locations

Regardless of pattern, fixtures live in the **consumer** repo at:

```text
tests/maproom/
├── fixtures/
│   └── *.json          ← consumer-authored fixtures
└── unit/
    └── *.Tests.ps1     ← consumer Pester tests
```

Canonical IIC fixtures live in the **platform** repo at `testing/iic-canon/`. Consumers reference them via `Get-IICCanonPath -InfrastructureType <value>`.

## Importing the canon from a consumer

```powershell
$canonPath = Get-IICCanonPath -InfrastructureType azure_local
$canon     = Import-MaproomFixture -Path $canonPath
```

`Get-IICCanonPath` resolves the path via the `PLATFORM_ROOT` environment variable (set by the reusable workflow) or a local platform clone (for dev). Never hardcode canon paths.

## Fixture naming

```text
<consumer-scope>-<scenario>.json
```

Examples:

- `cluster-3node-allnvme.json`
- `cluster-under-test.json`
- `storage-spaces-expected.json`

Consumer fixtures are *not* named with the `iic-` prefix — that prefix is reserved for platform-owned canon.

## Drift between canon and consumer fixtures

This is intentional and common. Consumer fixtures represent the *actual* environment under test; the canon represents the *idealised* reference. A test that asserts `canon.nodeCount -eq under.nodeCount` is exactly the contract: "the thing under test matches the canon." When the canon bumps (`iic-azure-local-01.json` → `...-02.json`), the consumer chooses when to re-point.
