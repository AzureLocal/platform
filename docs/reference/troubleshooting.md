---
title: Reference troubleshooting
---

# Reference troubleshooting

Cross-cutting platform issues. For MAPROOM-specific issues, see [MAPROOM → Troubleshooting](../maproom/troubleshooting.md).

## Docs site build fails

### `mkdocs build` — `Config value: 'plugins'. Error: The "X" plugin is not installed`

Platform's `mkdocs.yml` uses `mermaid2`, `include-markdown`, `git-revision-date-localized`, `minify`. Consumer mkdocs that borrow from the platform template may not install all of them.

**Fix:** Update the consumer's CI caller to include the relevant pip package:

```yaml
uses: AzureLocal/platform/.github/workflows/reusable-mkdocs-deploy.yml@main
with:
  pip-packages: 'mkdocs-material mkdocs-git-revision-date-localized-plugin'
```

### `mkdocs build` — `Unrecognised language 'text'`

This is usually a linter warning, not a build failure. Check the code fence — it should be ` ```text` (lowercase).

### Navigation links broken after reorganising docs

Run the link check:

```powershell
npx markdown-link-check docs/**/*.md
```

Fix each broken link. Cross-doc links are relative to the source `.md` file, not the rendered URL.

## `reusable-*` workflow fails — "unable to find reusable workflow"

Symptoms and fixes are in [MAPROOM troubleshooting](../maproom/troubleshooting.md#reusable-workflow-fails--unable-to-find-reusable-workflow).

Extra cause: the consumer is in a private repo calling a public platform reusable workflow. Private → public is allowed. Public → private is not (GitHub rule).

## Drift-audit produces an issue with zero drift items

**Symptom:** `drift-audit.yml` runs, creates an issue, but the issue body is empty or lists no repos.

**Cause:** Issue-emit triggers on every audit; the body should say "no drift" rather than create an empty issue.

**Fix:** Current behaviour creates an issue only when drift is detected (see `Invoke-RepoAudit.ps1` guard). If an empty issue appears, it's a regression — file a platform issue.

## `Sync-Labels.ps1` doesn't remove old labels

**Expected behaviour.** Label sync is additive — it creates or updates but never deletes. Deletion is manual per [label sync](../repo-management/label-sync.md).

## `Sync-BranchProtection.ps1` — HTTP 422

**Symptom:**

```text
gh: HTTP 422 Unprocessable Entity
```

**Causes:**

1. Branch doesn't exist on the remote (new repo with no initial commit). Push something first.
2. `required_status_checks.contexts` references a check that has never run — GitHub requires at least one run before it can be required. Workaround: set protection without status checks, let one run complete, then re-run the sync to add them.
3. Token lacks `admin:org` scope. Refresh with `gh auth refresh -s admin:org`.

## `New-AzureLocalRepo.ps1` — repo created but protection not applied

**Cause:** Branch protection requires at least one commit on `main`, but the script pushes and then calls `Sync-BranchProtection.ps1` — if the push hadn't fully propagated, the API call 422s.

**Fix:** The script already retries with exponential backoff. If you're seeing persistent failures, re-run just the protection step:

```powershell
./repo-management/org-scripts/Sync-BranchProtection.ps1 -Repo <new-repo-name>
```

## Consumer `drift-check.yml` fails — file content mismatch

**Symptom:**

```text
DRIFT: CODEOWNERS content differs from platform canon
```

**Cause:** A consumer hand-edited a `_common` file. The drift check compares content, not just presence.

**Fix:** Revert the local edit; if the edit was intentional, update platform's canonical file and propagate via `Sync-CommonFiles.ps1 -CreatePR` so every repo stays in sync.

## `gh` CLI — "could not determine default branch"

**Cause:** `gh` CLI's cached config is stale after a branch rename.

**Fix:**

```powershell
gh repo set-default  # select again
```

## PowerShell module import fails on first try, succeeds on second

**Cause:** `Import-Module` with `-Force` tries to re-compile types that are already loaded. When multiple `.ps1` files in `Public/` define conflicting types, PS silently loads a stale version.

**Fix:** Start a fresh PS session (close and reopen). If the problem persists, it's a module structure bug — file an issue with the module name and the specific type conflict.

## Still stuck

Open an issue on [AzureLocal/platform](https://github.com/AzureLocal/platform/issues) with:

- Platform version / SHA in use (`git log -1 --format=%H` from your platform clone)
- Consumer repo name and version
- Full workflow run URL (if a CI issue) or full error text (if local)
- What you've already tried
