---
title: Templates
---

# Templates

Platform ships five template variants plus a shared `_common` scaffold. Together they let `New-AzureLocalRepo.ps1` spin up any AzureLocal repo with one command.

## Variants

| Variant | When | Page |
|---|---|---|
| `ps-module` | PowerShell module (exported cmdlets, Pester, PSScriptAnalyzer) | [ps-module](ps-module.md) |
| `ts-web-app` | TypeScript / React / Vite web app | [ts-web-app](ts-web-app.md) |
| `iac-solution` | Bicep / Terraform / ARM infrastructure | [iac-solution](iac-solution.md) |
| `migration-runbook` | Operational playbook for a specific migration (e.g., Nutanix → Azure Local) | [migration-runbook](migration-runbook.md) |
| `training-site` | Course / training material served as a static site | [training-site](training-site.md) |

## Shared

- [`_common`](https://github.com/AzureLocal/platform/tree/main/templates/_common) — files copied into every variant: `CHANGELOG.md`, `CODEOWNERS`, `STANDARDS.md`, `.editorconfig`, `.gitignore`, `.azurelocal-platform.yml`, and 4 GitHub Actions workflows.

## Extending

- [Authoring a new variant](authoring-new-variant.md) — requirements, ADR flow, token set.

## How they're used

```powershell
./repo-management/org-scripts/New-AzureLocalRepo.ps1 `
    -Type ts-web-app `
    -Name azurelocal-cockpit `
    -Description "Ops dashboard for Azure Local fleets"
```

The script merges `_common` + the chosen variant, substitutes tokens, and pushes the result as a new GitHub repo. See [New-repo bootstrap](../repo-management/new-repo-bootstrap.md) for internals.

## Layout on disk

```text
templates/
├── _common/                # 10 files
├── ps-module/              # 7 files
├── ts-web-app/             # 6 files
├── iac-solution/           # 5 files
├── migration-runbook/      # 3 files
└── training-site/          # 3 files
```

## Token set (shared across variants)

| Token | Expanded value |
|---|---|
| `{{REPO_NAME}}` | e.g., `azurelocal-cockpit` |
| `{{MODULE_NAME}}` | e.g., `AzureLocalCockpit` |
| `{{DESCRIPTION}}` | Free text |
| `{{REPO_TYPE}}` | One of the 5 variant names |
| `{{YEAR}}` | Current year |
| `{{AUDIT_DATE}}` | `yyyy-MM-dd` today |
| `{{MODULE_GUID}}` | New GUID (ps-module only) |
| `{{ID_PREFIX}}` | Short ID prefix derived from module name |
| `{{MAPROOM}}` | `true` for ps-module with tests, else `false` |
| `{{WORKFLOWS_ADOPTED}}` | Comma-separated list of adopted workflows |
