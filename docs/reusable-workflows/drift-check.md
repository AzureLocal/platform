---
title: reusable-drift-check
---

# reusable-drift-check

A lightweight per-repo self-check that verifies a consumer repository stays aligned with platform standards. It runs a single `drift` job (on `ubuntu-latest`) with two checks:

1. **Required files** — confirms that every file listed in `required-files` exists in the repo.
2. **Deploy-docs reference** — when `check-platform-deploy-docs` is true, confirms that `.github/workflows/deploy-docs.yml` calls `AzureLocal/platform/.github/workflows/reusable-mkdocs-deploy.yml` rather than using an inline implementation.

The job prints a summary of drift points and exits non-zero if `fail-on-drift` is true and any drift is found.

## Inputs

| Input | Type | Default | Description |
|---|---|---|---|
| `required-files` | string | `CHANGELOG.md,mkdocs.yml,.github/workflows/deploy-docs.yml` | Comma-separated list of files that must exist in the repo |
| `check-platform-deploy-docs` | boolean | `true` | Verify `deploy-docs.yml` references the platform reusable workflow |
| `fail-on-drift` | boolean | `true` | Exit non-zero when drift is detected; set `false` for report-only mode |

## Caller example

Every product repo should have a `.github/workflows/drift-check.yml` that calls this workflow on a weekly schedule:

```yaml
name: Drift Check

on:
  schedule:
    - cron: '0 9 * * 1'   # Monday 09:00 UTC
  workflow_dispatch:

permissions:
  contents: read

jobs:
  drift:
    uses: AzureLocal/platform/.github/workflows/reusable-drift-check.yml@main
    with:
      required-files: CHANGELOG.md,mkdocs.yml,.github/workflows/deploy-docs.yml,.github/workflows/drift-check.yml,.azurelocal-platform.yml
```

## Distinguishing drift-check from drift-audit

| | `reusable-drift-check` | `drift-audit.yml` |
|---|---|---|
| Scope | Single repo (self-check) | Org-wide (all repos) |
| Runs in | Each consumer repo | Platform repo only |
| Trigger | Weekly schedule in the consumer | Monthly schedule on the platform |
| On failure | Consumer workflow fails | Issues filed on the platform repo |
| Action required by | Consumer repo maintainer | Org maintainer (@kristopherjturner) |

!!! note
    `reusable-drift-check` is a lightweight file-existence check. The org-wide
    [`drift-audit`](../repo-management/drift-audit.md) is the authoritative audit that
    checks workflow patterns and `.azurelocal-platform.yml` content in depth.
