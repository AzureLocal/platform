---
title: Label sync
---

# Label sync

`Sync-Labels.ps1` applies the canonical AzureLocal label set to every non-archived repository in the org. It adds labels that are missing and updates any label whose color or description has drifted from the definition in `labels.json`. Labels that exist in a repo but are not in the canonical set are left untouched — the script is additive only.

## Canonical label set

The source of truth is `repo-management/org-scripts/labels.json`. PRs that modify that file require a review before merge.

| Label | Color | Description |
|---|---|---|
| `bug` | `#d73a4a` | Something isn't working |
| `enhancement` | `#a2eeef` | New feature or request |
| `documentation` | `#0075ca` | Improvements or additions to documentation |
| `question` | `#d876e3` | Further information is requested |
| `wontfix` | `#ffffff` | This will not be worked on |
| `good first issue` | `#7057ff` | Good for newcomers |
| `help wanted` | `#008672` | Extra attention is needed |
| `duplicate` | `#cfd3d7` | This issue or pull request already exists |
| `invalid` | `#e4e669` | This doesn't seem right |
| `breaking-change` | `#b60205` | This change breaks the public API or a consumer contract |
| `drift-report` | `#e4762a` | Filed by `Invoke-RepoAudit.ps1` — repo has drifted from platform standards |
| `needs-review` | `#fbca04` | Awaiting review before next action |
| `trailhead` | `#1d76db` | Related to TRAILHEAD live-cluster validation |
| `maproom` | `#0e8a16` | Related to MAPROOM fixture-based testing |
| `platform` | `#5319e7` | Related to the AzureLocal platform itself |
| `dependencies` | `#0366d6` | Pull requests that update a dependency file |

## Running locally

The GitHub CLI (`gh`) must be authenticated with `org:write` scope (or equivalent repo-level write access).

```powershell
# Apply canonical labels to all repos in the org
./repo-management/org-scripts/Sync-Labels.ps1

# Dry run — print what would change without touching GitHub
./repo-management/org-scripts/Sync-Labels.ps1 -DryRun

# Target a single repo
./repo-management/org-scripts/Sync-Labels.ps1 -Repos azurelocal-ranger -DryRun
```

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `-Org` | string | `AzureLocal` | GitHub organisation to target |
| `-LabelsPath` | string | `labels.json` alongside the script | Path to the canonical label definitions file |
| `-Repos` | string[] | all non-archived repos | Explicit list of repo names to target |
| `-DryRun` | switch | — | Print planned changes without making any API calls |

## Behaviour notes

- The script compares each label by `name`, `color`, and `description`. If all three match the canonical definition, the label is skipped (no API call is made).
- Labels present in a repo that are absent from `labels.json` are intentionally preserved. Run with `-DryRun` to see the full state of a repo's labels without making changes.
- The script reports a count of synced, skipped, and errored labels at the end of each run.

!!! warning "Scope requirement"
    Creating or editing labels via the GitHub API requires write access to each target
    repository. Ensure `gh auth status` shows the correct org and scopes before running.
