---
title: AzureLocal Platform
description: Centralized standards, reusable workflows, test frameworks, and scaffolding for the AzureLocal organization.
---

# AzureLocal Platform

> Centralized standards, reusable workflows, test frameworks, and scaffolding for the AzureLocal organization.

This is the documentation site for [`AzureLocal/platform`](https://github.com/AzureLocal/platform) — the single home for everything shared across the ~28 repos in the [AzureLocal](https://github.com/AzureLocal) GitHub organization.

## For AzureLocal repo maintainers

- **[What is platform](getting-started/what-is-platform.md)** — overview, scope, non-goals
- **[Why platform exists](getting-started/why-platform-exists.md)** — the drift problem this fixes
- **[Adopt platform from an existing repo](onboarding/adopt-from-existing-repo.md)** — step-by-step
- **[Create a new repo](onboarding/create-new-repo.md)** — end-to-end bootstrap
- **[Consuming reusable workflows](reusable-workflows/consumer-patterns.md)** — copy-paste examples per repo type

## For contributors to platform itself

- **[Architecture overview](getting-started/architecture-overview.md)** — how platform relates to `.github`, product repos, and the docs site
- **[ADR process](governance/adr-process.md)** — how to propose cross-cutting decisions
- **[Local setup](contributing/local-setup.md)** — clone, build docs, run tests
- **[Release process](contributing/release-process.md)** — how platform ships

## Sections

=== "Standards"

    Canonical organizational standards — single source of truth. [Browse standards](../standards/).

=== "Reusable workflows"

    GitHub Actions reusable workflows for PS module CI, TS web CI, IaC validate, MkDocs deploy, MAPROOM run, and drift check. [Workflow catalog](reusable-workflows/index.md).

=== "MAPROOM"

    Offline fixture-based testing framework. [MAPROOM overview](maproom/overview.md).

=== "TRAILHEAD"

    Live-cluster validation cycles. [TRAILHEAD overview](trailhead/overview.md).

=== "Templates"

    Five repo-type starter skeletons. [Template variants](templates/overview.md).

=== "Repo management"

    Org-wide automation — audit, sync, bootstrap. [Repo management overview](repo-management/overview.md).

## Companion repo

[`AzureLocal/.github`](https://github.com/AzureLocal/.github) owns GitHub-metadata governance (community-health files, org-level reusable workflows). Platform owns developer tooling. The split rule is documented in [`reusable-workflows/split-rule.md`](reusable-workflows/split-rule.md).
