---
title: Migration checklist
---

# Migration checklist

Step-by-step checklist for adopting platform from an existing AzureLocal repo. See [Adopt from an existing repo](adopt-from-existing-repo.md) for narrative context.

## Before you start

- [ ] `gh` CLI authenticated against AzureLocal (`gh auth status` shows `admin:org` scope)
- [ ] Platform repo cloned locally
- [ ] Target repo cloned locally, clean working tree, on `main`
- [ ] You have merge rights on the target repo

## Phase A — Required files (canonical 5)

Create a branch `platform/adoption-<yyyymmdd>` on the target repo and add:

- [ ] `CHANGELOG.md` — copy from `templates/_common/CHANGELOG.md`
- [ ] `mkdocs.yml` — copy and adapt from the matching variant template
- [ ] `.github/workflows/deploy-docs.yml` — calls `AzureLocal/platform/.github/workflows/reusable-mkdocs-deploy.yml@main`
- [ ] `.github/workflows/drift-check.yml` — copy from `templates/_common/.github/workflows/drift-check.yml`
- [ ] `.azurelocal-platform.yml` — create with `repoType`, `adopts`, `lastAudited`

### `.azurelocal-platform.yml` template

```yaml
platformVersion: 1
repoType: ps-module         # or ts-web-app, iac-solution, migration-runbook, training-site
adopts:
  standards: true
  reusableWorkflows:
    - drift-check
    - release-please
    - validate-structure
  maproom: false
  trailhead: false
lastAudited: YYYY-MM-DD
```

## Phase B — Breadcrumbs

- [ ] README badge — add at the top of `README.md`:

    ```markdown
    [![AzureLocal Platform](https://img.shields.io/badge/platform-AzureLocal-0078D4)](https://github.com/AzureLocal/platform)
    ```

- [ ] `STANDARDS.md` stub at repo root:

    ```markdown
    # Standards

    This repo follows the [AzureLocal platform standards](https://github.com/AzureLocal/platform/tree/main/docs/standards).
    ```

- [ ] CODEOWNERS — copy from `templates/_common/CODEOWNERS` (single-maintainer reality; do not diverge)

## Phase C — CI alignment (optional on first pass)

Decide which existing workflows to replace with reusable ones. Not required on adoption, but recommended within one release cycle.

- [ ] If docs site exists: replace custom docs workflow with `reusable-mkdocs-deploy.yml`
- [ ] If PS module: migrate PSScriptAnalyzer + Pester to `reusable-ps-module-ci.yml`
- [ ] If TS web app: migrate lint/test/build to `reusable-ts-web-ci.yml`
- [ ] If IaC: migrate Bicep/Terraform validate to `reusable-iac-validate.yml`
- [ ] If MAPROOM consumer: add `reusable-maproom-run.yml` job

## Phase D — Automation sync

Run from the platform repo:

- [ ] `./repo-management/org-scripts/Sync-Labels.ps1 -Repo <name> -DryRun`
- [ ] `./repo-management/org-scripts/Sync-Labels.ps1 -Repo <name>` (after dry run looks right)
- [ ] `./repo-management/org-scripts/Sync-BranchProtection.ps1 -Repo <name> -DryRun`
- [ ] `./repo-management/org-scripts/Sync-BranchProtection.ps1 -Repo <name>`

## Phase E — Validate

- [ ] Push the branch and open a PR on the target repo
- [ ] `drift-check.yml` runs on the PR — should pass
- [ ] Review and merge
- [ ] Confirm on next scheduled `drift-check.yml` run (weekly Monday 09:00 UTC) that the repo stays green

## Phase F — Post-merge sanity check

Run an on-demand audit from platform:

- [ ] `gh workflow run drift-audit.yml -R AzureLocal/platform` (or wait for monthly cron)
- [ ] Inspect the drift report issue — target repo should not appear

## Rollback

If adoption causes unexpected breakage, revert the adoption PR. See [rollback](rollback.md).

## Mark adoption complete

- [ ] Bump `lastAudited` in `.azurelocal-platform.yml` to today's date
- [ ] Optionally announce in the `#azurelocal-platform` channel (or whatever comms are active)
- [ ] Target repo is now a consumer — consider it part of the Phase 4 managed set

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `drift-check.yml` fails immediately | `.azurelocal-platform.yml` YAML syntax | `yamllint` it locally |
| `mkdocs build` fails in CI | `docs/index.md` missing or `mkdocs.yml` nav broken | Create `docs/index.md` and verify nav refs |
| Branch protection doesn't apply | `gh` token missing `admin:org` | `gh auth refresh -s admin:org` and retry |
| Labels sync skips existing labels | Intended — sync is additive | Delete conflicting labels manually first if needed |
