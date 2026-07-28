---
title: Templates overview
---

# Templates overview

Comparison of the 5 variants. Use this page to pick a `-Type` for `New-AzureLocalRepo.ps1`.

## Variant comparison

| Aspect | `ps-module` | `ts-web-app` | `iac-solution` | `migration-runbook` | `training-site` |
|---|---|---|---|---|---|
| Primary output | PowerShell module | Web UI | Infra definitions | Operational playbook | Course content |
| File count in variant template | 7 | 6 | 5 | 3 | 3 |
| Ships test framework | Pester + optional MAPROOM | Vitest / Jest | bicep lint + tf validate | None | None |
| release-please type | `simple` | `node` | `simple` | `simple` | `simple` |
| Required CI caller | `reusable-ps-module-ci.yml` | `reusable-ts-web-ci.yml` | `reusable-iac-validate.yml` | None beyond docs | None beyond docs |
| Representative consumer | `azurelocal-ranger` | `azurelocal-surveyor` | `azurelocal-avd` | `azurelocal-nutanix-migration` | `azurelocal-training` |

## Shared `_common` contents

Every variant inherits these 10 files:

- `.azurelocal-platform.yml` — self-descriptor (tokenised)
- `.editorconfig` — shared editor config
- `.gitignore` — base patterns
- `CHANGELOG.md` — release-please-compatible seed
- `CODEOWNERS` — single-maintainer rule
- `STANDARDS.md` — breadcrumb to platform standards
- `.github/workflows/add-to-project.yml` — project-board automation
- `.github/workflows/drift-check.yml` — weekly self-check
- `.github/workflows/release-please.yml` — release automation
- `.github/workflows/validate-repo-structure.yml` — self-validation

When a variant defines a file with the same path (e.g., `mkdocs.yml`), the variant wins.

## What a fresh repo looks like

After `New-AzureLocalRepo.ps1 -Type ps-module -Name azurelocal-foo`:

```text
azurelocal-foo/
├── .github/
│   └── workflows/
│       ├── add-to-project.yml         # from _common
│       ├── drift-check.yml            # from _common
│       ├── release-please.yml         # from _common
│       ├── validate-repo-structure.yml# from _common
│       ├── deploy-docs.yml            # from ps-module
│       ├── validate.yml               # from ps-module
│       └── publish-psgallery.yml      # from ps-module
├── docs/                               # MkDocs content (empty — add yours)
├── tests/                              # empty
├── AzureLocalFoo.psd1                  # from ps-module, token-substituted
├── AzureLocalFoo.psm1                  # from ps-module, token-substituted
├── .azurelocal-platform.yml            # from _common, token-substituted
├── .editorconfig                       # from _common
├── .gitignore                          # from _common
├── CHANGELOG.md                        # from _common
├── CODEOWNERS                          # from _common
├── STANDARDS.md                        # from _common
├── LICENSE                             # MIT, created by gh repo create
├── mkdocs.yml                          # from ps-module, token-substituted
└── README.md                           # from ps-module, token-substituted
```

The repo is ready to clone and edit. Next step is adding actual source code — the template is a scaffold, not a starter app.

## Picking the right variant — decision tree

1. Will the repo export PowerShell cmdlets? → `ps-module`
2. Will it be a browser UI? → `ts-web-app`
3. Will it contain Bicep, Terraform, or ARM? → `iac-solution`
4. Is it a one-time operational playbook? → `migration-runbook`
5. Is it training material? → `training-site`

If none fit: file an issue discussing the shape; likely you need a new variant — see [authoring a new variant](authoring-new-variant.md).

## Extending an existing variant

Edit files under `templates/<variant>/`. Changes are picked up on the next `New-AzureLocalRepo.ps1` run. Existing repos do not auto-update — they use `Sync-CommonFiles.ps1` (which only affects `_common` files today).

## Related

- [`ps-module`](ps-module.md) — details
- [`ts-web-app`](ts-web-app.md) — details
- [`iac-solution`](iac-solution.md) — details
- [`migration-runbook`](migration-runbook.md) — details
- [`training-site`](training-site.md) — details
- [Repo management → New-repo bootstrap](../repo-management/new-repo-bootstrap.md) — script internals
