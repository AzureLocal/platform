---
title: Branch protection
---

# Branch protection

`Sync-BranchProtection.ps1` applies a uniform set of branch protection rules to the `main` branch of every non-archived repository in the org. Running the script at any time restores canonical settings, making it the recovery tool of choice when protection is accidentally removed or misconfigured.

## Canonical rules

The following ruleset is applied via the GitHub API (`PUT /repos/{org}/{repo}/branches/{branch}/protection`):

| Rule | Value |
|---|---|
| Required approving reviews | 1 |
| Dismiss stale reviews | false |
| Require code-owner review | false |
| Enforce admins | **false** |
| Allow force pushes | false |
| Allow branch deletions | false |
| Required conversation resolution | true |
| Required status checks | none imposed here — repos own their own gates |

### Why `enforce_admins: false`

With a single org maintainer, setting `enforce_admins: true` would block release-please merge commits and hotfix pushes that must land without a second approver. Admins are still subject to the no-force-push and no-delete rules; only the review gate is bypassable.

## Running locally

The GitHub CLI (`gh`) must be authenticated with `admin:org` scope or repo-admin rights on each target.

```powershell
# Apply to all non-archived repos
./repo-management/org-scripts/Sync-BranchProtection.ps1

# Dry run — show what would be applied without making API calls
./repo-management/org-scripts/Sync-BranchProtection.ps1 -DryRun

# Target specific repos
./repo-management/org-scripts/Sync-BranchProtection.ps1 -Repos azurelocal-ranger,azurelocal-surveyor -DryRun
```

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `-Org` | string | `AzureLocal` | GitHub organisation to target |
| `-Branch` | string | `main` | Branch name to protect |
| `-Repos` | string[] | all non-archived repos | Explicit list of repo names to target |
| `-DryRun` | switch | — | Print planned changes without making any API calls |

!!! tip "Restoring protection after an incident"
    If branch protection is accidentally removed from one or more repos, run
    `Sync-BranchProtection.ps1` without arguments to restore canonical settings across
    the entire org in a single pass. See also [Emergency runbooks](emergency-runbooks.md).
