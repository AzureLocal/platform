---
title: Reusable workflows
---

# Reusable workflows

Six reusable GitHub Actions workflows are published from `AzureLocal/platform`. Consumer repos call them via `uses:` and pass stack-specific inputs.

## The six

| Workflow | Purpose | Typical consumer |
|---|---|---|
| [`reusable-mkdocs-deploy.yml`](mkdocs-deploy.md) | Build + deploy MkDocs Material docs site to GitHub Pages | Any repo with a docs site (all 11 consumers) |
| [`reusable-iac-validate.yml`](iac-validate.md) | Validate Bicep and/or Terraform (lint, fmt, validate) | `azurelocal-avd`, `azurelocal-sofs-fslogix`, `azurelocal-loadtools`, `azurelocal-copilot` |
| [`reusable-ps-module-ci.yml`](ps-module-ci.md) | PSScriptAnalyzer + Pester + optional MAPROOM fixture validation | `azurelocal-s2d-cartographer`, `azurelocal-ranger`, `azurelocal-toolkit`, `azurelocal-vm-conversion-toolkit` |
| [`reusable-ts-web-ci.yml`](ts-web-ci.md) | npm/pnpm typecheck + lint + test + build | `azurelocal-surveyor` |
| [`reusable-maproom-run.yml`](maproom-run.md) | Run `Test-MaproomFixture` over a consumer fixture set | MAPROOM consumers needing a dedicated job |
| [`reusable-drift-check.yml`](drift-check.md) | Weekly per-repo self-check for required files and platform pinning | Every consumer repo |

## Supporting pages

- [Consumer patterns](consumer-patterns.md) — copy-paste caller examples for each workflow
- [Split rule](split-rule.md) — which repo (`platform` vs `.github`) owns which workflow and why
- [Versioning](versioning.md) — `@v1` pinning semantics and migration across majors

## Pinning today

Platform is pre-stable (`v0.x.x`) — consumers reference `@main`:

```yaml
uses: AzureLocal/platform/.github/workflows/reusable-ps-module-ci.yml@main
```

`drift-check.yml` does **not** flag `@main` as drift while pre-stable. The `@v1` pin rule kicks in when platform tags v1.0.0.

## Permissions

Every reusable workflow declares its own job-level permissions. Callers **do not** need to repeat them. Example: `reusable-mkdocs-deploy.yml` sets `contents: read` on its build job and `pages: write` + `id-token: write` on its deploy job internally.

## Input stability guarantee

Each input is part of the public contract. See the per-workflow page for the full signature. Summary of what's stable:

| Change to a reusable workflow | Versioning impact |
|---|---|
| Add a new optional input with default | Patch or minor |
| Change the default of an existing input | Minor |
| Remove or rename an input | Major (breaking) |
| Remove or rename a job | Major (breaking) |
| Add a new job | Minor (unless downstream callers expect a fixed job graph) |

## Authoring new reusable workflows

Guide lives in [split rule](split-rule.md) (decides *where* it goes) and [versioning](versioning.md) (decides *how* it's published). New reusable workflows require an ADR.
