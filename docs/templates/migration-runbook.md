---
title: "Template: migration-runbook"
---

# Template: migration-runbook

Scaffold for an operational playbook — a runbook that guides a specific migration (e.g., VMware → Azure Local, Nutanix → Azure Local). Used by `azurelocal-nutanix-migration`.

## When to pick this variant

- The repo's primary output is **documentation** describing a migration procedure.
- Supporting scripts may exist, but they're incidental — the runbook is the deliverable.
- There's no module to test, no web UI to build, no IaC to validate at PR time.

## What's in the template

```text
templates/migration-runbook/
├── .github/workflows/
│   └── deploy-docs.yml           # Calls reusable-mkdocs-deploy.yml
├── mkdocs.yml
└── README.md
```

Three files — minimal. The rest is up to the runbook author.

## Recommended docs structure

```text
docs/
├── index.md                      # Overview of the migration scope
├── prerequisites.md              # What must be true before starting
├── phases/
│   ├── 01-inventory.md           # Source environment inventory
│   ├── 02-target-prep.md         # Target (Azure Local) preparation
│   ├── 03-cutover.md             # Migration execution
│   ├── 04-validation.md          # Post-cutover validation
│   └── 05-rollback.md            # If things go wrong
├── tooling/
│   ├── scripts.md                # Supporting scripts (if any)
│   └── references.md             # Vendor docs, KB links
└── runbooks/
    └── <specific-scenario>.md
```

`mkdocs.yml` nav should mirror this structure — edit the template's stub nav after scaffolding.

## Consumer-authored supporting material

Unlike `ps-module` (which expects a `.psd1`), migration runbooks have no required file set beyond the 5 canonical required files. Consumers typically add:

- `scripts/` — small utilities (PowerShell, bash, Python) that automate parts of the cutover
- `fixtures/` — anonymised inventory samples (use IIC canon — never real customer data)
- `reference/` — vendor PDFs, links, screenshots

## What this variant doesn't do

- No Pester tests
- No PSGallery publish
- No Vitest / Jest
- No Bicep or Terraform validation

It's a docs-first variant. If the runbook grows beyond pure docs (e.g., ships a PS module), consider splitting into two repos or re-scaffolding as `ps-module`.

## Tokens used

| Token | Usage |
|---|---|
| `{{REPO_NAME}}` | `mkdocs.yml` repo_url, README |
| `{{DESCRIPTION}}` | README, mkdocs site description |
| `{{YEAR}}` | Copyright |

## Post-scaffold steps

1. Author `docs/index.md` explaining the migration scope
2. Flesh out `mkdocs.yml` nav
3. Add phase pages as above
4. Commit supporting scripts if any
5. Tag releases when a runbook version is "complete" for a given source platform

## Example consumer

- [`azurelocal-nutanix-migration`](https://github.com/AzureLocal/azurelocal-nutanix-migration)

## Relationship to LEDGER (v0.3.0)

When LEDGER ships (migration inventory differ, see [ADR-0004](https://github.com/AzureLocal/platform/blob/main/decisions/0004-testing-toolset-classification.md)), migration-runbook repos will be its primary consumers. LEDGER provides the before/after inventory diff contract; the runbook supplies the actual inventories. No template change needed ahead of time — LEDGER adoption is additive.

## Related

- [Templates overview](overview.md)
- [ADR 0004 — testing toolset classification](https://github.com/AzureLocal/platform/blob/main/decisions/0004-testing-toolset-classification.md)
