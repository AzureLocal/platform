# MAPROOM

Offline, fixture-based testing framework for AzureLocal repos.

## Structure

```text
maproom/
├── framework/      — AzureLocal.Maproom PS module: classes, Public, Private
├── generators/     — IIC-compliant synthetic data generators
├── schema/         — JSON Schemas for fixtures and IIC canon
├── harness/        — shared test runner and contract assertions
└── docs/           — authoring fixtures, writing tests, integration model
```

## Consumer pattern

A product repo imports the framework and writes its own fixtures:

```powershell
using module ../../platform/testing/maproom/framework/AzureLocal.Maproom.psd1

Describe 'Product X handles cluster Y' {
    $fixture = Get-Content tests/maproom/Fixtures/three-node-all-nvme.json | ConvertFrom-Json
    $result  = Invoke-ProductXAnalyzer -FixtureData $fixture
    $result.Status | Should -Be 'Pass'
}
```

Product repos keep their own `tests/maproom/Fixtures/*.json` — those are product-specific. Shared code (classes, generators, harness) lives here.

## Status

Framework implementation scheduled for Phase 2 of the platform rollout. Until then, see [`azurelocal-S2DCartographer/tests/maproom/`](https://github.com/AzureLocal/azurelocal-S2DCartographer/tree/main/tests/maproom) for the canonical reference implementation being ported.

## Documentation

- [Overview](../../docs/maproom/overview.md)
- [Framework architecture](../../docs/maproom/framework-architecture.md)
- [Authoring fixtures](../../docs/maproom/authoring-fixtures.md)
- [Writing unit tests](../../docs/maproom/writing-unit-tests.md)
- [IIC canon](../../docs/maproom/iic-canon.md)
