---
title: "Template: iac-solution"
---

# Template: iac-solution

Scaffold for an infrastructure-as-code repo (Bicep, Terraform, or ARM — or a mix). Used by `azurelocal-avd`, `azurelocal-sofs-fslogix`, `azurelocal-loadtools`, `azurelocal-copilot`.

## When to pick this variant

- The repo's primary output is IaC templates that deploy Azure / Azure Local resources.
- Validation is syntax/lint (not functional) at PR time; actual deployment happens elsewhere.
- Pester or similar runtime test frameworks are not the main validation tool.

## What's in the template

```text
templates/iac-solution/
├── .github/workflows/
│   ├── ci-bicep.yml              # Bicep validation (remove if not using Bicep)
│   ├── ci-terraform.yml          # Terraform validation (remove if not using Terraform)
│   └── deploy-docs.yml           # Calls reusable-mkdocs-deploy.yml
├── mkdocs.yml
└── README.md
```

## Bicep CI caller — `ci-bicep.yml`

```yaml
name: CI — Bicep

on:
  pull_request:
    paths:
      - 'bicep/**'
      - '.github/workflows/ci-bicep.yml'
  push:
    branches: [main]
    paths:
      - 'bicep/**'

jobs:
  bicep:
    uses: AzureLocal/platform/.github/workflows/reusable-iac-validate.yml@main
    with:
      run-bicep: true
      run-terraform: false
      bicep-path: ./bicep
```

## Terraform CI caller — `ci-terraform.yml`

```yaml
name: CI — Terraform

on:
  pull_request:
    paths:
      - 'terraform/**'
      - '.github/workflows/ci-terraform.yml'
  push:
    branches: [main]
    paths:
      - 'terraform/**'

jobs:
  terraform:
    uses: AzureLocal/platform/.github/workflows/reusable-iac-validate.yml@main
    with:
      run-bicep: false
      run-terraform: true
      terraform-path: ./terraform
      terraform-version: '~>1.5'
```

## Folder layout conventions

```text
<repo-root>/
├── bicep/
│   ├── main.bicep
│   └── modules/
├── terraform/
│   ├── main.tf
│   └── modules/
├── arm/                         # If using ARM templates
│   └── *.json
├── docs/                        # MkDocs content
└── ...
```

Pick one primary tool (Bicep or Terraform) and delete the other CI caller if unused. Multi-tool repos keep both.

## What `reusable-iac-validate.yml` does

- **Bicep job**: `az bicep build` on every `*.bicep` file + linter output
- **Terraform job**: `terraform fmt -check`, `terraform init -backend=false`, `terraform validate`
- Both skip when their `run-*` input is `false` — no cost when unused

## Not included

- **Actual deployment workflow** — deployment is too environment-specific to template. Each repo authors its own `deploy.yml` with OIDC / SPN auth and the appropriate target.
- **Drift detection against deployed infra** — use `terraform plan` or `az deployment what-if` in a dedicated workflow; not in the platform template.
- **ARM what-if** — shipped as part of BLUEPRINT (v0.3.0, see [ADR-0004](https://github.com/AzureLocal/platform/blob/main/decisions/0004-testing-toolset-classification.md)).

## Tokens used in this variant

| Token | Usage |
|---|---|
| `{{REPO_NAME}}` | `mkdocs.yml` repo_url, README |
| `{{DESCRIPTION}}` | README, mkdocs site description |
| `{{YEAR}}` | Copyright |

## Post-scaffold steps

1. Create `bicep/` and/or `terraform/` folders with real templates
2. Remove the CI caller for unused tool
3. Author a deploy workflow (out of scope for this template)
4. Create `docs/index.md`

## Example consumers

- [`azurelocal-avd`](https://github.com/AzureLocal/azurelocal-avd) — Bicep + Terraform both active
- [`azurelocal-sofs-fslogix`](https://github.com/AzureLocal/azurelocal-sofs-fslogix)
- [`azurelocal-loadtools`](https://github.com/AzureLocal/azurelocal-loadtools)

## Related

- [Reusable workflow: iac-validate](../reusable-workflows/iac-validate.md)
