---
title: Glossary
---

# Glossary

Terms used throughout platform docs and across AzureLocal repos.

## MAPROOM

The **offline, fixture-based testing framework** for AzureLocal repos. Stands for "Map Room" — the place where you study terrain before going out to the field. MAPROOM tests run without a live cluster, in CI, against JSON fixtures that model real cluster state. Lives under [`testing/maproom/`](https://github.com/AzureLocal/platform/tree/main/testing/maproom).

Contrast with TRAILHEAD.

## TRAILHEAD

The **live-cluster validation framework** for AzureLocal repos. Stands for the place where you start a hike — you leave the map and actually walk the trail. TRAILHEAD cycles run a module or script against a real cluster, capture evidence, and compare to prior runs. Lives under [`testing/trailhead/`](https://github.com/AzureLocal/platform/tree/main/testing/trailhead).

Contrast with MAPROOM.

## IIC / IIC canon

**Infinite Improbability Corp** — the canonical fictional company used in every AzureLocal test fixture, synthetic example, and code demo. Domain `iic.local`, cluster `azlocal-iic-s2d-01`, nodes `azl-iic-n01` through `azl-iic-n04`. Never real customer names in committed test data.

"IIC canon" refers to the canonical JSON data files under [`testing/iic-canon/`](https://github.com/AzureLocal/platform/tree/main/testing/iic-canon) that serve as the single source of truth for IIC identity data.

## Fixture

A JSON file that models cluster state for MAPROOM tests. Fixtures live per-product under `tests/maproom/Fixtures/*.json` in each product repo. Must validate against [`testing/maproom/schema/fixture.schema.json`](https://github.com/AzureLocal/platform/tree/main/testing/maproom/schema).

## Breadcrumb

A small pointer file in a product repo that links back to platform. Every AzureLocal repo carries three breadcrumbs:

1. **README badge** — visible at the top of the repo's README
2. **`STANDARDS.md`** — a ~6-line stub at repo root linking to [`platform/standards`](https://github.com/AzureLocal/platform/tree/main/standards)
3. **`.azurelocal-platform.yml`** — machine-readable metadata declaring the repo's type and adopted platform features

See [`reference/file-manifest.md`](../reference/file-manifest.md).

## Drift / drift audit

**Drift** is when a product repo diverges from the canonical standards or templates — a stale `CONTRIBUTING.md`, a reusable workflow pinned to `@main`, a missing `STANDARDS.md` stub. The **drift audit** is the monthly scheduled workflow ([`drift-audit.yml`](https://github.com/AzureLocal/platform/tree/main/.github/workflows/drift-audit.yml)) that checks every repo and files an issue when drift is detected.

See [`repo-management/drift-audit.md`](../repo-management/drift-audit.md).

## Reusable workflow

A GitHub Actions workflow that other workflows call via `uses:`. Consumers pin by major version tag (`@v1`). Lives either in `AzureLocal/.github/.github/workflows/` (governance) or `AzureLocal/platform/.github/workflows/` (stack-specific).

See [`reusable-workflows/split-rule.md`](../reusable-workflows/split-rule.md).

## Template variant

One of the five repo-type skeletons used to bootstrap new repos: `ps-module`, `ts-web-app`, `iac-solution`, `migration-runbook`, `training-site`. Cap is five for v1 — a sixth triggers an ADR.

See [`templates/overview.md`](../templates/overview.md).

## ADR

**Architecture Decision Record**. A numbered, immutable document capturing a cross-cutting decision (rationale, consequences, alternatives). Stored in [`decisions/`](https://github.com/AzureLocal/platform/tree/main/decisions). Required for standards changes, new reusable workflows, IIC canon edits, and new template variants.

See [`governance/adr-process.md`](../governance/adr-process.md).

## Canonical

An adjective that means "the one source of truth — all other copies must defer to this". Canonical standards live in `platform/standards/`. Canonical IIC data lives in `platform/testing/iic-canon/`. Canonical labels live in `platform/repo-management/org-scripts/labels.json`. Etc.

## Consumer / consumer repo

Any AzureLocal repo that references platform via a reusable workflow, a `STANDARDS.md` stub, or an `AzureLocal.Common` module import. Every AzureLocal repo except `platform` and `.github` is a consumer.

## Dual-support window

When a reusable workflow releases a breaking change (`@v2`), the prior major (`@v1`) is maintained for six months so consumer repos can migrate on their own cadence. Documented per workflow in [`governance/breaking-changes.md`](../governance/breaking-changes.md).

## Platform version

The `platformVersion` field in `.azurelocal-platform.yml`. Declares which major version of platform contracts a repo adopts. Monotonic integer (starts at 1). Bumps when breaking changes land across the reusable-workflow surface.

## `@v1`

The git tag convention for major versions of reusable workflows. Consumers reference workflows like `uses: AzureLocal/platform/.github/workflows/reusable-ps-module-ci.yml@v1`. Pinning to `@main` fails the drift audit.
