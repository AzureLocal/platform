---
title: Env and secrets
---

# Env and secrets

Environment variables and GitHub secrets used by platform workflows, org-scripts, and MAPROOM.

## GitHub secrets (used by workflows)

| Secret | Scope | Used by | Purpose |
|---|---|---|---|
| `GITHUB_TOKEN` | Built-in, all workflows | Every workflow | Default auth token; scoped by the workflow's `permissions:` block |
| `NUGET_API_KEY` | Repo-level (ps-module consumers) | `publish-psgallery.yml` | Publish a PS module to PSGallery on tag |
| `PAGES_TOKEN` | Not used today | — | GitHub Pages uses `GITHUB_TOKEN` via the pages/id-token flow |

`GITHUB_TOKEN` is never stored; it is issued per run by GitHub Actions. Permissions are declared inline in the calling workflow.

## Environment variables set by reusable workflows

| Variable | Set by | Purpose |
|---|---|---|
| `PLATFORM_ROOT` | `reusable-ps-module-ci.yml` (when `validate-maproom: true`), `reusable-maproom-run.yml` | Absolute path to the checked-out platform repo; used to import `AzureLocal.Maproom` |

Consumer scripts that run inside a reusable workflow access `PLATFORM_ROOT` as a regular env var:

```powershell
Import-Module (Join-Path $env:PLATFORM_ROOT 'testing/maproom/AzureLocal.Maproom.psd1') -Force
```

## Environment variables for local dev

| Variable | Purpose |
|---|---|
| `GITHUB_TOKEN` | Authenticate `gh` CLI for org-scripts that read/write via GitHub API |
| `AZURELOCAL_PLATFORM_ROOT` | Optional — defaults to the current directory when running from platform clone; set when running scripts from elsewhere |

## gh CLI scopes required

| Script | Scopes |
|---|---|
| `Invoke-RepoAudit.ps1` (read-only) | `repo` |
| `Invoke-RepoAudit.ps1 -EmitIssue` | `repo`, `issues:write` (via `GITHUB_TOKEN` in CI) |
| `Sync-Labels.ps1` | `repo`, `admin:org` |
| `Sync-BranchProtection.ps1` | `repo`, `admin:org` |
| `Sync-CommonFiles.ps1` (report only) | `repo` |
| `Sync-CommonFiles.ps1 -CreatePR` | `repo` (push to forks / branches) |
| `New-AzureLocalRepo.ps1` | `repo`, `admin:org`, `workflow` |

Authenticate once with the full set:

```powershell
gh auth login --scopes "repo,admin:org,workflow"
```

## Secrets NOT stored in the platform repo

- Azure tenant/subscription credentials — stored per-consumer in that consumer's repo secrets
- PSGallery API keys — repo-level secret per ps-module consumer
- Any customer-specific identifier — never; use IIC canon for tests

## Rotating secrets

| Secret | Rotation cadence | How |
|---|---|---|
| `NUGET_API_KEY` | Per maintainer rotation | Regenerate on nuget.org, update `gh secret set NUGET_API_KEY --repo <repo>` |
| `GITHUB_TOKEN` | Per run (automatic) | No action — issued fresh per workflow run |

## Security: what not to log

- Never `Write-Host $env:GITHUB_TOKEN` or equivalent
- Never `Write-Host "$fixture | ConvertTo-Json"` if the fixture might contain customer data (shouldn't ever — IIC canon only)
- Never commit a `.env` file — `.gitignore` in `_common` excludes common dotenv patterns
