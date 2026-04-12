---
title: Consumer patterns
---

# Reusable workflow consumer patterns

Copy-paste reference for every AzureLocal reusable workflow. One snippet per workflow. Drop into `.github/workflows/<name>.yml` in your product repo.

Every snippet pins `@v1` (major). Never pin `@main` — drift audit will fail your repo.

## Governance workflows (from `.github`)

### `reusable-add-to-project` — add PR/issue to org project board

```yaml
name: Add to project

on:
  issues:
    types: [opened]
  pull_request:
    types: [opened]

jobs:
  add-to-project:
    uses: AzureLocal/.github/.github/workflows/reusable-add-to-project.yml@v1
    with:
      id-prefix: my-repo              # unique string per consumer
      solution-option-id: SOME_GUID   # from org project metadata
```

### `reusable-release-please` — release automation

```yaml
name: Release please

on:
  push:
    branches: [main]

permissions:
  contents: write
  pull-requests: write

jobs:
  release-please:
    uses: AzureLocal/.github/.github/workflows/reusable-release-please.yml@v1
```

### `reusable-validate-structure` — required-file check

```yaml
name: Validate repo structure

on:
  pull_request:
  push:
    branches: [main]

jobs:
  validate:
    uses: AzureLocal/.github/.github/workflows/reusable-validate-structure.yml@v1
```

## Stack-specific workflows (from `platform`)

### `reusable-ps-module-ci` — PowerShell module

Runs Pester + PSScriptAnalyzer. Optionally publishes to PSGallery on release.

```yaml
name: CI

on:
  pull_request:
  push:
    branches: [main]
  release:
    types: [published]

jobs:
  ci:
    uses: AzureLocal/platform/.github/workflows/reusable-ps-module-ci.yml@v1
    with:
      module-path: Modules/MyModule
      module-manifest: Modules/MyModule/MyModule.psd1
      test-path: tests/maproom/unit
      publish-to-gallery: ${{ github.event_name == 'release' }}
    secrets:
      psgallery-api-key: ${{ secrets.PSGALLERY_API_KEY }}
```

### `reusable-ts-web-ci` — TypeScript web app

Runs lint, typecheck, vitest, build.

```yaml
name: CI

on:
  pull_request:
  push:
    branches: [main]

jobs:
  ci:
    uses: AzureLocal/platform/.github/workflows/reusable-ts-web-ci.yml@v1
    with:
      node-version: '20'
      package-manager: npm             # npm | pnpm | yarn
      build-output-dir: dist
```

### `reusable-iac-validate` — Infrastructure-as-code

Validates Bicep, Terraform, and ARM templates.

```yaml
name: Validate IaC

on:
  pull_request:
    paths:
      - 'bicep/**'
      - 'terraform/**'
      - 'arm/**'
  push:
    branches: [main]

jobs:
  validate:
    uses: AzureLocal/platform/.github/workflows/reusable-iac-validate.yml@v1
    with:
      bicep-path: bicep
      terraform-path: terraform
      arm-path: arm
```

### `reusable-mkdocs-deploy` — MkDocs Material site

Builds MkDocs and deploys to GitHub Pages (`gh-pages` branch).

```yaml
name: Deploy docs

on:
  push:
    branches: [main]
    paths:
      - 'docs/**'
      - 'mkdocs.yml'
      - 'requirements-docs.txt'
  workflow_dispatch:

permissions:
  contents: write

jobs:
  deploy:
    uses: AzureLocal/platform/.github/workflows/reusable-mkdocs-deploy.yml@v1
    with:
      python-version: '3.12'
      requirements-file: requirements-docs.txt
```

### `reusable-maproom-run` — MAPROOM test harness

Invokes the MAPROOM runner against the calling repo's `tests/maproom/` fixtures and unit tests.

```yaml
name: MAPROOM

on:
  pull_request:
  push:
    branches: [main]

jobs:
  maproom:
    uses: AzureLocal/platform/.github/workflows/reusable-maproom-run.yml@v1
    with:
      fixtures-path: tests/maproom/Fixtures
      tests-path: tests/maproom/unit
```

### `reusable-drift-check` — conformance report for the calling repo

Runs on demand (scheduled or manual). Reports any drift from canonical standards.

```yaml
name: Drift check

on:
  schedule:
    - cron: '0 9 * * MON'      # weekly, Monday 09:00 UTC
  workflow_dispatch:

jobs:
  drift-check:
    uses: AzureLocal/platform/.github/workflows/reusable-drift-check.yml@v1
```

## Complete examples per repo type

### PS module repo (like Ranger or S2DCartographer)

```
.github/workflows/
├── ci.yml                  # reusable-ps-module-ci
├── maproom.yml             # reusable-maproom-run
├── release-please.yml      # reusable-release-please (from .github)
├── add-to-project.yml      # reusable-add-to-project (from .github)
├── validate-structure.yml  # reusable-validate-structure (from .github)
└── drift-check.yml         # reusable-drift-check (weekly)
```

### TS web app repo (like Surveyor)

```
.github/workflows/
├── ci.yml                  # reusable-ts-web-ci
├── release-please.yml      # reusable-release-please (from .github)
├── add-to-project.yml      # reusable-add-to-project (from .github)
├── validate-structure.yml  # reusable-validate-structure (from .github)
└── drift-check.yml         # reusable-drift-check
```

### IaC solution repo (like AVD, SOFS, AKS)

```
.github/workflows/
├── validate-iac.yml        # reusable-iac-validate
├── deploy-docs.yml         # reusable-mkdocs-deploy
├── release-please.yml      # reusable-release-please (from .github)
├── add-to-project.yml      # reusable-add-to-project (from .github)
├── validate-structure.yml  # reusable-validate-structure (from .github)
└── drift-check.yml         # reusable-drift-check
```

## If something goes wrong

- [`reusable-workflows/versioning.md`](versioning.md) — how to pin, how to migrate across majors
- [`reference/env-secrets.md`](../reference/env-secrets.md) — which secrets each workflow needs
- [`reference/troubleshooting.md`](../reference/troubleshooting.md) — common failure modes
