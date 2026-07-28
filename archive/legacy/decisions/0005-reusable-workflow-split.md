# ADR 0005 — Reusable workflow split between `AzureLocal/.github` and `AzureLocal/platform`

- **Status**: Accepted
- **Date**: 2026-04-13
- **Deciders**: @kristopherjturner

## Context

Reusable GitHub Actions workflows for the AzureLocal org could plausibly live in either of two existing repos:

- [`AzureLocal/.github`](https://github.com/AzureLocal/.github) — the org's GitHub-metadata repo. Already hosts `reusable-add-to-project.yml`, `reusable-release-please.yml`, `reusable-validate-structure.yml`.
- [`AzureLocal/platform`](https://github.com/AzureLocal/platform) — the org's developer-tooling repo created by [ADR-0001](./0001-create-platform-repo.md). Hosts standards, testing frameworks, and templates.

Without a written rule, every new reusable workflow becomes a judgement call about where it should live. ADR-0001 deferred this decision; [`docs/reusable-workflows/split-rule.md`](../docs/reusable-workflows/split-rule.md) sketched the rule informally. This ADR formalises it.

The rule has practical consequences: each repo has its own release cadence (`.github` rarely changes, `platform` evolves with frameworks), its own contributor audience, and a different blast radius if a workflow regresses.

## Decision

Adopt the **stack-vs-governance split**:

> **`AzureLocal/.github` owns governance workflows — those that apply to every repo regardless of stack.**
>
> **`AzureLocal/platform` owns stack-specific workflows — those that apply only to certain repo types (PS module, TS web app, IaC, MkDocs site, MAPROOM consumer).**

Plus three corollaries:

1. **Single-consumer workflows are not reusable.** If only one repo uses a workflow, keep it local to that repo. A reusable workflow must have at least two plausible consumers.
2. **A workflow that's both universal and stack-specific** (e.g., release-please publishing to PSGallery) splits along the seam: the governance half goes to `.github`, the stack-specific half goes to `platform`.
3. **New universal workflows default to `.github`.** If one ends up in `platform` for convenience, revisit at the next major version.

## Consequences

### Positive

- **Discovery is predictable.** A contributor browsing `AzureLocal/.github` for "how do I contribute" doesn't wade past TypeScript build internals.
- **Release cadences are decoupled.** `platform` can ship breaking changes to a stack-specific workflow without forcing a `.github` release.
- **Blast radius is bounded.** A bad governance workflow breaks every repo. A bad stack-specific workflow breaks only the repos in that stack. The split limits the worst case.
- **Authority is clear for cross-repo conformance.** `Test-RepoConformance` (in `AzureLocal.Common`) only has to check that `deploy-docs.yml` references `AzureLocal/platform/.github/workflows/reusable-mkdocs-deploy.yml@<ref>` — never `.github` — because docs deployment is stack-specific by definition.

### Negative

- **Two repos to track for workflow versions.** Consumers pin two refs separately (`@v1` for `.github`, `@v1` for `platform`). Mitigated by documenting the canonical pin patterns in [`docs/reusable-workflows/consumer-patterns.md`](../docs/reusable-workflows/consumer-patterns.md).
- **Edge cases require a judgement.** When a workflow blurs the governance/stack line, the corollary in §Decision applies — but applying it correctly requires the maintainer to think carefully. ADR doesn't remove the judgement, only makes it consistent.
- **Two ADR-required surfaces.** Adding a new reusable workflow to either repo now requires an ADR. Documented overhead, accepted as the cost of explicit decisions.

### Neutral

- The current lineup (`reusable-add-to-project`, `reusable-release-please`, `reusable-validate-structure` in `.github`; the six `reusable-*` workflows in `platform`) already follows the rule. This ADR codifies the existing state, no migration required.

### Affected repos / owners

- **`AzureLocal/.github`**: no change today. Future governance workflows land here.
- **`AzureLocal/platform`**: no change today. Future stack-specific workflows land here.
- **All consumer repos**: no change today. Already pin against the correct repos per the rule.
- **Maintainer**: every new reusable workflow proposal should cite this ADR and state which side of the rule it falls on.

## Alternatives considered

- **Single repo for all reusable workflows** — rejected. Discovery and blast-radius arguments above. The cost of a second repo (already paid — both repos exist) is lower than the cost of mixing governance and stack content.
- **Per-stack repos** (`AzureLocal/ps-workflows`, `AzureLocal/ts-workflows`, etc.) — rejected. Would multiply the number of repos a consumer pins and the number of major-version axes to track. The current two-repo split is the minimum viable separation.
- **Live in the consumer repos themselves; share via copy-paste** — rejected. This is the drift problem [ADR-0001](./0001-create-platform-repo.md) and [ADR-0002](./0002-standards-single-source.md) already solved for standards. Rejected on the same grounds.
- **Keep the rule informal in `docs/reusable-workflows/split-rule.md` only** — rejected. Without an ADR the rule is a documentation note, not a governing decision. ADR makes it citable and reviewable.

## Status

Accepted 2026-04-13. Supersedes the "ADR 0004 — reusable-workflow-split" placeholder referenced in [ADR-0001](./0001-create-platform-repo.md). (ADR-0004 was repurposed for testing-toolset classification.)

The rule is also documented in user-facing form at [`docs/reusable-workflows/split-rule.md`](../docs/reusable-workflows/split-rule.md). When the ADR and the docs page diverge, this ADR wins; update the docs page accordingly.
