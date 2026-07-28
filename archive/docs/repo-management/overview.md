---
title: Repo management overview
---

# Repo management overview

The automation set is designed around one question: *does every AzureLocal repo conform to the platform canon?* If the answer drifts, the automation brings it back.

## The automation surface

```text
┌─────────────────────────────────────────────────────────────────┐
│                         platform repo                           │
│                                                                 │
│  repo-management/org-scripts/                                   │
│  ├── Invoke-RepoAudit.ps1     ◀──  drift-audit.yml (monthly)    │
│  ├── Sync-Labels.ps1                                            │
│  ├── Sync-BranchProtection.ps1                                  │
│  ├── Sync-CommonFiles.ps1                                       │
│  └── New-AzureLocalRepo.ps1                                     │
│                                                                 │
│  modules/powershell/AzureLocal.Common/                          │
│  ├── Get-AzureLocalRepoInventory  ◀──  used by audit & sync     │
│  ├── Test-RepoConformance         ◀──  used by audit            │
│  └── Write-AzureLocalLog          ◀──  used by all scripts      │
└─────────────────────────────────────────────────────────────────┘
                         │
                         ▼
          ┌──────────────────────────────────┐
          │  AzureLocal consumer repos (N)   │
          │  ├── .azurelocal-platform.yml    │  ◀── self-descriptor
          │  ├── drift-check.yml (weekly)    │  ◀── self-check via reusable-drift-check.yml
          │  └── (standard required files)   │
          └──────────────────────────────────┘
```

## Two layers of enforcement

| Layer | Cadence | Owner | Action on failure |
|---|---|---|---|
| **Per-repo `drift-check.yml`** | Weekly (Mon 09:00 UTC) | Each consumer | CI fails; maintainer sees a red check |
| **Org-wide `drift-audit.yml`** | Monthly (1st, 09:00 UTC) | Platform | Issue filed on platform repo with `drift-report` label |

Per-repo check catches drift at the repo boundary; org-wide audit catches things the per-repo check can't — e.g., a repo that lost its `drift-check.yml` entirely.

## What each script does

| Script | One-line summary |
|---|---|
| `Invoke-RepoAudit.ps1` | Enumerate AzureLocal repos, run `Test-RepoConformance` on each, emit report |
| `Sync-Labels.ps1` | Apply canonical 16-label set (additive — never removes) |
| `Sync-BranchProtection.ps1` | Apply canonical protection (1 review, admin-not-enforced, no force-push, convo resolution) |
| `Sync-CommonFiles.ps1` | Propagate `_common` files (LICENSE, `.editorconfig`, `.gitignore`, CODEOWNERS) via PRs |
| `New-AzureLocalRepo.ps1` | Create a new repo from scratch: template + `gh repo create` + push + labels + protection |

## What's NOT automated (and why)

- **Archiving old repos** — human decision; automated archiving would risk losing context.
- **Removing labels that aren't in canonical set** — additive model is safer; allows per-repo custom labels.
- **Rewriting `.azurelocal-platform.yml`** — platform doesn't overwrite self-descriptor files; the consumer owns them.
- **Writing CHANGELOGs** — release-please does this per repo.

## Operational cadence

| When | What |
|---|---|
| Daily | Nothing scheduled; watch email for unexpected `drift-report` label |
| Weekly | Per-repo `drift-check.yml` runs; CI turns red if drifted |
| Monthly (1st) | `drift-audit.yml` runs; filed issue surfaces org-wide report |
| Ad-hoc | Run any script manually with `-DryRun` first |

## For operators

Most of the time: wait for the monthly audit, read the issue, decide whether to close with "drift is intentional" or fix. For sysadmins: see [emergency runbooks](emergency-runbooks.md).
