---
title: "Template: training-site"
---

# Template: training-site

Scaffold for a static training-content site — courses, workshops, self-paced labs. Used by `azurelocal-training`.

## When to pick this variant

- The repo's primary output is **training material** rendered as a static site.
- Chapters / modules / labs organised as MkDocs pages.
- No app-like interactivity beyond what Material for MkDocs provides natively (search, tabs, code-copy, admonitions).

## What's in the template

```text
templates/training-site/
├── .github/workflows/
│   └── deploy-docs.yml           # Calls reusable-mkdocs-deploy.yml
├── mkdocs.yml
└── README.md
```

Three files — identical structure to `migration-runbook`, but with a training-oriented `mkdocs.yml` nav suggestion.

## Recommended docs structure

```text
docs/
├── index.md                      # Course overview, prerequisites, outcomes
├── module-01/
│   ├── index.md                  # Module landing
│   ├── lesson-01.md
│   ├── lesson-02.md
│   └── exercises.md
├── module-02/
│   └── ...
├── labs/
│   ├── lab-01-deploy-local.md
│   └── lab-02-validate.md
├── reference/
│   ├── glossary.md
│   └── further-reading.md
└── completion/
    └── checklist.md
```

Edit `mkdocs.yml` nav after scaffolding to match.

## Theming conventions

Material for MkDocs provides enough for most training content. Recommended extras:

- **`pymdownx.details`** — for collapsible exercise solutions
- **`pymdownx.tabbed`** — for PowerShell / bash / Azure CLI variants of the same command
- **`admonition`** — for callouts (Note, Warning, Tip)
- **`pymdownx.superfences` + mermaid2** — for diagrams

All are enabled in the default `mkdocs.yml` already.

## Exercises and solutions

Pattern:

````markdown
## Exercise: Deploy a two-node cluster

Using `New-AzureLocalCluster`, deploy a two-node cluster named `azlocal-iic-lab-01`.

??? success "Solution"
    ```powershell
    New-AzureLocalCluster `
        -Name azlocal-iic-lab-01 `
        -NodeCount 2 `
        -Subscription $env:SUB_ID
    ```
````

The `???` makes the solution collapsible.

## Fictional content and the IIC canon

Use the IIC canon for all example values — cluster names, node names, subscription IDs, resource groups. See [IIC canon](../maproom/iic-canon.md).

Do not invent alternative fictional companies per course. One canon, one set of fictional values, used everywhere.

## What this variant doesn't do

- No PS modules
- No web app framework
- No IaC validation
- No Pester / Vitest tests

Training content is reviewed for correctness, not machine-validated.

## Tokens used

| Token | Usage |
|---|---|
| `{{REPO_NAME}}` | `mkdocs.yml` repo_url, README |
| `{{DESCRIPTION}}` | README, mkdocs site description |
| `{{YEAR}}` | Copyright |

## Post-scaffold steps

1. Author `docs/index.md` with course overview
2. Build out module structure
3. Add labs and exercises
4. Enable GitHub Pages in repo settings so `deploy-docs.yml` can publish

## Example consumer

- [`azurelocal-training`](https://github.com/AzureLocal/azurelocal-training)

## Related

- [Templates overview](overview.md)
- [Reusable workflow: mkdocs-deploy](../reusable-workflows/mkdocs-deploy.md)
- [IIC canon](../maproom/iic-canon.md)
