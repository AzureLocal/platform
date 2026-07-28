---
title: CODEOWNERS and reviewers
---

# CODEOWNERS and reviewers

## Canonical CODEOWNERS

The platform repo's `CODEOWNERS` is the **single source of truth** for every AzureLocal consumer repo. `Sync-CommonFiles.ps1` distributes it.

Current contents:

```text
* @kristopherjturner
```

Every file in every AzureLocal repo has @kristopherjturner as the required reviewer. This reflects the single-maintainer reality — it is intentional, not a gap.

## Why sync instead of per-repo CODEOWNERS

- A consumer fork of the CODEOWNERS file drifts immediately.
- Single-maintainer org means there's nothing to differentiate between repos — every path has one owner.
- When the maintainer roster changes (or a second maintainer onboards), one edit in platform + `Sync-CommonFiles.ps1 -CreatePR` fans out to all repos.

## How `Sync-CommonFiles.ps1` handles CODEOWNERS

- Source: `templates/_common/CODEOWNERS`
- Target: `CODEOWNERS` at the root of each consumer repo
- Run with `-DryRun` first to see the planned diff
- Run with `-CreatePR` to open a `platform/sync-common-files-YYYYMMDD` PR per repo with the change

## Reviewer expectations

| PR type | Minimum review |
|---|---|
| Platform repo PR | 1 approval from CODEOWNERS (= @kristopherjturner) + green CI |
| Consumer repo PR | 1 approval from CODEOWNERS (= @kristopherjturner) + green CI |
| Release-please PR (merge the auto-generated changelog PR) | Maintainer may self-approve (CODEOWNERS approval from the maintainer who opened it satisfies branch protection with `enforce_admins=false`) |

## Branch protection interaction

`Sync-BranchProtection.ps1` sets:

- `required_pull_request_reviews.required_approving_review_count = 1`
- `enforce_admins = false` — so the sole maintainer can merge their own PRs when reviewer pool is one person
- `require_code_owner_reviews = true`
- `required_conversation_resolution = true`

## Adding a second maintainer

When a second maintainer onboards:

1. Edit `templates/_common/CODEOWNERS` — add the new handle.
2. Land that PR on platform.
3. Run `./repo-management/org-scripts/Sync-CommonFiles.ps1 -CreatePR` to propagate.
4. Review and merge the ~12 sync PRs across consumer repos.
5. Optionally tighten `enforce_admins = true` in `Sync-BranchProtection.ps1` and re-run, now that self-merge isn't the only option.

## Path-specific ownership (future)

When the team grows past two maintainers, path-specific rules become useful:

```text
# Example — not active today
*                       @kristopherjturner
/testing/maproom/       @maproom-maintainers
/docs/                  @docs-maintainers
```

Track this in an ADR when adopted. The `Sync-CommonFiles.ps1` script needs no change — it just copies the file.
