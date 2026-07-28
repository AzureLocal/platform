---
title: Local setup
---

# Local setup

Set up a working copy of `AzureLocal/platform` for local development.

## Prerequisites

| Tool | Minimum | Purpose |
|---|---|---|
| `git` | 2.40+ | Source control |
| Python | 3.12 | MkDocs docs site build |
| PowerShell | 7.2+ | Module development and org-scripts |
| `gh` CLI | 2.40+ | Authenticated against `AzureLocal` org |
| Node.js | — | Optional, only for editing `ts-web-app` template |

## Clone and set up

```powershell
git clone https://github.com/AzureLocal/platform.git
cd platform
```

## Docs site

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1        # Windows
pip install -r requirements-docs.txt

mkdocs serve
```

Docs site renders at `http://127.0.0.1:8000/`. Edits to files under `docs/` auto-reload.

## PowerShell modules

```powershell
Import-Module ./modules/powershell/AzureLocal.Common/AzureLocal.Common.psd1 -Force
Import-Module ./testing/maproom/AzureLocal.Maproom.psd1 -Force
```

If a module needs re-importing after edits, use `-Force`.

## Running tests locally

```powershell
# Pester (when tests exist under modules/powershell/<module>/tests/)
Invoke-Pester ./modules/powershell/AzureLocal.Common/tests

# MAPROOM fixture validation
Import-Module ./testing/maproom/AzureLocal.Maproom.psd1 -Force
Test-MaproomFixture -Path ./testing/iic-canon/iic-azure-local-01.json
```

## Lint locally

```powershell
# Markdown
npx markdownlint-cli2 "**/*.md"

# YAML
pip install yamllint
yamllint -c .yamllint.yml .github/workflows mkdocs.yml .azurelocal-platform.yml
```

CI runs the same commands, so fixing locally first saves a round-trip.

## Authenticating the `gh` CLI

Most org-scripts require an authenticated `gh` CLI:

```powershell
gh auth login --scopes "repo,admin:org,workflow"
gh auth status          # verify scopes
```

Scope `admin:org` is needed only for scripts that touch labels, branch protection, or create repos (`Sync-Labels.ps1`, `Sync-BranchProtection.ps1`, `New-AzureLocalRepo.ps1`).
