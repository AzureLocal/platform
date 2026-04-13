---
title: Authoring a new template variant
---

# Authoring a new template variant

Adding a new variant to `templates/` is an ADR-level change. This page covers when to do it, the mechanical steps, and the contract the new variant must satisfy.

## When to add a variant

| Signal | Add a variant? |
|---|---|
| One repo has a slightly different shape | No — handle in that repo |
| Two repos share a new shape not covered by existing variants | Probably yes — write an ADR |
| Future planned repos will share this shape | Yes |
| The shape exists but variant would duplicate an existing one | No — extend the existing variant |

Two-consumer rule (per [ADR-0003](https://github.com/AzureLocal/platform/blob/main/decisions/0003-maproom-iic-canon.md) philosophy): a variant is worth centralising only when at least two distinct consumers need it.

## ADR-first

1. File an issue describing the proposed variant.
2. Draft an ADR in `decisions/` covering:
    - What the variant is for (consumer shape).
    - What required files it adds beyond `_common`.
    - What tokens it uses (new ones, if any).
    - Which reusable workflows it expects.
    - What's explicitly out of scope.
3. Name at least one near-term consumer that will adopt it on day one.
4. Land the ADR; then ship the variant.

## Mechanical steps

### 1. Create the variant directory

```text
templates/<new-variant-name>/
├── .github/workflows/
│   └── deploy-docs.yml               # almost always present
├── ... variant-specific files ...
├── mkdocs.yml
└── README.md
```

Name convention: kebab-case, descriptive — e.g., `ai-service`, `aks-workload`.

### 2. Author token-substituted files

Use existing tokens where possible:

- `{{REPO_NAME}}`, `{{MODULE_NAME}}`, `{{DESCRIPTION}}`, `{{REPO_TYPE}}`, `{{YEAR}}`, `{{AUDIT_DATE}}`, `{{MODULE_GUID}}`, `{{ID_PREFIX}}`, `{{MAPROOM}}`, `{{WORKFLOWS_ADOPTED}}`

Only introduce a new token if existing ones don't cover the need. A new token is a breaking change to `New-AzureLocalRepo.ps1` — requires the ADR to mention it.

### 3. Update `New-AzureLocalRepo.ps1`

Add the new variant to the `-Type` `ValidateSet`:

```powershell
[ValidateSet('ps-module', 'ts-web-app', 'iac-solution', 'migration-runbook', 'training-site', 'new-variant-name')]
[string]$Type
```

If the variant introduces new token resolution logic (e.g., variant-specific default for `{{WORKFLOWS_ADOPTED}}`), add it in the resolver block.

### 4. Add docs

- New file: `docs/templates/<new-variant-name>.md` — follow the pattern of existing variant pages ([ps-module](ps-module.md) is a good reference)
- Update `docs/templates/index.md` variant table
- Update `docs/templates/overview.md` comparison table
- Update `mkdocs.yml` nav

### 5. Add a test case

Run `New-AzureLocalRepo.ps1 -Type <new-variant> -Name azurelocal-testvariant -Description "test" -DryRun` and confirm:

- Temp scaffold has the expected file tree
- Tokens are fully substituted (no `{{X}}` remaining in any file)
- Filename tokens are renamed

### 6. Open PR

Commit message:

```text
feat(templates): add <new-variant-name> variant

<summary>
<consumer motivation>

Closes #<adr-issue>
```

ADR lands in the same PR (or one immediately prior).

## What the variant must satisfy

- All 5 canonical required files (`CHANGELOG.md`, `mkdocs.yml`, `deploy-docs.yml`, `drift-check.yml`, `.azurelocal-platform.yml`) present in the merged output
- At least the 4 `_common` workflows (add-to-project, drift-check, release-please, validate-repo-structure) — merged automatically, don't duplicate
- `README.md` with the AzureLocal Platform badge
- `STANDARDS.md` stub — merged from `_common`

`Test-RepoConformance` will verify these on every new repo scaffolded with the variant.

## What the variant must NOT do

- Introduce a new required workflow without updating `drift-check` to know about it (drift-check's list of required files is authoritative; additions belong there in the same PR).
- Ship files that duplicate `_common` content with drift — that defeats the override model.
- Add platform-repo-scoped helpers (those go in `modules/powershell/` or `repo-management/org-scripts/`).

## Long-term maintenance

Once a variant exists, its file set is part of the public contract. Changes follow normal versioning:

- Add a new file → minor bump
- Remove or rename a file → major bump (existing scaffolded repos don't re-scaffold, but `Sync-CommonFiles.ps1` behaviour may change)
- Change token semantics → major bump

## Example — adding `aks-workload`

1. ADR in `decisions/NNNN-aks-workload-variant.md`.
2. Create `templates/aks-workload/` with `ci-aks.yml` (new reusable workflow), `mkdocs.yml`, `README.md`, possibly a `helm/` folder.
3. Define `{{WORKFLOWS_ADOPTED}}` default: `"ci-aks, drift-check, release-please"`.
4. Update `New-AzureLocalRepo.ps1` `-Type` enum.
5. Docs: `docs/templates/aks-workload.md`, update index and overview.
6. Consumer adoption: `azurelocal-aks` picks it up in the same release.

## Related

- [Templates overview](overview.md)
- [Repo management → New-repo bootstrap](../repo-management/new-repo-bootstrap.md)
- [Governance → ADR process](../governance/adr-process.md)
