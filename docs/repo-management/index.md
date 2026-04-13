---
title: Repo management
---

# Repo management

Org-wide automation that keeps the ~28 AzureLocal repos in sync with the platform canon.

## What lives here

| Page | Script(s) |
|---|---|
| [Overview](overview.md) | High-level map of the automation set |
| [New-repo bootstrap](new-repo-bootstrap.md) | `New-AzureLocalRepo.ps1` — create a new repo end-to-end |
| [Drift audit](drift-audit.md) | `Invoke-RepoAudit.ps1` — monthly org-wide conformance report |
| [Label sync](label-sync.md) | `Sync-Labels.ps1` — apply canonical 16-label set |
| [Branch protection](branch-protection.md) | `Sync-BranchProtection.ps1` — apply canonical rules |
| [Common file sync](common-file-sync.md) | `Sync-CommonFiles.ps1` — propagate LICENSE, `.editorconfig`, `.gitignore` |
| [Emergency runbooks](emergency-runbooks.md) | What to do when something goes wrong org-wide |

## Script location

All scripts are under `repo-management/org-scripts/` in the platform repo. All depend on `AzureLocal.Common` for logging, inventory, and conformance checks.

## Invocation model

Scripts are designed to:

- Default to **dry-run / report-only** when run without mutating flags.
- Accept `-Repo <name>` to operate against a single repo, or no `-Repo` to operate against every non-archived AzureLocal repo.
- Use `Write-AzureLocalLog` for colored, level-tagged output.
- Emit JSON when `-OutputPath` is given (for CI consumption by `drift-audit.yml`).

## Prerequisites

- `gh` CLI authenticated with `repo` and `admin:org` scopes
- PowerShell 7.2+
- Platform repo cloned and `AzureLocal.Common` importable

## Read before running destructive scripts

- [Sync-Labels](label-sync.md) — additive, not destructive
- [Sync-BranchProtection](branch-protection.md) — overwrites existing protection; dry-run first
- [Sync-CommonFiles](common-file-sync.md) — opens PRs; dry-run first
- [New-AzureLocalRepo](new-repo-bootstrap.md) — creates GitHub resources; dry-run first
