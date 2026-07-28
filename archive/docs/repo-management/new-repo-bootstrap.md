---
title: New-repo bootstrap
---

# New-repo bootstrap

`New-AzureLocalRepo.ps1` is the end-to-end "create a new AzureLocal repo" script. This page covers its internals. For how to invoke it from a user perspective, see [Onboarding → Create a new repo](../onboarding/create-new-repo.md).

## Script location

```text
platform/repo-management/org-scripts/New-AzureLocalRepo.ps1
```

## Execution pipeline

```text
Validate inputs
    │
    ▼
Create temp scaffold directory
    │
    ▼
Copy templates/_common/ → temp
    │
    ▼
Copy templates/<Type>/ → temp (overrides _common where paths collide)
    │
    ▼
Substitute {{TOKEN}} in file contents
    │
    ▼
Substitute {{TOKEN}} in filenames
    │
    ▼
gh repo create AzureLocal/<Name> --public --license=mit
    │
    ▼
git init + add + commit + push
    │
    ▼
(unless -SkipBranchProtection) Sync-BranchProtection.ps1
    │
    ▼
(unless -SkipLabels) Sync-Labels.ps1
    │
    ▼
Clean up temp directory
```

## Input validation

- `-Type` must be one of: `ps-module`, `ts-web-app`, `iac-solution`, `migration-runbook`, `training-site`.
- `-Name` must match the regex `^azurelocal-[a-z0-9][a-z0-9-]{1,40}$`.
- `-Description` must be non-empty.
- If `-ModuleName` omitted, derive PascalCase from the post-prefix slug: `azurelocal-foo-bar` → `AzureLocalFooBar`.

## Template merge

`templates/_common/` contents are copied first, then `templates/<Type>/` is overlaid. When a file exists in both, the variant wins — this is how `ps-module/mkdocs.yml` overrides the common mkdocs behaviour.

## Token substitution

Two passes over the temp directory:

1. **Content pass.** Every text file is read, `{{TOKEN}}` sequences replaced with the resolved value, and written back.
2. **Filename pass.** Every path component is checked; files named `{{MODULE_NAME}}.psd1` become `AzureLocalFoo.psd1`.

Token set resolved at runtime:

| Token | Value |
|---|---|
| `{{REPO_NAME}}` | `-Name` input |
| `{{MODULE_NAME}}` | `-ModuleName` input or derived from `-Name` |
| `{{DESCRIPTION}}` | `-Description` input |
| `{{REPO_TYPE}}` | `-Type` input |
| `{{YEAR}}` | `(Get-Date).Year` |
| `{{AUDIT_DATE}}` | `(Get-Date).ToString('yyyy-MM-dd')` |
| `{{MODULE_GUID}}` | Fresh `[guid]::NewGuid()` |
| `{{ID_PREFIX}}` | Uppercase first letters of module words (e.g., `AzureLocalRanger` → `ALR`) |
| `{{MAPROOM}}` | `true` when `-Type` is `ps-module`, else `false` |
| `{{WORKFLOWS_ADOPTED}}` | Per-variant default list |

## `gh repo create`

Invoked as:

```powershell
gh repo create AzureLocal/<Name> `
    --public `
    --description "<Description>" `
    --license MIT `
    --add-readme=false    # we bring our own
```

If the repo already exists, the script errors out — it does not try to merge into a pre-existing repo. For that path, use [adopt-from-existing-repo](../onboarding/adopt-from-existing-repo.md).

## Initial push

```powershell
cd <temp>
git init
git add -A
git commit -m "feat: initial scaffold from AzureLocal/platform template"
git branch -M main
git remote add origin https://github.com/AzureLocal/<Name>.git
git push -u origin main
```

## Protection and labels

Unless `-SkipBranchProtection` / `-SkipLabels`:

```powershell
./Sync-BranchProtection.ps1 -Repo <Name>
./Sync-Labels.ps1 -Repo <Name>
```

Both are called with the freshly-created repo's name. They handle the same 422-race-condition by retrying up to 3 times with exponential backoff (branch protection requires an initial commit on `main` which has just been pushed).

## Error handling

The script runs each step with `try/catch`. On failure:

- Print the failed step via `Write-AzureLocalLog -Level FAIL`
- Leave the partial state in place (repo may exist without protection, etc.)
- Exit non-zero so CI callers surface the failure

Re-running the script against an existing repo name errors on the `gh repo create` step. To resume, run `Sync-BranchProtection.ps1` and `Sync-Labels.ps1` manually against the created repo.

## `-DryRun`

When `-DryRun` is passed, the script:

- Validates inputs
- Prints the resolved token set
- Prints the merged file tree
- Prints the commands it *would* run (no `gh` or `git` invoked)

Always dry-run first.

## Related

- [Onboarding → Create a new repo](../onboarding/create-new-repo.md) — user-facing guide
- [Templates → Overview](../scaffolds/overview.md) — variant comparison
- [Reference → File manifest](../reference/file-manifest.md) — what files land in a new repo
