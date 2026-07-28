---
title: FAQ
---

# FAQ

## What is `AzureLocal/platform`?

Centralized standards, reusable workflows, test frameworks, and scaffolding for the ~28 repos in the AzureLocal org. Replaces the drift-prone practice of copying standards folders and CI workflows from one repo to the next.

## How is platform different from `AzureLocal/.github`?

`.github` owns **governance metadata** (community-health files, org-level reusable workflows for release-please/add-to-project/validate-structure). `platform` owns **developer tooling** (stack-specific reusable workflows, PS modules, testing frameworks, templates, ADRs, docs). See [reusable-workflows/split-rule](../reusable-workflows/split-rule.md).

## Do I have to adopt platform?

No — adoption is opt-in. But unadopted repos are flagged by `drift-audit.yml`'s monthly report. For the AzureLocal org's active repos, adoption is the plan.

## What version should I pin to?

While platform is pre-stable (v0.x.x), pin `@main`. When v1.0.0 ships, switch to `@v1`. `drift-check.yml` enforces the current rule.

## Can I use platform from a private repo?

Yes for consuming. Public → public and private → public reusable-workflow calls both work. Private reusable workflows **cannot** be called from public repos — which is why platform is public.

## Where do I file bugs?

[AzureLocal/platform issues](https://github.com/AzureLocal/platform/issues). Use labels `bug`, `docs`, `maproom`, `ci`, `template` to categorize.

## How do I propose a new standard?

PR on `docs/standards/<your-page>.md`. A new standards topic requires the ADR process — see [governance/adr-process](../governance/adr-process.md).

## How do I propose a new reusable workflow?

1. ADR explaining the problem and proposed contract.
2. Draft workflow as `reusable-<name>.yml`.
3. At least one consumer ready to adopt it immediately (proves the contract fits).
4. Platform PR with the workflow + consumer adoption + docs in one batch.

## What's MAPROOM vs TRAILHEAD vs IIC canon?

- **MAPROOM** — offline fixture-based testing framework. Runs in CI.
- **TRAILHEAD** — live-cluster cycles with evidence capture. Runs out-of-band.
- **IIC canon** — canonical fictional-company test data. Used by both.

See [getting-started/glossary](../getting-started/glossary.md) for the full glossary.

## Can I contribute if I'm not in the AzureLocal org?

Yes — external PRs welcome. Review cadence is slower (single-maintainer). Prefer small, focused PRs; discuss larger changes in an issue first.

## Does platform support languages other than PowerShell and TypeScript?

Today, no. Reusable workflows cover PS modules, TS web apps, and IaC (Bicep/Terraform). New language support requires an ADR + a consumer ready to adopt it on day one.

## How often does platform release?

When a qualifying commit lands on `main`, release-please opens/updates a release PR. Merge cadence is up to the maintainer — see [governance/release-cycle](../governance/release-cycle.md).

## What happens when I remove a consumer from the AzureLocal org?

Nothing in platform changes. The repo's `drift-audit.yml` entry disappears on the next monthly run because `Get-AzureLocalRepoInventory` reads live from `gh repo list`.

## How do I run tests for platform itself?

See [contributing/testing-platform](../contributing/testing-platform.md).

## Why is the canon called "IIC"?

Infinite Improbability Corp — a fictional company. Chosen so (a) no real customer data ever enters fixtures and (b) everyone on the team uses the same named cluster/nodes/subscription IDs in examples. See [maproom/iic-canon](../maproom/iic-canon.md) for the full reference.

## Who can merge to platform `main`?

Anyone listed in `CODEOWNERS` — currently just @kristopherjturner. Branch protection enforces one approval + passing CI.

## How do I extend a template variant?

Edit the files under `templates/<variant>/`. Every new run of `New-AzureLocalRepo.ps1 -Type <variant>` will pick up the change. To add a whole new variant, see [scaffolds/authoring-new-variant](../scaffolds/authoring-new-variant.md).

## What if I find a security issue?

See `SECURITY.md` at the repo root. Do not file a public issue for security disclosure.
