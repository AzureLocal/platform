# ADR 0003 — MAPROOM framework & IIC canon centralization

- **Status**: Accepted
- **Date**: 2026-04-12
- **Accepted**: 2026-04-13 (unblocked by ADR-0004)
- **Deciders**: @kristopherjturner

## Context

MAPROOM — the contract-testing framework that asserts a live target (cluster, host pool, tenancy, fleet) matches an expected shape encoded as a JSON fixture — currently lives in [`azurelocal-s2d-cartographer/tests/maproom/`](https://github.com/AzureLocal/azurelocal-s2d-cartographer/tree/main/tests/maproom). The IIC canon (`iic-org.json`, `iic-cluster-01.json`, `iic-networks.json`) — the canonical test data representing the fictional Infinite Improbability Corp environment — lives alongside it.

Three problems today:

1. **Framework is repo-locked.** A second consumer (`azurelocal-ranger`) exists; a third (`azurelocal-avd`, `azurelocal-sofs-fslogix`, etc.) is blocked on "go copy the framework, maybe." Forking the framework into each repo recreates the drift problem [ADR-0002](./0002-standards-single-source.md) just solved for standards.
2. **IIC canon is repo-locked.** Same problem. Every consumer wants to assert "my cluster matches the IIC canonical shape"; none can without vendoring the canon.
3. **Framework is S2D-shaped.** MAPROOM's vocabulary (pools, tiers, volumes, witness, fault domains) encodes cluster-fabric assumptions that don't fit non-fabric consumers (AVD host pools, FSLogix profile fleets, VM-conversion inventories, Nutanix source manifests).

TRAILHEAD (scenario runner for user journeys) has the same shape of problem but smaller surface — it's templated enough today that centralizing it is straightforward; the open questions are about MAPROOM.

## Decision

**Proposed** — not yet accepted. The shape of the decision:

1. Move MAPROOM framework → [`platform/testing/maproom/framework/`](../testing/maproom/). Ship as PowerShell module `AzureLocal.Maproom` (manifest + `.psm1`). Consumers reference by module name.
2. Move TRAILHEAD harness + templates → [`platform/testing/trailhead/`](../testing/trailhead/). Consumers reference by path or, if module-shaped content emerges, `AzureLocal.Trailhead` sibling module.
3. Move IIC canon → [`platform/testing/iic-canon/`](../testing/iic-canon/). Consumers reference canonical fixtures by path; additional per-domain canons (AVD, FSLogix, Nutanix) land here as they're authored, not in consumer repos.
4. Publish schemas under [`platform/testing/maproom/schema/`](../testing/maproom/): `fixture.schema.json`, `iic-canon.schema.json`. All consumer fixtures validate against these in CI.
5. Framework surface (what primitives `AzureLocal.Maproom` exposes) is **under classification review** in platform issue [#3](https://github.com/AzureLocal/platform/issues/3). This ADR is blocked on that issue — Phase 2 implementation does not start until classification lands.

## Consequences

### Positive

- One canonical MAPROOM implementation; no per-repo forks.
- IIC canon is genuinely canonical — the same JSON powers every consumer's contract tests.
- Schema-gated fixtures catch drift between consumers and framework at PR time.
- Non-S2D consumers become plausible — the classification work (issue #3) ensures the framework surface actually fits their shapes.

### Negative

- Consumers pay a coupling cost — bumping `AzureLocal.Maproom` is a platform PR, and consumers see the new version on schedule, not on demand.
- Module-based distribution means consumers need either a Git-referenced install or (eventually) PSGallery publication. Phase 2 uses Git reference; PSGallery is deferred until the public surface stabilizes.
- Decoupling the framework from S2D-specific assumptions is non-trivial and is the actual design work — captured in issue [#3](https://github.com/AzureLocal/platform/issues/3).

### Neutral

- `azurelocal-s2d-cartographer` becomes the first migration — its current `tests/maproom/` is the reference implementation being ported, and once ported it becomes the first consumer of the centralized framework.
- `azurelocal-ranger` becomes the **second** consumer, deliberately chosen — two consumers is the minimum signal that the framework isn't secretly S2DCartographer-shaped.

### Affected repos / owners

- **`AzureLocal/platform`**: gains `testing/maproom/`, `testing/trailhead/`, `testing/iic-canon/`. Phase 2 work.
- **`azurelocal-s2d-cartographer`**: existing `tests/maproom/` is re-pointed at the platform module. Local copy of framework code is deleted; fixtures + tests remain.
- **`azurelocal-ranger`**: switches to consuming platform MAPROOM. Second-consumer validation.
- **All other product repos**: opt in as their use case matures; required testing surface is documented in [Testing Standards](../standards/testing.mdx).

## Alternatives considered

- **Keep MAPROOM in S2DCartographer, let consumers reference it directly.** Rejected — same drift pattern standards had; cross-repo references are fragile and discoverability is poor.
- **Fork MAPROOM into each consuming repo.** Rejected — this is the current state and is exactly what's not working.
- **Publish `AzureLocal.Maproom` to PSGallery in v1.** Rejected for now — surface will churn during Phase 2; PSGallery deferred until v0.3 at earliest, probably v1.0.
- **Generalize the framework in-place (inside `azurelocal-s2d-cartographer`).** Rejected — the repo's identity is S2D, not platform tooling; generalization would make the repo's purpose less clear.

## Status

Proposed 2026-04-12. Blocked on issue [#3](https://github.com/AzureLocal/platform/issues/3) — classification rubric for testing toolsets must land before this ADR can be accepted. Phase 2 implementation does not start until that resolves.
