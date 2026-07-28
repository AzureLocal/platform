---
title: Workflow matrix
---

# Workflow matrix

Which consumer repos call which reusable workflows.

## Current state

| Repo | repoType | mkdocs-deploy | iac-validate | ps-module-ci | ts-web-ci | maproom-run | drift-check |
|---|---|:-:|:-:|:-:|:-:|:-:|:-:|
| `azurelocal-platform` | platform | ✓ | — | — | — | — | — |
| `azurelocal-avd` | iac-solution | ✓ | ✓ (B+T) | — | — | — | ✓ |
| `azurelocal-sofs-fslogix` | iac-solution | ✓ | — | — | — | — | ✓ |
| `azurelocal-loadtools` | iac-solution | ✓ | — | — | — | — | ✓ |
| `azurelocal-copilot` | iac-solution | ✓ | — | — | — | — | ✓ |
| `azurelocal-vm-conversion-toolkit` | ps-module | ✓ | — | — | — | — | ✓ |
| `azurelocal-ranger` | ps-module | ✓ | — | ✓ | — | — | ✓ |
| `azurelocal-toolkit` | ps-module | ✓ | — | — | — | — | ✓ |
| `azurelocal-s2d-cartographer` | ps-module | ✓ | — | ✓ | — | ✓ | ✓ |
| `azurelocal-surveyor` | ts-web-app | ✓ | — | — | ✓ | — | ✓ |
| `azurelocal-training` | training-site | ✓ | — | — | — | — | ✓ |
| `azurelocal-nutanix-migration` | migration-runbook | ✓ | — | — | — | — | ✓ |

Legend:

- ✓ — calls the reusable workflow
- (B+T) — Bicep and Terraform both active
- — — not called

## Pinning

All consumers pin to `@main` while platform is pre-stable (v0.x.x). The `@v1` pin activates at v1.0.0.

## Ownership by workflow

| Workflow | Source of truth | Owner |
|---|---|---|
| `reusable-mkdocs-deploy.yml` | platform | @kristopherjturner |
| `reusable-iac-validate.yml` | platform | @kristopherjturner |
| `reusable-ps-module-ci.yml` | platform | @kristopherjturner |
| `reusable-ts-web-ci.yml` | platform | @kristopherjturner |
| `reusable-maproom-run.yml` | platform | @kristopherjturner |
| `reusable-drift-check.yml` | platform | @kristopherjturner |
| `reusable-release-please.yml` | `AzureLocal/.github` | @kristopherjturner |
| `reusable-add-to-project.yml` | `AzureLocal/.github` | @kristopherjturner |
| `reusable-validate-structure.yml` | `AzureLocal/.github` | @kristopherjturner |

The `.github` repo owns governance/metadata workflows; platform owns developer-tooling workflows. See [reusable-workflows/split-rule](../reusable-workflows/split-rule.md).

## When a row changes

- A consumer adopts a new workflow: update the consumer's `.azurelocal-platform.yml` `adopts.reusableWorkflows` list and this matrix page (same PR).
- A consumer drops a workflow: remove the caller workflow file, update `.azurelocal-platform.yml`, and this matrix page.
- A new consumer onboards: add a row below the existing ones in lexicographic order on repo name.

## Machine-readable source

`./repo-management/org-scripts/Invoke-RepoAudit.ps1 -Org AzureLocal` outputs a JSON report with the per-repo adoption state. Prefer that over trying to infer from this page — it will always be current.

```powershell
$report = Invoke-RepoAudit -Org AzureLocal -OutputPath drift-report.json
$report | Where-Object { $_.adopts.reusableWorkflows -contains 'maproom-run' }
```
