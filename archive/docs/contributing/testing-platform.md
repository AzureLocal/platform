---
title: Testing platform
---

# Testing platform

Platform changes have a large blast radius — one bad reusable workflow breaks ~11 consumer repos. This page covers how to test platform code *before* merging.

## Local test layers

| Layer | Tool | Scope |
|---|---|---|
| Markdown | `markdownlint-cli2` | Every `*.md` under repo root (with `.markdownlint.json`) |
| YAML | `yamllint` | Workflows, `mkdocs.yml`, `.azurelocal-platform.yml` |
| PowerShell style | `PSScriptAnalyzer` | Every `*.ps1` / `*.psm1` under `modules/` and `repo-management/org-scripts/` |
| PowerShell unit | `Pester` | Tests under `modules/powershell/<module>/tests/` |
| MAPROOM schema | `Test-MaproomFixture` | Every fixture in `testing/iic-canon/` and template examples |

## Running each layer locally

```powershell
# Markdown
npx markdownlint-cli2 "**/*.md"

# YAML
yamllint -c .yamllint.yml .github/workflows mkdocs.yml .azurelocal-platform.yml

# PSScriptAnalyzer
Invoke-ScriptAnalyzer -Path ./modules/powershell -Recurse -Settings ./scripts/PSScriptAnalyzerSettings.psd1

# Pester
Invoke-Pester ./modules/powershell/AzureLocal.Common/tests

# MAPROOM
Import-Module ./testing/maproom/AzureLocal.Maproom.psd1 -Force
Test-MaproomFixture -Path ./testing/iic-canon/iic-azure-local-01.json
```

## CI: `platform-ci.yml`

Runs on every PR and push to `main`:

| Job | Runs |
|---|---|
| `markdownlint` | `DavidAnson/markdownlint-cli2-action@v17` over all `*.md` |
| `yaml-lint` | `yamllint` over workflows and YAML config |
| `pester` | Only when a `*.psm1` or `*.psd1` changes; runs `Invoke-Pester` |
| `link-check` | Broken-link check over docs (non-blocking warning) |

## Testing reusable workflows

Reusable workflows are harder — they're defined here but only *run* when a consumer calls them. Three strategies:

1. **Dry-run caller.** Push a test branch to a consumer repo with a PR-only caller and let it run.
2. **Use platform's own docs deploy.** `deploy-docs.yml` in platform calls `reusable-mkdocs-deploy.yml@main` — editing the reusable workflow and pushing to platform's `main` exercises it end-to-end.
3. **GitHub Actions local runner** (`act`) — not officially supported for our workflows but useful for syntax checks.

## Testing MAPROOM changes

When changing `testing/maproom/framework/`:

1. Run Pester against the framework itself: `Invoke-Pester ./testing/maproom/tests/`.
2. Re-validate every canon fixture: `Get-ChildItem ./testing/iic-canon/*.json | ForEach-Object { Test-MaproomFixture -Path $_.FullName }`.
3. Test against a real consumer. Locally clone `azurelocal-s2d-cartographer` and run its `tests/maproom/` Pester suite with the local platform module imported.

## Testing `AzureLocal.Common`

1. Unit tests: `Invoke-Pester ./modules/powershell/AzureLocal.Common/tests`.
2. Run against real org (read-only):

    ```powershell
    Import-Module ./modules/powershell/AzureLocal.Common/AzureLocal.Common.psd1 -Force
    $inventory = Get-AzureLocalRepoInventory -Org AzureLocal
    $inventory | Format-Table Name, PlatformVersion, RepoType
    ```

3. Dry-run destructive scripts:

    ```powershell
    ./repo-management/org-scripts/Sync-Labels.ps1 -DryRun
    ./repo-management/org-scripts/Sync-BranchProtection.ps1 -DryRun
    ```

## Never skip in CI

Do not merge with `--no-verify` or `[skip ci]`. The CI suite is small enough that skipping is never worth the risk of propagating breakage to consumer repos.
