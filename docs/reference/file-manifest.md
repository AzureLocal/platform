---
title: File manifest
---

# File manifest

Every AzureLocal consumer repo must have the following files. `Test-RepoConformance` (in `AzureLocal.Common`) and `reusable-drift-check.yml` both enforce this set.

## Canonical required files (all repo types)

| File | Purpose | Source |
|---|---|---|
| `CHANGELOG.md` | Release history, maintained by release-please | `templates/_common/CHANGELOG.md` |
| `mkdocs.yml` | Docs site config | `templates/<variant>/mkdocs.yml` |
| `.github/workflows/deploy-docs.yml` | Calls `reusable-mkdocs-deploy.yml` | `templates/<variant>/.github/workflows/deploy-docs.yml` |
| `.github/workflows/drift-check.yml` | Weekly self-check for required files + platform pinning | `templates/_common/.github/workflows/drift-check.yml` |
| `.azurelocal-platform.yml` | Self-descriptor: repoType, adopts, lastAudited | Hand-authored per repo |

## Breadcrumb files (all repo types)

| File | Purpose | Source |
|---|---|---|
| `CODEOWNERS` | Single-maintainer rule synced from platform | `templates/_common/CODEOWNERS` |
| `STANDARDS.md` | Stub linking to `platform/docs/standards/` | `templates/_common/STANDARDS.md` |
| `.editorconfig` | Editor config synced from platform | `templates/_common/.editorconfig` |
| `.gitignore` | Base gitignore; variant-specific additions on top | `templates/_common/.gitignore` |
| `LICENSE` | MIT | Standard MIT |
| `CONTRIBUTING.md` | Contributor guidance (repo-local content above shared footer) | Per repo, contributes back to platform standards as needed |
| `README.md` | Repo-specific; must carry the AzureLocal Platform badge | Per repo |

## Per-variant files

### `ps-module`

| File | Purpose |
|---|---|
| `<ModuleName>.psd1` | Module manifest at repo root |
| `<ModuleName>.psm1` | Module code at repo root |
| `.github/workflows/validate.yml` | Calls `reusable-ps-module-ci.yml` |
| `.github/workflows/publish-psgallery.yml` | Publishes to PSGallery on tag (optional) |

### `ts-web-app`

| File | Purpose |
|---|---|
| `package.json` | Dependencies |
| `tsconfig.json` | TS config |
| `.github/workflows/ci.yml` | Calls `reusable-ts-web-ci.yml` |

### `iac-solution`

| File | Purpose |
|---|---|
| `.github/workflows/ci-bicep.yml` | Calls `reusable-iac-validate.yml` with `run-bicep: true` |
| `.github/workflows/ci-terraform.yml` | Calls `reusable-iac-validate.yml` with `run-terraform: true` |

Not every `iac-solution` ships both Bicep and Terraform — use only the relevant caller.

### `migration-runbook`

No required workflows beyond `deploy-docs.yml` + `drift-check.yml`. The runbook content lives in `docs/` of the consumer repo.

### `training-site`

Same as `migration-runbook` — content-first, minimal CI.

## `_common` scaffolding files (authored on `New-AzureLocalRepo.ps1`)

`templates/_common/` ships these into every new repo:

- `.azurelocal-platform.yml`
- `.editorconfig`
- `.gitignore`
- `CHANGELOG.md`
- `CODEOWNERS`
- `STANDARDS.md`
- `.github/workflows/add-to-project.yml`
- `.github/workflows/drift-check.yml`
- `.github/workflows/release-please.yml`
- `.github/workflows/validate-repo-structure.yml`

## Validation

`Test-RepoConformance -Org AzureLocal -RepoName <name>` returns a `$_.Passed` boolean and a `$_.DriftItems` list of missing files. Run from the platform repo:

```powershell
Import-Module ./modules/powershell/AzureLocal.Common/AzureLocal.Common.psd1 -Force
Test-RepoConformance -Org AzureLocal -RepoName azurelocal-ranger
```

## Contents of each required file

See the matching template under [`templates/`](https://github.com/AzureLocal/platform/tree/main/templates) for the canonical content. `Sync-CommonFiles.ps1` propagates changes to `_common` files across all consumers.
