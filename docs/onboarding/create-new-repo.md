---
title: Create a new repo
---

# Create a new repo

Creating a new AzureLocal org repo is a single command that:

1. Merges the chosen template variant with the `_common` scaffolding
2. Substitutes tokens (`{{REPO_NAME}}`, `{{MODULE_NAME}}`, etc.)
3. Creates the GitHub repo under AzureLocal
4. Pushes the scaffolded tree
5. Applies canonical labels
6. Applies canonical branch protection

## The command

```powershell
./repo-management/org-scripts/New-AzureLocalRepo.ps1 `
    -Type ps-module `
    -Name azurelocal-newthing `
    -Description "Short description of what this repo does"
```

## Parameters

| Parameter | Required | Purpose |
|---|---|---|
| `-Type` | Yes | One of `ps-module`, `ts-web-app`, `iac-solution`, `migration-runbook`, `training-site` |
| `-Name` | Yes | Must match `^azurelocal-[a-z0-9][a-z0-9-]{1,40}$` |
| `-Description` | Yes | Public description; becomes the GitHub repo description and docs site subtitle |
| `-ModuleName` | No | PascalCase module name. Auto-derived from `-Name` if omitted (e.g., `azurelocal-ranger` → `AzureLocalRanger`) |
| `-DryRun` | No | Print the plan; don't create anything |
| `-SkipBranchProtection` | No | Skip the `Sync-BranchProtection.ps1` step |
| `-SkipLabels` | No | Skip the `Sync-Labels.ps1` step |
| `-PlatformRoot` | No | Defaults to the current platform clone |

## Prerequisites

- `gh` CLI authenticated with `repo` and `admin:org` scopes.
- Platform repo cloned locally (the script reads `templates/_common/` + `templates/<Type>/`).
- You have admin rights on the AzureLocal org to create repos and set protection.

## Dry-run first

```powershell
./repo-management/org-scripts/New-AzureLocalRepo.ps1 `
    -Type ts-web-app `
    -Name azurelocal-cockpit `
    -Description "Ops dashboard for Azure Local fleets" `
    -DryRun
```

Dry run prints the merged file tree, token substitutions, and the `gh repo create` / protection / label commands it would run. Verify before running without `-DryRun`.

## Choosing the `-Type`

| If the repo will... | Use |
|---|---|
| Export PowerShell cmdlets/functions consumed by other repos or runbooks | `ps-module` |
| Be a TypeScript / React / Next.js web UI | `ts-web-app` |
| Contain Bicep / Terraform / ARM templates that deploy Azure resources | `iac-solution` |
| Host a migration playbook (e.g., source → Azure Local inventory cutover) | `migration-runbook` |
| Be training / course material published as a static site | `training-site` |

Reference: [Templates → Overview](../scaffolds/overview.md) compares the variants in detail.

## Token substitution

Tokens in template files are replaced at scaffold time:

| Token | Value |
|---|---|
| `{{REPO_NAME}}` | From `-Name` |
| `{{MODULE_NAME}}` | From `-ModuleName` or derived from `-Name` |
| `{{DESCRIPTION}}` | From `-Description` |
| `{{REPO_TYPE}}` | From `-Type` |
| `{{YEAR}}` | Current year |
| `{{AUDIT_DATE}}` | Today's date (populates `.azurelocal-platform.yml` `lastAudited`) |
| `{{MODULE_GUID}}` | Fresh GUID for the `.psd1` manifest |
| `{{ID_PREFIX}}` | Derived from module name (for log prefixes, etc.) |
| `{{MAPROOM}}` | `true` / `false` based on repo type |
| `{{WORKFLOWS_ADOPTED}}` | Comma-separated list of workflow adoptions |

Filename tokens (e.g., `{{MODULE_NAME}}.psd1`) are renamed during the scaffold loop.

## What the script does in order

1. **Validate inputs** (name pattern, type in enum, description present)
2. **Merge** `templates/_common/` + `templates/<Type>/` into a temp directory
3. **Substitute** `{{TOKEN}}` placeholders in both file contents and filenames
4. **`gh repo create`** — public, MIT, under AzureLocal org, initial `main` branch
5. **`git push`** — the scaffolded tree goes up
6. **`Sync-BranchProtection.ps1`** against the new repo unless `-SkipBranchProtection`
7. **`Sync-Labels.ps1`** against the new repo unless `-SkipLabels`

## Post-creation

The new repo is immediately picked up by:

- `drift-audit.yml` (monthly org-wide audit on platform)
- The new repo's own `drift-check.yml` (weekly self-check)

Things you still do manually:

- Add actual source code (the template is a scaffold, not a working app)
- Enable GitHub Pages in repo settings if the repo ships a docs site (`deploy-docs.yml` requires this)
- Invite collaborators (single-maintainer org today; this is usually a no-op)

## If the command fails

| Error | Fix |
|---|---|
| `gh: unknown command 'repo'` | Update `gh` CLI: `gh --version` should be ≥ 2.40 |
| `HTTP 403` on repo create | `gh auth refresh -s repo,admin:org` |
| `template path not found` | Confirm you're running from the platform repo root |
| `name does not match pattern` | Name must start with `azurelocal-`, all lowercase, hyphens allowed |

## Related

- [Templates → Overview](../scaffolds/overview.md) — what each variant contains
- [Repo management → New-repo bootstrap](../repo-management/new-repo-bootstrap.md) — the script internals
- [Adopt from existing repo](adopt-from-existing-repo.md) — for repos that already exist
