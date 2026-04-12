# Templates

Starter skeletons for new AzureLocal repos. Used by [`../repo-management/org-scripts/New-AzureLocalRepo.ps1`](../repo-management/org-scripts/New-AzureLocalRepo.ps1).

## Variants

| Variant | Used by | Stack |
|---|---|---|
| `_common/` | Every variant inherits these files | n/a (shared) |
| `ps-module/` | Ranger, S2DCartographer, toolkit | PowerShell module, Pester, PSGallery |
| `ts-web-app/` | Surveyor, azloflows | TypeScript, Vite, Tailwind, Vitest |
| `iac-solution/` | AVD, SOFS, AKS, SQL-HA, SQL-MI, VMs, ML-AI, IoT, custom-images | Bicep, Terraform, ARM, MkDocs |
| `migration-runbook/` | vm-conversion, vmware, nutanix, hydration | MkDocs + PowerShell playbooks |
| `training-site/` | training | MkDocs Material + curriculum structure |

## How New-AzureLocalRepo.ps1 uses these

```powershell
New-AzureLocalRepo.ps1 -Type iac-solution -Name azurelocal-foo -Description "…" -DryRun
```

Process:

1. Merges `_common/` + the chosen variant into a temp dir
2. Substitutes tokens (e.g. `<ModuleName>`, repo description)
3. `gh repo create AzureLocal/<Name>` (public, MIT)
4. `git push` the scaffolded tree
5. Applies canonical branch protection via [`Sync-BranchProtection.ps1`](../repo-management/org-scripts/Sync-BranchProtection.ps1)
6. Applies canonical labels via [`Sync-Labels.ps1`](../repo-management/org-scripts/Sync-Labels.ps1)

See [`docs/templates/overview.md`](../docs/templates/overview.md) for details.

## Adding a new variant

Requires an ADR. Cap is 5 variants for v1 per the architecture plan — a 6th triggers a design review.
