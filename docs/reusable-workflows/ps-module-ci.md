---
title: reusable-ps-module-ci
---

# reusable-ps-module-ci

Provides a three-job CI pipeline for PowerShell modules. Each job is independently gated by a boolean input, so repos can enable only the checks relevant to them. All jobs run on `windows-latest`.

## Jobs

### `psscriptanalyzer` (`run-psscriptanalyzer`)

Installs PSScriptAnalyzer from the PSGallery and runs it with `-Severity Warning,Error` against the paths specified by `psscriptanalyzer-path`. The job fails if any `Error`-severity finding is present; `Warning`-severity findings are printed but do not block the run.

### `pester-unit` (`run-pester`)

1. Validates the module manifest with `Test-ModuleManifest`.
2. Imports the module.
3. Runs Pester 5 tests from `pester-test-path`, writing results to `TestResults\pester-results.xml` in the configured format.
4. Uploads the results XML as the `pester-results` artifact (always, even on failure).

The job fails if `result.FailedCount` is greater than zero.

### `maproom` (`validate-maproom`)

Checks out the platform repo alongside the consumer repo and imports `AzureLocal.Maproom`. Runs `Test-MaproomFixture` against every `*.json` file in `maproom-fixture-path`, skipping `synthetic-cluster.json` by default. The job fails if any fixture does not pass platform schema validation.

## Inputs

| Input | Type | Default | Description |
|---|---|---|---|
| `module-manifest` | string | **required** | Path to the `.psd1` module manifest, relative to the repo root |
| `run-psscriptanalyzer` | boolean | `true` | Enable the PSScriptAnalyzer lint job |
| `psscriptanalyzer-path` | string | `src` | Path(s) to analyse — space-separate multiple paths |
| `run-pester` | boolean | `true` | Enable the Pester unit test job |
| `pester-test-path` | string | `tests` | Path to Pester test files |
| `pester-result-format` | string | `NUnitXml` | Pester result output format (`NUnitXml` or `JUnitXml`) |
| `validate-maproom` | boolean | `false` | Enable MAPROOM fixture validation |
| `maproom-fixture-path` | string | `tests/maproom/Fixtures` | Path to fixture JSON files |

## Caller examples

### Ranger — lint only, no Pester, no MAPROOM

```yaml
name: Module CI

on: [pull_request]

permissions:
  contents: read

jobs:
  ci:
    uses: AzureLocal/platform/.github/workflows/reusable-ps-module-ci.yml@main
    with:
      module-manifest: src/AzureLocal.Ranger/AzureLocal.Ranger.psd1
      run-pester: false
      validate-maproom: false
```

### S2D Cartographer — lint + Pester + MAPROOM

```yaml
name: Module CI

on: [pull_request]

permissions:
  contents: read

jobs:
  ci:
    uses: AzureLocal/platform/.github/workflows/reusable-ps-module-ci.yml@main
    with:
      module-manifest: src/AzureLocal.S2DCartographer/AzureLocal.S2DCartographer.psd1
      psscriptanalyzer-path: src tests
      pester-test-path: tests/unit
      validate-maproom: true
      maproom-fixture-path: tests/maproom/Fixtures
```

!!! tip "MAPROOM vs standalone maproom-run"
    The `maproom` job embedded here is suitable when fixture validation is part of the
    same CI run as the module build. Use [`reusable-maproom-run`](maproom-run.md) as a
    standalone workflow when you want MAPROOM validation to run on its own schedule or
    trigger independently of module CI.
