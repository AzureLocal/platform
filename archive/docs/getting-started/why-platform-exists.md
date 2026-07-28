---
title: Why platform exists
---

# Why platform exists

The short version: the AzureLocal organization has ~28 active repos, one maintainer, and drift.

## The measured drift

An audit of the 12 locally-cloned repos at the time of platform's creation found:

| Finding | Count | Implication |
|---|---|---|
| `/standards/` folder duplicated across repos | 7 of 12 | Content has diverged — different file extensions, different subsets, different edits. |
| `/repo-management/` folder duplicated | 11 of 12 | Same shared template drifted per-repo. |
| `CONTRIBUTING.md` has unique content per repo | 10 unique hashes | No two repos agree on contributor rules. |
| `deploy-docs.yml` near-duplicates | 9 of 12 | Same workflow, 9 slightly different copies to maintain. |
| Repos with NO `/standards`, `/repo-management`, or `CODEOWNERS` | 3 of 12 | Missed bootstrap, no retroactive fix. |
| Canonical MAPROOM testing framework | 1 of 12 | `S2DCartographer` has a great framework; every other PS module repo reinvents the wheel. |

## What manual maintenance would require

Every org-wide change — a new standard, an updated workflow, a renamed label — means:

1. Open N PRs (one per repo)
2. Review each one (or self-merge)
3. Wait for each CI to pass
4. Handle N subtly different merge conflicts
5. Verify the outcome matches

For N = 28 and one maintainer, that's infeasible. In practice, it meant the change happened in one or two repos and then stopped — hence the drift.

## What platform changes

### Single source of truth

- Standards live in [`platform/standards/`](https://github.com/AzureLocal/platform/tree/main/standards) and are pulled into the community docs site via a sync workflow. No product repo keeps a local copy.
- Canonical labels, branch protection rules, common files (LICENSE, .gitignore, .editorconfig, CODEOWNERS) live in [`platform/repo-management/org-scripts/`](https://github.com/AzureLocal/platform/tree/main/repo-management/org-scripts) and are pushed to every repo by `Sync-*.ps1` scripts.

### Reusable workflows

Nine near-duplicate `deploy-docs.yml` files become one `reusable-mkdocs-deploy.yml` plus nine four-line consumer files. Same pattern for PS module CI, TS web CI, and IaC validate. Changes to the reusable workflow propagate automatically to every consumer (pinned by major tag).

### Automated drift detection

A monthly [`drift-audit.yml`](https://github.com/AzureLocal/platform/tree/main/.github/workflows/drift-audit.yml) workflow inspects every repo and files an issue when drift is detected. The maintainer sees a checklist once a month instead of discovering drift ad-hoc when something breaks.

### One-command new repos

`New-AzureLocalRepo.ps1 -Type iac-solution -Name azurelocal-foo` replaces a dozen manual steps: create repo, clone, add standard files, apply labels, apply branch protection, wire CI. New repos are conforming from first commit.

## What platform does NOT try to do

- **Replace `.github`.** Community-health files and the three governance reusable workflows stay there. See [`reusable-workflows/split-rule.md`](../reusable-workflows/split-rule.md).
- **Enforce uniformity where repos legitimately differ.** A PS module repo and a TS web app repo have different structure — templates encode that.
- **Own product-specific content.** Fixtures, source code, and product docs stay with products.

## Rollout is phased

Platform didn't arrive overnight. Six phases across ~9 weeks — see the [implementation plan](https://github.com/AzureLocal/platform/blob/main/decisions/0001-create-platform-repo.md) for exit criteria per phase.

## Related reading

- [ADR 0001 — Create platform repo](https://github.com/AzureLocal/platform/blob/main/decisions/0001-create-platform-repo.md)
- [ADR 0002 — Standards single source](https://github.com/AzureLocal/platform/blob/main/decisions/0002-standards-single-source.md)
- [What is platform](what-is-platform.md)
- [Architecture overview](architecture-overview.md)
