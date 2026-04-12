# AzureLocal Platform

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Docs](https://img.shields.io/badge/docs-mkdocs--material-0078D4)](https://AzureLocal.github.io/platform/)

> Centralized standards, reusable workflows, test frameworks, and scaffolding for the AzureLocal organization.

## What this is

`AzureLocal/platform` is the single home for everything that's shared across the ~28 repos in the [AzureLocal](https://github.com/AzureLocal) GitHub organization. Product repos contain only product-specific code and reference this repo for standards, testing frameworks, CI primitives, and scaffolding.

Companion repo: [`AzureLocal/.github`](https://github.com/AzureLocal/.github) owns GitHub-metadata governance (community health files, org-level reusable workflows). `platform` owns developer tooling.

## Contents

| Folder | Purpose |
|---|---|
| [`standards/`](./standards) | Canonical standards documents (single source of truth) |
| [`repo-management/`](./repo-management) | Templates for per-repo `/repo-management` folders + org-wide automation scripts |
| [`testing/maproom/`](./testing/maproom) | Offline fixture-based testing framework (classes, generators, harness, schema) |
| [`testing/trailhead/`](./testing/trailhead) | Live-cluster validation templates and scripts |
| [`testing/iic-canon/`](./testing/iic-canon) | Canonical IIC identity data (the one copy) |
| [`templates/`](./templates) | Starter skeletons for new repos (5 variants: ps-module, ts-web-app, iac-solution, migration-runbook, training-site) |
| [`scripts/`](./scripts) | Platform's own automation (build, test, release) |
| [`modules/powershell/`](./modules/powershell) | Shared PowerShell helpers (`AzureLocal.Common`) |
| [`docs/`](./docs) | Full MkDocs Material site source |
| [`decisions/`](./decisions) | Architectural Decision Records (ADRs) |

## How product repos consume this

Every product repo carries three breadcrumbs pointing here:

1. A README badge linking to this repo
2. A `STANDARDS.md` stub at repo root linking to [`platform/standards`](./standards)
3. A `.azurelocal-platform.yml` metadata file declaring the repo type and which platform features it adopts

Reusable workflows are referenced by tag:

```yaml
jobs:
  ci:
    uses: AzureLocal/platform/.github/workflows/reusable-ps-module-ci.yml@v1
```

See [`docs/reusable-workflows/consumer-patterns.md`](./docs/reusable-workflows/consumer-patterns.md) for copy-paste examples per repo type.

## Documentation

Full docs site: **https://AzureLocal.github.io/platform/**

Quick links:

- [Getting started](./docs/getting-started/what-is-platform.md)
- [Onboarding an existing repo](./docs/onboarding/adopt-from-existing-repo.md)
- [Creating a new repo](./docs/onboarding/create-new-repo.md)
- [Consuming reusable workflows](./docs/reusable-workflows/consumer-patterns.md)
- [MAPROOM overview](./docs/maproom/overview.md)
- [TRAILHEAD overview](./docs/trailhead/overview.md)
- [Architecture overview](./docs/getting-started/architecture-overview.md)

## License

MIT — see [LICENSE](./LICENSE).
