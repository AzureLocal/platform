---
title: MAPROOM overview
---

# MAPROOM overview

## The problem MAPROOM solves

Before MAPROOM existed, every repo that produced a cluster, host pool, or workload fleet tested its output by either:

1. Standing up a live environment (slow, expensive, blocks CI), or
2. Writing ad-hoc Pester assertions against hand-rolled JSON dumps, fork-by-fork.

The second approach drifted. Two repos that both "validate an Azure Local cluster" ended up with incompatible assertion shapes, and the assertions themselves were undocumented.

MAPROOM replaces both:

- **Fixtures are offline** — JSON files committed to the repo; no live dependency.
- **Fixtures are contract-validated** — every fixture must pass `fixture.schema.json` at PR time.
- **Fixtures are type-discriminated** — `infrastructure_type` gates which property set applies.
- **Contract tests are Pester-native** — consumers load a fixture and write normal Pester `Should` assertions against it.

## What a MAPROOM test looks like

```powershell
BeforeAll {
    Import-Module (Join-Path $env:PLATFORM_ROOT 'testing\maproom\AzureLocal.Maproom.psd1') -Force

    $canonPath     = Get-IICCanonPath -InfrastructureType azure_local
    $script:canon  = Import-MaproomFixture -Path $canonPath
    $script:under  = Import-MaproomFixture -Path "./tests/maproom/fixtures/cluster-under-test.json"
}

Describe 'cluster-under-test conforms to IIC canon' {
    It 'has the same node count as canon' {
        $script:under.nodeCount | Should -Be $script:canon.nodeCount
    }
    It 'uses 3-way mirror resiliency matching canon' {
        $script:under.resiliency | Should -Be $script:canon.resiliency
    }
}
```

## When to use MAPROOM vs TRAILHEAD

| If you're testing... | Use |
|---|---|
| Expected output shape of an IaC template or planning tool | MAPROOM |
| Output of a module that generates cluster specs | MAPROOM |
| Live cluster behaviour under load | TRAILHEAD |
| User journey on an AVD host pool | TRAILHEAD (or STORYBOARD when it ships) |
| Compliance / policy posture against a live tenant | COMPASS (v0.3.0) |

## When NOT to use MAPROOM

- Repos that don't produce or consume cluster/fleet shapes (e.g., `azurelocal-training`). MAPROOM adds cost without value.
- Purely functional unit tests with no infrastructure domain (use plain Pester).
- Runtime assertions against a real cluster (use TRAILHEAD — fixtures are static).

## Scope boundaries

MAPROOM is classified per [ADR-0004](https://github.com/AzureLocal/platform/blob/main/decisions/0004-testing-toolset-classification.md):

| Axis | Value |
|---|---|
| Scope | `infra-fabric` |
| Target | `cluster` |
| Authority | `canonical` |
| Lifecycle | `post-deploy` · `drift-audit` |

Canonical authority means: platform owns the schema, the primitives, and the IIC canon fixtures. Consumers supply their own domain fixtures but must validate against the same schema.

## Reserved schema sections

`fixture.schema.json` reserves (empty in v0.2.0) four top-level sections so deferred toolsets do not force a breaking change later:

- `compliance` — COMPASS (v0.3.0)
- `performance` — PULSE (v0.3.0)
- `user_journey` — STORYBOARD (v0.3.0)
- `iac` — BLUEPRINT (v0.3.0)

## Next steps

- [Framework architecture](framework-architecture.md) — how it's built
- [IIC canon](iic-canon.md) — the canonical test data
- [Authoring fixtures](authoring-fixtures.md) — write your first fixture
