# ADR 0001 — Create AzureLocal platform repo

- **Status**: Accepted
- **Date**: 2026-04-12
- **Deciders**: @kristopherjturner

## Context

The AzureLocal GitHub organization owns ~28 active repositories. An audit of the 12 locally-cloned repos showed systemic drift:

- `/standards/` folder duplicated across 7 repos (partial drift from the `azurelocal.github.io` source).
- `/repo-management/` folder duplicated across 11 repos with shared template files.
- `CONTRIBUTING.md` has 10 unique content hashes across 10 repos — every repo has drifted from every other.
- 9 repos each carry near-duplicate `deploy-docs.yml` workflow files.
- MAPROOM testing framework (offline fixture-based) exists in mature form only in `azurelocal-s2d-cartographer` — other PS module repos would benefit but can't easily share it today.
- Surveyor (TS/React) and two other repos are missing entire categories of standard files (no `/standards`, no `/repo-management`, no CODEOWNERS).

The existing `AzureLocal/.github` repo already hosts community-health files and three reusable workflows (`reusable-add-to-project.yml`, `reusable-release-please.yml`, `reusable-validate-structure.yml`). That repo is optimized for GitHub-metadata governance. It is NOT the right home for developer tooling, standards *docs*, ADRs, bootstrap scripts, shared PS modules, or a testing framework.

With ~28 repos to maintain and a solo maintainer, manual conformance is infeasible.

## Decision

Create a new public repository `AzureLocal/platform` (MIT license, main branch) that holds everything shared across the organization's repos:

- Canonical standards docs
- Repo-management templates + org-wide automation scripts
- MAPROOM and TRAILHEAD testing frameworks
- IIC canon (canonical synthetic identity data)
- Templates for new repos (5 variants)
- Shared PowerShell modules (`AzureLocal.Common`, future `AzureLocal.Maproom`)
- Reusable GitHub Actions workflows that are stack-specific (PS module CI, TS web CI, IaC validate, MkDocs deploy, MAPROOM run, drift check)
- Platform's own full MkDocs Material documentation site at `https://AzureLocal.github.io/platform/`

`AzureLocal/.github` continues to own GitHub-metadata governance. No content moves out of `.github`. The two repos have clearly separated responsibilities — GitHub metadata vs developer tooling.

Each product repo carries three breadcrumbs pointing to platform: README badge, `STANDARDS.md` stub, and `.azurelocal-platform.yml` metadata file.

## Consequences

### Positive

- Single source of truth for standards — 7 duplicated `/standards/` folders reduce to 1.
- Drift becomes detectable and automatable via a monthly `drift-audit.yml` cron.
- Reusable workflows remove 9 near-duplicate `deploy-docs.yml` files and similar CI duplication.
- MAPROOM framework becomes consumable by every PS module repo, not just S2DCartographer.
- New-repo creation becomes a single command: `New-AzureLocalRepo.ps1 -Type iac-solution -Name ...`.
- ADR trail for org-wide decisions prevents institutional-knowledge loss.

### Negative

- Two central homes for "shared stuff" — `.github` and `platform`. Judgement call required on where new shared content lives. Mitigated by the split rule documented in [ADR 0004 (pending)](./0004-reusable-workflow-split.md): `.github` owns governance, `platform` owns developer tooling.
- Breaking changes in platform can cascade across N consumer repos at once. Mitigated by major-version tagging (`@v1`, `@v2`) with six-month dual-support windows.
- Bus factor — one more repo for the solo maintainer to track. Mitigated by the automation scripts platform itself hosts.

### Affected repos / owners

- **All ~28 product repos**: must eventually adopt platform — badge, STANDARDS.md stub, `.azurelocal-platform.yml`. Rollout is phased over ~9 weeks.
- **`.github` repo**: unchanged. No content moves.
- **`azurelocal.github.io`**: gains a scheduled sync workflow pulling standards from `platform`.

## Alternatives considered

- **Keep standards duplicated, accept drift** — rejected. Drift is already causing maintenance pain and incorrect docs.
- **Put everything in `.github`** — rejected. `.github` is GitHub-metadata-oriented; mixing developer tooling dilutes its purpose and makes discovery harder.
- **Separate repos per concern** (e.g. `AzureLocal/standards`, `AzureLocal/testing-framework`, `AzureLocal/templates`) — rejected. Increases maintenance overhead and cross-linking fragility; single repo with clear folder boundaries is better for a solo-maintained org.
- **Make platform private** — rejected. GitHub reusable-workflow visibility rule: private-repo reusable workflows cannot be called by public repos. Would force workflows back into `.github` and collapse the consolidation value.

## Status

Accepted 2026-04-12. Phase 0 implementation in progress.
