---
title: What is platform
---

# What is platform

`AzureLocal/platform` is the single home for everything shared across the ~28 repositories in the [AzureLocal](https://github.com/AzureLocal) GitHub organization.

Product repos contain only product-specific code. Anything that would otherwise be copied between repos — standards docs, repo-management templates, testing frameworks, CI primitives, scaffolding — lives here exactly once.

## Scope

**In scope:**

- Canonical organizational standards (naming, documentation, scripting, infrastructure, testing, etc.)
- Reusable GitHub Actions workflows that are stack-specific (PS module, TS web, IaC, MkDocs, MAPROOM run, drift check)
- MAPROOM (offline fixture-based testing) framework
- TRAILHEAD (live-cluster validation) framework
- IIC canon — the canonical synthetic identity data for all test fixtures
- Starter templates for new repos (5 variants)
- Shared PowerShell modules (`AzureLocal.Common`, `AzureLocal.Maproom`)
- Org-wide automation scripts (repo audit, label sync, branch protection sync, common file sync, new-repo bootstrap)
- Platform's own full MkDocs documentation site

**Out of scope:**

- Product-specific source code (Modules, src/, bicep/, terraform/ stay in their product repos)
- GitHub community-health files (CONTRIBUTING, SECURITY, PR template, issue templates) — those live in [`AzureLocal/.github`](https://github.com/AzureLocal/.github)
- Governance reusable workflows (`reusable-add-to-project`, `reusable-release-please`, `reusable-validate-structure`) — those live in `.github`
- Product documentation that isn't about platform itself — that belongs in the product repo's docs

## Companion repo: `AzureLocal/.github`

`AzureLocal/.github` already exists and owns **GitHub-metadata governance**:

- Org profile README
- Organization-wide `CONTRIBUTING.md`, `SECURITY.md`, issue templates, PR template
- Three reusable workflows that apply to every repo regardless of stack: `reusable-add-to-project`, `reusable-release-please`, `reusable-validate-structure`

Platform owns **developer tooling**. The two don't overlap. The split rule is documented in [`reusable-workflows/split-rule.md`](../reusable-workflows/split-rule.md).

## Non-goals

- Platform does not try to replace `.github` — both repos exist side by side.
- Platform does not host product-specific fixtures or code — products keep their own.
- Platform does not publish any NPM or PyPI packages — PSGallery is reserved for `AzureLocal.Common` and `AzureLocal.Maproom`, and only after Phase 2 proves the interface.

## Learn more

- [Why platform exists](why-platform-exists.md) — the drift problem this fixes
- [Architecture overview](architecture-overview.md) — how the pieces fit together
- [Adopt platform from an existing repo](../onboarding/adopt-from-existing-repo.md) — step-by-step
- [Glossary](glossary.md) — MAPROOM, TRAILHEAD, IIC, canon, breadcrumb, drift
