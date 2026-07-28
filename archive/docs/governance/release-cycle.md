---
title: Release cycle
---

# Release cycle

## Cadence

**Event-driven.** A release happens when one of the following lands on `main`:

- A `feat:` commit → minor bump
- A `fix:` or `perf:` commit → patch bump
- A `feat!:` commit or `BREAKING CHANGE:` footer → major bump

release-please opens (or updates) a release PR after every qualifying merge. Merging the release PR cuts the tag. There is no fixed weekly/monthly schedule — batching is done by timing the merge of the release PR.

## The pipeline

```text
┌─────────────┐     ┌─────────────┐     ┌───────────────┐     ┌─────────────┐
│ Feature PR  │ ──▶ │ Merge to    │ ──▶ │ release-please│ ──▶ │ Merge       │
│ merged      │     │ main        │     │ PR opened /   │     │ release PR  │
└─────────────┘     └─────────────┘     │ updated       │     └──────┬──────┘
                                        └───────────────┘            │
                                                                     ▼
                                                         ┌──────────────────────┐
                                                         │ Tag + GitHub Release │
                                                         │ created automatically│
                                                         └──────────┬───────────┘
                                                                    │
                                                                    ▼
                                                        ┌───────────────────────┐
                                                        │ Maintainer force-moves│
                                                        │ short major tag (v1)  │
                                                        └───────────────────────┘
```

## What triggers what

| Commit | release-please action | Consumer impact |
|---|---|---|
| `feat(maproom): add new function` | Opens/updates release PR with minor bump | None until release merged |
| Merge release PR | Cuts tag `azurelocal-platform-v0.3.0`, generates release notes | Consumers pinned to `@main` see change immediately; consumers pinned to `@v0` (not applicable today) would not |
| `docs(reusable-workflows): clarify pinning` | No release PR change | None |

## Release PR lifetime

- Open: after first qualifying commit lands on `main`
- Updates: each subsequent qualifying merge rebases/edits it
- Close when merged or when you manually close it (e.g., waiting for more features)

There's always zero or one release PR open — release-please does not fan out multiple PRs.

## Hotfix path

Platform pre-stable (`v0.x.x`) does not maintain backport branches. Every fix lands on `main` and ships in the next release.

Post-stable (v1+) this expands — see the [ADR for branch strategy](https://github.com/AzureLocal/platform/tree/main/decisions) once ratified.

## Version bump examples

| Current | Commits since last release | Next |
|---|---|---|
| `v0.2.0` | `fix(ci): ...` | `v0.2.1` |
| `v0.2.1` | `feat(common): ...`, `fix(maproom): ...` | `v0.3.0` |
| `v0.3.0` | `feat!(templates): remove deprecated token` | `v1.0.0` |
| `v1.0.0` | `docs: ...` only | *no release* |

## What happens to consumers

Pre-stable (today): consumers pin `@main`, so every merge to `main` takes effect immediately for them — the release PR merge adds a tag and changelog, but doesn't alter consumer behaviour.

Post-stable (v1+): consumers pin `@v1`. The short major tag is force-updated on release (see [release process](../contributing/release-process.md)), so consumers automatically pick up patches and minors within the same major. A major bump requires explicit consumer migration.

## Related pages

- [Contributing → Release process](../contributing/release-process.md) — the practical steps
- [Versioning](versioning.md) — semver policy
- [Breaking changes](breaking-changes.md) — what counts and how to communicate
