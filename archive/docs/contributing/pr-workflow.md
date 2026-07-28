---
title: PR workflow
---

# PR workflow

Every change to `AzureLocal/platform` goes through a pull request, even for the sole maintainer. Reasons: the platform-CI check is the backstop against propagating bad content to ~28 consumer repos, and PR titles become release notes via release-please.

## Branch naming

```text
<type>/<short-description>
```

Types match Conventional Commits:

- `feat/` — new feature (new workflow, new function, new template)
- `fix/` — bug fix
- `docs/` — docs-only change
- `chore/` — refactor, dependency bumps, config, no user-visible change
- `ci/` — CI/workflow file edits that don't change consumer behaviour

Example: `feat/reusable-bicep-what-if`.

## Commit message format (Conventional Commits)

```text
<type>(<scope>): <subject>

<body>

<footer>
```

- **type**: `feat`, `fix`, `docs`, `chore`, `ci`, `test`, `refactor`, `perf`
- **scope** (optional): `maproom`, `trailhead`, `common`, `templates`, `standards`, `ci`, `docs`
- **subject**: imperative, ≤ 70 chars
- **body**: the *why*; what constraint or incident drove this change
- **footer**: `BREAKING CHANGE: <description>` for breaking changes (triggers major bump)

Examples:

```text
feat(maproom): add Test-MaproomFixture schema validation
fix(ps-module-ci): honour run-pester=false when no tests present
docs(reusable-workflows): clarify @v1 pin behaviour for v0.x callers
```

## Required status checks

A PR must have green on:

- `Platform CI / Markdown lint`
- `Platform CI / YAML lint`
- `Platform CI / Pester` (only if a PowerShell module was touched)

Branch protection blocks merge until these pass.

## Review

Single-maintainer reality: @kristopherjturner reviews and merges. For external PRs, expect a review within the next merge-Monday window unless it's tagged `priority:high`.

Review rubric:

1. Does the change match the PR's stated intent?
2. Is the commit log release-please-compatible?
3. Have consumer repos been checked for breakage (`@main` → specific SHA if risky)?
4. Is there an ADR for breaking changes?
5. Did docs get updated in the same PR?

## Merge strategy

- **Squash-merge** is the default — one commit per PR on `main`.
- The squash commit message becomes the release-please line; write it carefully.
- Merge commits and rebase-merges are disabled at the repo level.

## After merge

release-please opens (or updates) a release PR on `main`. Merge that release PR to cut a tag. See [release process](release-process.md).
