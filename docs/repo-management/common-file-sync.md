---
title: Common file sync
---

# Common file sync

`Sync-CommonFiles.ps1` propagates the platform's canonical versions of shared files to every consumer repository. It compares each consumer's copy against the platform source and either reports the difference or opens a pull request with the corrected content.

## Files synced

| File | Notes |
|---|---|
| `LICENSE` | MIT license, identical across all repos |
| `.editorconfig` | Editor formatting rules |
| `.gitignore` | Common ignore patterns |

!!! note "Files that are never auto-synced"
    `CODEOWNERS` and `CHANGELOG.md` contain per-repo content and are intentionally
    excluded. The script will never overwrite them automatically.

## Running locally

The GitHub CLI (`gh`) and `git` must both be in `PATH`. `gh` must be authenticated.

```powershell
# Report-only mode — check for drift without making any changes (default)
./repo-management/org-scripts/Sync-CommonFiles.ps1

# Open PRs in every repo where drift is detected
./repo-management/org-scripts/Sync-CommonFiles.ps1 -CreatePR

# Dry run — preview what would happen, no API calls or git operations
./repo-management/org-scripts/Sync-CommonFiles.ps1 -DryRun

# Target a single repo and open a PR if drift is found
./repo-management/org-scripts/Sync-CommonFiles.ps1 -Repos azurelocal-ranger -CreatePR
```

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `-Org` | string | `AzureLocal` | GitHub organisation to target |
| `-PlatformRoot` | string | two levels above the script | Path to the local platform clone (source of canonical files) |
| `-Repos` | string[] | all non-archived repos except `platform` | Explicit list of repo names to target |
| `-Files` | string[] | `LICENSE`, `.editorconfig`, `.gitignore` | File paths (relative to repo root) to sync |
| `-CreatePR` | switch | — | Open a pull request in repos where drift is detected |
| `-DryRun` | switch | — | Print planned changes without making any API calls or git operations |

## Pull request details

When `-CreatePR` is passed, the script:

1. Clones the consumer repo to a temporary directory (`--depth 1`).
2. Creates a branch named `platform/sync-common-files-YYYYMMDD`.
3. Copies the drifted files from the platform root into the clone.
4. Commits with the message `chore: sync common platform files` and pushes the branch.
5. Opens a PR against `main` with a description listing the affected files.

The temporary clone is deleted automatically after the PR is created (or if an error occurs).

!!! tip
    Run without `-CreatePR` first to review what will change, then re-run with
    `-CreatePR` to open the PRs once you are satisfied with the diff.
