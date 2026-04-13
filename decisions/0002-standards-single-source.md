# ADR 0002 — Standards as single source of truth in platform

- **Status**: Accepted
- **Date**: 2026-04-12
- **Deciders**: @kristopherjturner

## Context

Seven AzureLocal repos each carry a local `/standards/` folder with copies of the 10+ standards documents. The content derives from `azurelocal.github.io/standards/` but has drifted — different file formats (`.mdx` vs `.md`), different subsets of files, occasional per-repo tweaks. Keeping them in sync manually is failing.

We need one authoritative home for standards docs that:

- Every product repo can reference without forking
- The community docs site (`azurelocal.github.io`) can render for human readers
- Has change tracking and PR review (so edits aren't ad-hoc)
- Is publicly readable (every repo that references it is public; broken permalinks would be worse than drift)

## Decision

Canonical standards docs live **only** in `AzureLocal/platform/docs/standards/`. No other repo keeps a local copy.

Distribution model:

1. **Community docs site** (`azurelocal.github.io`) continues to render standards for humans. It pulls `platform/docs/standards/*.md` via a scheduled GitHub Actions workflow and publishes them as `.mdx` in the site's `standards/` folder. The site renders, the platform repo authors.

2. **Product repos** carry a `STANDARDS.md` stub (~6 lines) at repo root that links to [`https://github.com/AzureLocal/platform/tree/main/docs/standards`](https://github.com/AzureLocal/platform/tree/main/docs/standards). No files copied.

3. **Maintenance**: standards changes are PRs against `platform`. Typos need no ADR; substantive changes do.

The 7 existing `/standards/` folders in product repos are deleted in Phase 1 of the rollout.

## Consequences

### Positive

- One canonical text of each standard. Drift eliminated by construction.
- Community docs site reliably reflects current standards (sync is one-way, overwrite, not merge).
- Product repo PRs about standards become PRs against platform — reviewable, ADR-gated, versioned.
- New repos automatically inherit the current standards via the `STANDARDS.md` stub in [`templates/_common/`](../templates/_common/STANDARDS.md).

### Negative

- Community docs site depends on the scheduled sync workflow. If it breaks, the rendered standards go stale silently. Mitigated by: sync runs on platform release, site CI asserts "standards content matches platform at this tag", stale content fails the site's own CI.
- Standards-only edits require a platform PR even if the change is narrow. Acceptable — standards edits are rare.
- Product repo visitors clicking the `STANDARDS.md` link leave the product repo. Acceptable — GitHub renders platform's standards docs fine.

### Affected repos / owners

- **7 repos with local `/standards/` folders**: delete the folder, add the stub. Phase 1 work.
- **`azurelocal.github.io`**: add scheduled sync workflow. Phase 1 work.
- **Future new repos**: `New-AzureLocalRepo.ps1` includes the stub automatically; no manual action needed.

## Alternatives considered

- **Git submodule**: rejected. Submodules create UX friction on clone (init/update), and `mdx` rendering in Docusaurus doesn't play well with submodule paths.
- **Standards in `.github`**: rejected. `.github` is governance-oriented; standards are developer-tooling-oriented and fit the platform repo's purpose.
- **Keep the site as canonical, platform as mirror**: rejected. Platform is where the ADR process and change review live; authoring should happen where reviews happen.
- **Every repo owns its own standards**: rejected — that's the current state that produced the drift.

## Status

Accepted 2026-04-12. Phase 0 seeds the `standards/` folder; Phase 1 consolidates.
