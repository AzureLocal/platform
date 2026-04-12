# Repo Management

Centralized templates and automation for managing the AzureLocal organization's repositories.

## Structure

```text
repo-management/
├── templates/       — canonical content for each repo's /repo-management folder
└── org-scripts/     — scripts that act on the entire org (audit, sync, bootstrap)
```

## `templates/`

The content every product repo's `/repo-management` folder starts with. Each product repo keeps a thin local overlay; the heavy content lives here.

| File | Purpose |
|---|---|
| `automation.md` | Automation inventory and conventions for the repo |
| `README.md` | Local repo-management folder's README template |
| `setup.md` | One-time setup notes |
| `scripts-roadmap.md` | Planned automation additions |

## `org-scripts/`

Scripts that operate on every repo in the AzureLocal org. Run from a local clone of `platform` against the org.

| Script | Purpose |
|---|---|
| `Invoke-RepoAudit.ps1` | Drift detection — compares every repo against canonical standards |
| `Sync-Labels.ps1` | Applies canonical GitHub label set (source: `labels.json`) |
| `Sync-BranchProtection.ps1` | Applies uniform branch protection rules |
| `Sync-CommonFiles.ps1` | Pushes `LICENSE`, `.gitignore`, `.editorconfig`, `CODEOWNERS` updates |
| `New-AzureLocalRepo.ps1` | Bootstrap a new repo from [`templates/`](../templates) |
| `labels.json` | Canonical label definitions |

## Documentation

See [`docs/repo-management/`](../docs/repo-management) for detailed usage, examples, and troubleshooting.
