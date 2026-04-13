---
title: Drift audit
---

# Drift audit

The drift audit is an org-wide check that compares every non-archived AzureLocal repository against the canonical platform standards. It detects missing required files, workflows that have not adopted the platform reusable pattern, and repos that lack a `.azurelocal-platform.yml` descriptor.

## What counts as drift

A repository is considered drifted when any of the following is true:

- One or more required files are absent (see list below).
- A workflow file exists but still uses an inline implementation instead of calling the platform reusable workflow.
- The repo has no `.azurelocal-platform.yml` descriptor at the root.

### Required files

| File | Purpose |
|---|---|
| `CHANGELOG.md` | Release history, managed by release-please |
| `mkdocs.yml` | MkDocs site configuration |
| `.github/workflows/deploy-docs.yml` | Docs deployment, must call platform reusable workflow |
| `.github/workflows/drift-check.yml` | Per-repo self-check, calls `reusable-drift-check.yml` |
| `.azurelocal-platform.yml` | Repo descriptor read by the audit script |

## Running locally

Run from the root of a full platform clone. The GitHub CLI (`gh`) must be authenticated.

```powershell
# Print the audit report to the terminal
./repo-management/org-scripts/Invoke-RepoAudit.ps1

# CI mode — file a GitHub Issue on the platform repo and exit 1 if drift is found
./repo-management/org-scripts/Invoke-RepoAudit.ps1 -EmitIssue -FailOnDrift

# Write the report to disk as JSON
./repo-management/org-scripts/Invoke-RepoAudit.ps1 -OutputPath drift-report.json
```

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `-Org` | string | `AzureLocal` | GitHub organisation to audit |
| `-EmitIssue` | switch | — | Create a `drift-report` issue on the platform repo when drift is found |
| `-OutputPath` | string | — | Write the full report as a JSON file to this path |
| `-FailOnDrift` | switch | — | Exit with code 1 if any repos have drift (useful in CI) |

!!! note
    The script requires the `AzureLocal.Common` module, which lives at
    `modules/powershell/AzureLocal.Common/` in the platform repo. It is imported
    automatically when the script is run from a full clone.

## Automated schedule

`drift-audit.yml` runs `Invoke-RepoAudit.ps1` on a monthly schedule (09:00 UTC on the 1st of every month) and on `workflow_dispatch`. When drift is found it files a GitHub Issue on the platform repo with the label `drift-report`. The full JSON report is uploaded as a workflow artifact and retained for 90 days.

```text
Trigger: cron '0 9 1 * *' (monthly) + workflow_dispatch
Permissions: contents: read, issues: write
```

## Fixing drift

1. Open the `drift-report` issue filed on the platform repo. Each drifted repo is listed with the specific items that need attention.
2. Address the drift in the consumer repo — add the missing file, update the workflow call, or add the `.azurelocal-platform.yml` descriptor.
3. Re-run the audit locally to confirm the repo is clean before closing the issue:

```powershell
./repo-management/org-scripts/Invoke-RepoAudit.ps1 -Org AzureLocal -FailOnDrift
```

!!! tip
    If you need to suppress a false positive, add the relevant exemption to the
    repo's `.azurelocal-platform.yml` descriptor rather than disabling the check globally.
