---
title: reusable-iac-validate
---

# reusable-iac-validate

Validates Infrastructure-as-Code in consumer repositories. Two independent jobs run in parallel — `bicep` and `terraform` — each gated by a boolean input so repos can opt into only the toolchain they use.

## Jobs

### Bicep (`run-bicep`)

Runs against all `*.bicep` files found under `bicep-path`:

1. `az bicep build --file <file> --stdout` — compiles every file and fails on any compilation error.
2. `az bicep lint --file <file>` — lints every file and fails on any lint error.

Uses `azure/CLI@v2` with an isolated `AZURE_CONFIG_DIR` so no Azure credentials are required.

### Terraform (`run-terraform`)

Runs in `terraform-path`:

1. `terraform fmt -check -recursive` — fails if any file is not formatted canonically.
2. `terraform init -backend=false` — initialises the module graph without connecting to a state backend.
3. `terraform validate` — validates the configuration.

Uses `hashicorp/setup-terraform@v3` with a configurable version constraint.

## Inputs

| Input | Type | Default | Description |
|---|---|---|---|
| `run-bicep` | boolean | `true` | Enable the Bicep build + lint job |
| `run-terraform` | boolean | `true` | Enable the Terraform validate job |
| `bicep-path` | string | `src/bicep` | Directory containing `.bicep` files |
| `terraform-path` | string | `src/terraform` | Working directory for Terraform commands |
| `terraform-version` | string | `~> 1.5` | Terraform version constraint passed to `setup-terraform` |

## Caller examples

### Bicep only

```yaml
name: IaC Validate

on: [pull_request]

permissions:
  contents: read

jobs:
  validate:
    uses: AzureLocal/platform/.github/workflows/reusable-iac-validate.yml@main
    with:
      run-bicep: true
      run-terraform: false
      bicep-path: infrastructure/bicep
```

### Terraform only

```yaml
name: IaC Validate

on: [pull_request]

permissions:
  contents: read

jobs:
  validate:
    uses: AzureLocal/platform/.github/workflows/reusable-iac-validate.yml@main
    with:
      run-bicep: false
      run-terraform: true
      terraform-path: infrastructure/terraform
      terraform-version: '~> 1.7'
```

### Both Bicep and Terraform

```yaml
name: IaC Validate

on: [pull_request]

permissions:
  contents: read

jobs:
  validate:
    uses: AzureLocal/platform/.github/workflows/reusable-iac-validate.yml@main
    with:
      bicep-path: infra/bicep
      terraform-path: infra/terraform
```

!!! note
    The Bicep and Terraform jobs run in parallel. A failure in one does not cancel the
    other, so you get full feedback from both toolchains in a single run.
