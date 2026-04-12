# Standards

**Single source of truth for AzureLocal organization standards.**

These documents were previously duplicated across 7+ repos. In Phase 1 of the platform rollout, all local copies were deleted and replaced with a [`STANDARDS.md`](../templates/_common/STANDARDS.md) stub that points here.

The docs site at [`AzureLocal.github.io/azurelocal.github.io/standards`](https://azurelocal.github.io/azurelocal.github.io/standards) continues to render these for humans — it pulls from this folder via a scheduled sync workflow.

## Files

| File | Scope |
|---|---|
| `index.mdx` | Entry point — table of contents |
| `automation.mdx` | Automation conventions (PowerShell, Ansible, Azure CLI, Bicep helpers) |
| `documentation.mdx` | How to write and structure docs across the org |
| `examples.mdx` | Fictional company / IIC canon rules for sample data |
| `infrastructure.mdx` | IaC conventions (Bicep, Terraform, ARM) |
| `naming.mdx` | Repo, branch, tag, variable, resource naming |
| `new-repo-setup.mdx` | Process for creating a new AzureLocal repo |
| `repository-management.mdx` | Per-repo structure, CODEOWNERS, branch protection |
| `scripting.mdx` | PowerShell authoring conventions |
| `solutions.mdx` | How solution repos are organized |
| `variables.mdx` | Canonical variable registry |
| `testing.mdx` | MAPROOM / TRAILHEAD / IIC testing conventions |

## Editing

Changes to any standards doc require an ADR in [`../decisions/`](../decisions) (except typo fixes). See [`docs/standards/contributing.md`](../docs/standards/contributing.md) for the PR workflow.

## Consuming from a product repo

See [`docs/standards/consuming.md`](../docs/standards/consuming.md). TL;DR: put a `STANDARDS.md` stub at your repo root linking to this folder — do not copy the files locally.
