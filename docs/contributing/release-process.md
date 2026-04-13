---
title: Release process
---

# Release process

`AzureLocal/platform` uses [release-please](https://github.com/googleapis/release-please) to automate versioning and tag creation based on Conventional Commits.

## The loop

```text
PR merged → release-please parses log → release PR opened/updated → merge → tag + GitHub Release
```

No one hand-edits `CHANGELOG.md` or creates tags manually. Every step after a PR is merged is automated.

## Version bumps

release-please decides the bump from commit types:

| Commit type | Bump |
|---|---|
| `fix:`, `perf:` | patch (`0.2.0 → 0.2.1`) |
| `feat:` | minor (`0.2.0 → 0.3.0`) |
| `feat!:` or `BREAKING CHANGE:` footer | major (`0.2.0 → 1.0.0`) |
| `docs:`, `chore:`, `ci:`, `test:`, `refactor:` | no bump (but still appears in log) |

## Tag format

```text
azurelocal-platform-v<MAJOR>.<MINOR>.<PATCH>
```

Consumers pin to the *short* major tag (`v1`, `v2`) — not the full tag. See [workflow versioning](../reusable-workflows/versioning.md).

## Cutting a release

1. Land all the PRs you want in the release (squash-merged to `main`).
2. Check the open release-please PR — confirm the proposed version and changelog entries look right.
3. Merge the release PR.
4. release-please creates the git tag and GitHub Release automatically.
5. Update the short major tag to point at the new release:

    ```powershell
    git fetch origin --tags
    git tag -f v<MAJOR> azurelocal-platform-v<MAJOR>.<MINOR>.<PATCH>
    git push origin -f v<MAJOR>
    ```

    This step moves `v1` (or `v2`, etc.) forward so existing consumer pins pick up the new patch/minor. Only do this when the release is backwards-compatible with the major.

## Current version state

While platform is pre-stable (`v0.x.x`), consumers reference `@main` — the `@v1` pin rule activates at v1.0.0. See [governance/versioning](../governance/versioning.md) for the full policy.

## What release-please updates

| File | What |
|---|---|
| `CHANGELOG.md` | Prepends a new `## [x.y.z]` section |
| `release-please-config.json` | Untouched (config-only) |
| `.release-please-manifest.json` | Bumped to new version |
| Git tag | `azurelocal-platform-v<x.y.z>` |
| GitHub Release | Created with the changelog slice as the body |

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| No release PR opened | No qualifying commit since last release (all `docs:`/`chore:`) | Land a `feat:` or `fix:` commit |
| Release PR shows wrong version bump | Commit type was wrong at merge | Don't try to rewrite — land a follow-up PR with the correct type |
| Tag missing after merge | Release-please workflow failed | Check `.github/workflows/release-please.yml` run; usually a permissions issue |
