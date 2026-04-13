---
title: reusable-maproom-run
---

# reusable-maproom-run

Runs standalone MAPROOM fixture validation against the platform schema. This is a single `maproom` job (on `windows-latest`) that checks out both the consumer repo and the platform repo, imports `AzureLocal.Maproom`, and runs `Test-MaproomFixture` against every `*.json` file in the configured fixture directory.

```text
checkout consumer repo
checkout AzureLocal/platform → _platform/
Import-Module _platform/testing/maproom/AzureLocal.Maproom.psd1
Test-MaproomFixture for each *.json in fixture-path
  (excluding synthetic-cluster.json by default)
```

The job fails if any fixture does not pass schema validation.

## Inputs

| Input | Type | Default | Description |
|---|---|---|---|
| `fixture-path` | string | `tests/maproom/Fixtures` | Path to fixture JSON files, relative to the consumer repo root |
| `exclude-synthetic` | boolean | `true` | Exclude `synthetic-cluster.json` from validation |
| `platform-ref` | string | `main` | Ref (branch, tag, or SHA) of the platform repo to check out |

## Caller example

```yaml
name: MAPROOM Fixtures

on:
  push:
    branches: [main]
    paths: ['tests/maproom/**']
  schedule:
    - cron: '0 6 * * 1'   # weekly Monday 06:00 UTC
  workflow_dispatch:

permissions:
  contents: read

jobs:
  fixtures:
    uses: AzureLocal/platform/.github/workflows/reusable-maproom-run.yml@main
    with:
      fixture-path: tests/maproom/Fixtures
```

## When to use this workflow vs the maproom job in ps-module-ci

| Scenario | Use |
|---|---|
| MAPROOM validation is part of every PR build alongside lint and unit tests | `validate-maproom: true` in [`reusable-ps-module-ci`](ps-module-ci.md) |
| MAPROOM validation runs on its own schedule or trigger (e.g. weekly, or only on fixture file changes) | This workflow (`reusable-maproom-run`) |
| You want to pin fixture validation to a specific platform schema version during a migration | This workflow, with `platform-ref` set to a tag or SHA |

!!! tip "Pinning the platform ref"
    During a platform schema migration, set `platform-ref` to the previous release tag
    (e.g. `v0.0.1`) to keep fixture validation passing while you update your fixtures to
    the new schema. Switch back to `main` once all fixtures are updated.
