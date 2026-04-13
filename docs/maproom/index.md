---
title: MAPROOM
---

# MAPROOM

MAPROOM is the AzureLocal offline, fixture-based testing framework. It lets a repo assert that a cluster or workload matches an expected shape encoded as a JSON fixture — without needing a live cluster in the loop.

## Start here

| Read | When |
|---|---|
| [Overview](overview.md) | What problem MAPROOM solves; when to use it vs live cluster testing |
| [Framework architecture](framework-architecture.md) | How the PowerShell module, schema, and fixtures fit together |
| [IIC canon](iic-canon.md) | The canonical synthetic identity used across repos |
| [Authoring fixtures](authoring-fixtures.md) | How to write a fixture for a new consumer |
| [Writing unit tests](writing-unit-tests.md) | Pester patterns that consume MAPROOM |
| [Integration model](integration-model.md) | Calling MAPROOM from consumer workflows and Pester suites |
| [Extending the framework](extending-the-framework.md) | Adding an `infrastructure_type`, canon file, or primitive |
| [Troubleshooting](troubleshooting.md) | Common failure modes |

## Key facts

- **Module**: `AzureLocal.Maproom` v0.2.0 at `testing/maproom/`
- **Functions**: `Import-MaproomFixture`, `Get-IICCanonPath`, `Test-MaproomFixture`
- **Schema**: `testing/maproom/schema/fixture.schema.json` — type-discriminated by `infrastructure_type`
- **Canon**: `testing/iic-canon/iic-azure-local-01.json` (v0.2.0; more variants in v0.3.0 — see ADR-0004)
- **Current consumers**: `azurelocal-s2d-cartographer`, `azurelocal-ranger`
- **Reusable workflow**: [`reusable-maproom-run.yml`](../reusable-workflows/maproom-run.md)

## Relationship to TRAILHEAD

- **MAPROOM** — offline, fixture-based, run in CI, asserts expected shape.
- **TRAILHEAD** — live-cluster cycles, captured evidence, run out-of-band.

MAPROOM and TRAILHEAD are complementary. Most repos use both.
