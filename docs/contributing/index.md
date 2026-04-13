---
title: Contributing
---

# Contributing to platform

Contributions to `AzureLocal/platform` fall into four tracks. Each track has its own conventions — pick the one that matches what you're changing and follow the linked page.

| Track | When to use | Page |
|---|---|---|
| **Standards** | Editing anything under `docs/standards/`, or the canonical rules propagated to consumer repos | [Standards contributing](../standards/contributing.md) |
| **Reusable workflows** | Editing any file in `.github/workflows/reusable-*.yml` | [Workflow versioning](../reusable-workflows/versioning.md) |
| **MAPROOM / TRAILHEAD** | Editing testing framework code, schemas, or IIC canon | [MAPROOM extending](../maproom/extending-the-framework.md) |
| **Everything else** | Docs, templates, org-scripts, `AzureLocal.Common` helpers | Follow [PR workflow](pr-workflow.md) |

## Contributor expectations

- **One maintainer today.** @kristopherjturner owns the repo. External PRs are welcome but review cadence matches single-maintainer capacity.
- **Conventional Commits are mandatory.** release-please reads the log to decide the next version bump.
- **Breaking changes require an ADR.** See [governance/breaking-changes](../governance/breaking-changes.md).
- **Every PR must pass `platform-ci.yml`** — markdownlint, yamllint, and Pester if modules were touched.

## Contribute in order

1. [Local setup](local-setup.md) — clone, Python venv, `mkdocs serve`, run tests
2. [PR workflow](pr-workflow.md) — branch naming, commit format, status checks, review
3. [Testing platform](testing-platform.md) — how platform-ci, Pester, and reusable-workflow dry runs work
4. [Release process](release-process.md) — how a merged PR becomes a new version tag
