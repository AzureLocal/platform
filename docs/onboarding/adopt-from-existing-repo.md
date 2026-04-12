---
title: Adopt from an existing repo
---

# Adopt platform from an existing repo

Step-by-step for taking one of the existing AzureLocal product repos and making it platform-conformant.

Do this once per repo during Phase 3 of the rollout. Each repo's adoption is its own PR.

## Prerequisites

- You have push access to the product repo
- Platform is at least at tag `v1.0.0` (or a pre-release `v0.x.y` if you're rolling out early)
- Relevant platform feature is available (e.g. if adopting `reusable-mkdocs-deploy`, it must exist and be tagged)

## Step 1 — delete duplicated content

| If the repo has | Delete it |
|---|---|
| `/standards/` folder (with `.mdx` or `.md` files copied from old `azurelocal.github.io`) | `rm -rf standards/` |
| `/repo-management/*.md` files that are byte-identical copies of [`platform/repo-management/templates/`](https://github.com/AzureLocal/platform/tree/main/repo-management/templates) | Delete matching files only — keep product-specific overlays |
| `CONTRIBUTING.md` that duplicates generic org-wide rules | Replace with shim (see step 3) |

Do NOT delete:

- Product-specific `src/`, `Modules/`, `bicep/`, `terraform/`, `docs/` (product's own docs, not platform docs)
- `CODEOWNERS` (it must stay physically present per GitHub rules; platform owns the *canonical copy*)
- Product-specific workflows

## Step 2 — add the three breadcrumbs

### 2a. README badge

At the very top of `README.md`, under the main title:

```markdown
[![AzureLocal Platform v1](https://img.shields.io/badge/AzureLocal_Platform-v1-0078D4)](https://github.com/AzureLocal/platform)
```

### 2b. `STANDARDS.md` stub

Create `STANDARDS.md` at repo root with exactly this content (adjust the `Repo type:` line):

```markdown
# Standards

This repository follows AzureLocal organization standards.
The canonical standards documents live in [AzureLocal/platform/standards](https://github.com/AzureLocal/platform/tree/main/standards).
Do not edit a local copy of these files — propose changes via PR against platform.

Repo type: ps-module
```

Valid `Repo type` values: `ps-module`, `ts-web-app`, `iac-solution`, `migration-runbook`, `training-site`, `meta`.

### 2c. `.azurelocal-platform.yml` metadata

Create at repo root:

```yaml
platformVersion: 1
repoType: ps-module
adopts:
  standards: true
  reusableWorkflows:
    - release-please
    - validate-structure
    - add-to-project
    - ps-module-ci         # stack-specific — add whichever apply
  maproom: true            # true if repo has tests/maproom/
  trailhead: false         # true if repo has tests/trailhead/
lastAudited: 2026-04-12    # ISO date of last manual audit
```

## Step 3 — replace `CONTRIBUTING.md` with a shim

Replace the repo's `CONTRIBUTING.md` with ~15 lines that defer to the org-wide file:

```markdown
# Contributing to <repo-name>

Organization-wide contribution rules live in [`AzureLocal/.github/CONTRIBUTING.md`](https://github.com/AzureLocal/.github/blob/main/CONTRIBUTING.md). Read that first.

This file adds only the rules specific to this repo.

## Running the tests

<product-specific commands here>

## Building locally

<product-specific commands here>
```

## Step 4 — convert CI workflows to reusable

For each workflow in `.github/workflows/` that duplicates platform-owned CI:

| Old workflow | New content (4-line call) |
|---|---|
| `deploy-docs.yml` | Calls `reusable-mkdocs-deploy.yml@v1` |
| `validate.yml` (PS module) | Calls `reusable-ps-module-ci.yml@v1` |
| `ci.yml` (TS web) | Calls `reusable-ts-web-ci.yml@v1` |
| `validate-config.yml` (IaC) | Calls `reusable-iac-validate.yml@v1` |

Example — converting `deploy-docs.yml`:

```yaml
name: Deploy docs

on:
  push:
    branches: [main]
    paths:
      - 'docs/**'
      - 'mkdocs.yml'
  workflow_dispatch:

jobs:
  deploy:
    uses: AzureLocal/platform/.github/workflows/reusable-mkdocs-deploy.yml@v1
```

See [`reusable-workflows/consumer-patterns.md`](../reusable-workflows/consumer-patterns.md) for every workflow's full consumer example.

## Step 5 — replace CODEOWNERS, .gitignore, .editorconfig with canonical copies

Either manually copy from [`platform/templates/_common/`](https://github.com/AzureLocal/platform/tree/main/templates/_common), or wait for `Sync-CommonFiles.ps1` (Phase 4) to push a PR for you automatically.

## Step 6 — open the PR

Title: `chore: adopt AzureLocal platform v1`

Description checklist:

```markdown
- [ ] Deleted duplicated `/standards/` folder
- [ ] Deleted duplicated `/repo-management/` template files
- [ ] Added README badge
- [ ] Added STANDARDS.md stub
- [ ] Added .azurelocal-platform.yml
- [ ] Replaced CONTRIBUTING.md with shim
- [ ] Converted deploy-docs.yml to call reusable
- [ ] Converted CI workflows to call reusable
- [ ] Canonical CODEOWNERS / .gitignore / .editorconfig in place
- [ ] CI green on this PR
```

## Step 7 — verify

After merge, run `Test-RepoConformance` against the repo:

```powershell
Import-Module ./modules/powershell/AzureLocal.Common/AzureLocal.Common.psd1
Test-RepoConformance -Repo AzureLocal/<repo-name>
```

Expect: no violations. If anything fails, see [`reference/troubleshooting.md`](../reference/troubleshooting.md).

## Rolling back

If adoption causes a regression you can't fix quickly, see [`rollback.md`](rollback.md).

## Related

- [Create a new repo](create-new-repo.md) — the same end state, but greenfield
- [Migration checklist](migration-checklist.md) — tracker for rolling adoption across many repos in Phase 3
- [Consumer patterns](../reusable-workflows/consumer-patterns.md) — reusable workflow copy-paste reference
