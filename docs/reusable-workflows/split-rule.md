---
title: Workflow split rule
---

# The workflow split rule

Reusable workflows for AzureLocal live in one of two org repos. Which repo owns which workflow follows a single rule:

> **`.github` owns governance workflows — those that apply to every repo regardless of its stack.**
>
> **`platform` owns stack-specific workflows — those that apply only to certain repo types.**

## Why split at all?

Both could technically live in one repo. The split exists because:

1. **`.github` has a distinct purpose** — GitHub-metadata governance (community health, org profile, enforcement). Overloading it with TypeScript build logic dilutes that purpose.
2. **Discovery** — a new contributor browsing `AzureLocal/.github` looking for "how do I contribute" shouldn't wade past stack-specific CI internals.
3. **Release cadence** — governance workflows change rarely. Stack-specific workflows evolve with frameworks and tooling. Different cadences want different homes.
4. **Blast radius** — a broken governance workflow breaks every repo. A broken stack-specific workflow breaks only the repos of that stack. Separating reduces the risk surface of any one change.

## The current lineup

| Workflow | Owner | Why |
|---|---|---|
| `reusable-add-to-project.yml` | `.github` | Every repo uses the same org project board |
| `reusable-release-please.yml` | `.github` | Every repo uses Conventional Commits and release-please |
| `reusable-validate-structure.yml` | `.github` | Every repo must have README / LICENSE / CHANGELOG / .gitignore / docs |
| `reusable-ps-module-ci.yml` | `platform` | Only PS module repos use Pester and PSGallery |
| `reusable-ts-web-ci.yml` | `platform` | Only TS web app repos use vitest and pnpm |
| `reusable-iac-validate.yml` | `platform` | Only IaC repos use tflint, bicep build, arm-ttk |
| `reusable-mkdocs-deploy.yml` | `platform` | Only repos with MkDocs sites use this |
| `reusable-maproom-run.yml` | `platform` | Only repos with MAPROOM tests use this |
| `reusable-drift-check.yml` | `platform` | Platform's own conformance-reporting tool |

## Edge cases

**"What about a workflow that's governance but stack-specific?"** Example: if release-please published to PSGallery automatically — that'd blur the line. We'd put the PSGallery publish in `reusable-ps-module-ci.yml` (platform, stack-specific) and keep the release-please tagging separate in `.github`.

**"What if a workflow is universal but lives in platform?"** New universal workflows should go in `.github`. If one ends up in platform for convenience, revisit during the next major version.

**"What about a workflow only ONE repo uses?"** If only one repo uses it, it's not reusable. Keep it local to that repo. A reusable workflow must have at least two plausible consumers.

## Versioning per owner

- `.github` workflows are versioned by tag on the `.github` repo.
- `platform` workflows are versioned by tag on the `platform` repo.

Consumers reference each separately:

```yaml
jobs:
  governance:
    uses: AzureLocal/.github/.github/workflows/reusable-release-please.yml@v1
  stack:
    uses: AzureLocal/platform/.github/workflows/reusable-ps-module-ci.yml@v1
```

## If you're unsure where to put a new workflow

Ask one question: *does every AzureLocal repo benefit from this, or only a subset?*

- **Every repo** → propose in `.github`, open an ADR in `platform/decisions/` since it crosses the org
- **Subset of repos by stack** → `platform`, with an ADR

## Related

- [Consumer patterns](consumer-patterns.md) — copy-paste examples
- [Versioning](versioning.md) — how to pin, how to bump
- [ADR 0005 — reusable-workflow-split](https://github.com/AzureLocal/platform/blob/main/decisions/0005-reusable-workflow-split.md)
