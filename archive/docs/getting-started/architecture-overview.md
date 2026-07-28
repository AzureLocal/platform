---
title: Architecture overview
---

# Architecture overview

How `AzureLocal/platform` fits into the broader AzureLocal organization.

## The three central repos

```mermaid
graph LR
    subgraph "Org-level repos"
        G[AzureLocal/.github<br/>GitHub-metadata governance]
        P[AzureLocal/platform<br/>Developer tooling]
        S[azurelocal.github.io<br/>Community docs site]
    end
    subgraph "Product repos (~25)"
        R1[azurelocal-ranger]
        R2[azurelocal-s2d-cartographer]
        R3[azurelocal-surveyor]
        RN[...other product repos]
    end
    G -->|reusable workflows: add-to-project, release-please, validate-structure| R1
    G -->|same| R2
    G -->|same| R3
    G -->|same| RN
    P -->|reusable workflows: ps-module-ci, ts-web-ci, iac-validate, mkdocs-deploy, maproom-run, drift-check| R1
    P -->|same| R2
    P -->|same| R3
    P -->|same| RN
    P -->|standards/*.mdx via scheduled sync| S
    R1 -->|STANDARDS.md link| P
    R2 -->|STANDARDS.md link| P
    R3 -->|STANDARDS.md link| P
    RN -->|STANDARDS.md link| P
```

## Who owns what

| Responsibility | Repo | Examples |
|---|---|---|
| GitHub-metadata governance | `AzureLocal/.github` | `CONTRIBUTING.md`, `SECURITY.md`, PR template, issue templates, org profile README |
| Governance reusable workflows | `AzureLocal/.github` | `reusable-add-to-project`, `reusable-release-please`, `reusable-validate-structure` |
| Canonical standards | `AzureLocal/platform` | `standards/naming.mdx`, `standards/testing.mdx`, all `.mdx` files |
| Stack-specific reusable workflows | `AzureLocal/platform` | `reusable-ps-module-ci`, `reusable-ts-web-ci`, `reusable-iac-validate`, `reusable-mkdocs-deploy` |
| MAPROOM framework | `AzureLocal/platform` | `testing/maproom/framework/`, generators, harness, schema |
| TRAILHEAD templates | `AzureLocal/platform` | `testing/trailhead/templates/` |
| IIC canon | `AzureLocal/platform` | `testing/iic-canon/*.json` |
| Repo bootstrap scripts | `AzureLocal/platform` | `repo-management/org-scripts/New-AzureLocalRepo.ps1` |
| Drift audit | `AzureLocal/platform` | `drift-audit.yml` workflow + `Invoke-RepoAudit.ps1` |
| Community-facing docs rendering | `azurelocal.github.io` | Docusaurus site that renders standards pulled from platform |
| Product source code | Product repos | `Modules/`, `src/`, `bicep/`, etc. |
| Product-specific fixtures | Product repos | `tests/maproom/Fixtures/*.json` per product |

## Data flow — standards update

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant P as AzureLocal/platform
    participant S as azurelocal.github.io
    participant R as Product repo

    Dev->>P: PR against standards/*.mdx
    P->>P: platform-ci.yml runs, ADR required
    P->>P: Merge + release-please tag
    P->>S: Scheduled sync workflow pulls standards/*.mdx
    S->>S: Docusaurus rebuild, site redeploys
    R->>P: STANDARDS.md link → same content, always current
```

## Data flow — new repo creation

```mermaid
sequenceDiagram
    participant Dev as Maintainer
    participant Script as New-AzureLocalRepo.ps1
    participant T as templates/
    participant GH as GitHub API

    Dev->>Script: -Type iac-solution -Name azurelocal-foo
    Script->>T: Merge _common/ + iac-solution/
    Script->>Script: Token substitution
    Script->>GH: gh repo create AzureLocal/azurelocal-foo
    Script->>GH: git push scaffolded tree
    Script->>GH: Apply branch protection (via Sync-BranchProtection)
    Script->>GH: Apply canonical labels (via Sync-Labels)
    Script-->>Dev: Repo ready, CI green on first commit
```

## Versioning and release cadence

- **Platform**: `release-please`-driven, SemVer, monorepo mode. Major tag (`v1`, `v2`) is what consumers pin.
- **Reusable workflows**: consumers pin `@v1` (major). Minor/patch updates propagate automatically. Breaking change → new `v2` tag + six-month dual-support.
- **Standards**: versioned as part of the platform release stream. Sync workflow in `azurelocal.github.io` pulls on release tag.
- **IIC canon**: frozen post-v1. Changes require ADR.

See [`governance/versioning.md`](../governance/versioning.md) and [`governance/breaking-changes.md`](../governance/breaking-changes.md).

## Further reading

- [What is platform](what-is-platform.md)
- [Why platform exists](why-platform-exists.md)
- [Glossary](glossary.md)
- [ADR 0001 — Create platform repo](https://github.com/AzureLocal/platform/blob/main/decisions/0001-create-platform-repo.md)
