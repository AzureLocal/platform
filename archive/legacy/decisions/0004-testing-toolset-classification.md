# ADR 0004 — Testing toolset classification rubric

- **Status**: Accepted
- **Date**: 2026-04-13
- **Deciders**: @kristopherjturner
- **Closes**: platform issue [#3](https://github.com/AzureLocal/platform/issues/3)

## Context

Phase 2 moves MAPROOM and TRAILHEAD from `azurelocal-s2d-cartographer` into `platform/testing/` as the canonical testing framework for all AzureLocal repos. Before Phase 2 implementation begins, three things must be decided:

1. How to classify any testing tool — so future toolsets can be evaluated consistently.
2. What happens to each candidate toolset proposed in issue #3 (ship v0.2.0, defer, or reject).
3. What constraints the Phase 2 MAPROOM schema must satisfy to remain open to the deferred toolsets.

A repo survey (`docs/testing/repo-survey.md`) was conducted across all 11 sibling repos to ground these decisions in actual test surface, not assumptions.

## Decision

### 1. Classification rubric

Every platform testing toolset is described along four axes. All four must be stated when proposing a new toolset.

| Axis | Values |
|------|--------|
| **Scope** | `infra-fabric` · `platform-feature` · `workload` · `user-journey` · `compliance` · `performance` |
| **Target** | `cluster` · `node` · `module` · `repo` · `org` |
| **Authority** | `unit` (repo owns contract + fixture) · `contract` (platform owns contract, repo owns fixture) · `canonical` (platform owns both) |
| **Lifecycle** | `pre-deploy` · `deploy` · `post-deploy` · `drift-audit` · `incident-response` |

**Placement rules derived from classification:**

- `canonical` authority tools live entirely in `platform/testing/` — the IIC canon, schemas, and assertion logic are all platform-owned.
- `contract` authority tools: the contract (schema, expected interface) lives in `platform/testing/`; the fixture (actual values for a specific repo's environment) lives in the consumer repo under `tests/fixtures/`.
- `unit` authority tools are repo-local by definition and do not belong in platform.
- Tools with `org` target always land in platform. Tools with `repo` target may be platform-owned contracts or fully repo-local — use authority to decide.

### 2. MAPROOM and TRAILHEAD — Ship in v0.2.0

Both are confirmed for Phase 2 extraction.

**MAPROOM classification:**

| Axis | Value |
|------|-------|
| Scope | `infra-fabric` |
| Target | `cluster` |
| Authority | `canonical` |
| Lifecycle | `post-deploy` · `drift-audit` |

The critical v0.2.0 design constraint (see §3) is that `fixture.schema.json` must be typed by `infrastructure_type`, not by S2D-specific vocabulary. The S2D-shaped primitives (pools, tiers, volumes) become one fixture *variant* within a type-discriminated schema, not the schema's root vocabulary.

**TRAILHEAD classification:**

| Axis | Value |
|------|-------|
| Scope | `workload` |
| Target | `cluster` · `node` |
| Authority | `contract` |
| Lifecycle | `post-deploy` |

TRAILHEAD is a scenario runner. The platform owns the harness and scenario template structure; repos supply their own scenario scripts. No schema-level change needed for v0.2.0 — TRAILHEAD is already loosely coupled.

### 3. Candidate toolsets — decisions

#### MUSTER — Repo conformance checker · Planned for Phase 4

| Axis | Value |
|------|-------|
| Scope | `compliance` |
| Target | `repo` · `org` |
| Authority | `canonical` |
| Lifecycle | `drift-audit` |

MUSTER is the engine behind Phase 4's `drift-audit.yml` workflow. It asserts repos conform to platform standards: required files present, CI wired, STANDARDS.md stub in place, CODEOWNERS synced, `.azurelocal-platform.yml` parseable.

**Decision: Planned — Phase 4.** Not blocked on MAPROOM schema. No schema intersection. Implemented as `platform/testing/muster/` alongside Phase 4 automation scripts.

#### COMPASS — Compliance / policy assertion harness · Defer to v0.3.0

| Axis | Value |
|------|-------|
| Scope | `compliance` |
| Target | `cluster` |
| Authority | `canonical` |
| Lifecycle | `post-deploy` · `drift-audit` |

Azure Policy / CIS / STIG assertions against a live cluster, reported against the IIC canon. Highest value for regulated deployments.

**Decision: Defer to v0.3.0.** Requires live cluster access and a policy-assertion vocabulary not yet designed. The MAPROOM schema must reserve a `compliance` section in the fixture type to avoid collision — see §3 below. COMPASS becomes a sibling module `AzureLocal.Compass` when it ships, not part of `AzureLocal.Maproom`.

#### LEDGER — Migration inventory differ · Defer to v0.3.0

| Axis | Value |
|------|-------|
| Scope | `platform-feature` |
| Target | `repo` |
| Authority | `contract` |
| Lifecycle | `pre-deploy` · `post-deploy` |

Before/after inventory diffs for VM conversion and Nutanix cutover. Platform owns the diff contract (what fields must be present in before/after snapshots, what delta counts as a failure); repos supply the actual inventories.

**Decision: Defer to v0.3.0.** `azurelocal-vm-conversion-toolkit` and `azurelocal-nutanix-migration` currently have zero test infrastructure. The contract cannot be designed without understanding what they actually inventory. The path: those repos establish their own test surfaces first (Phase 3 is a natural point), then LEDGER formalises the contract in v0.3.0.

#### PULSE — Synthetic-workload load harness · Defer to v0.3.0

| Axis | Value |
|------|-------|
| Scope | `performance` |
| Target | `cluster` |
| Authority | `contract` |
| Lifecycle | `post-deploy` |

Standardised load profiles (IOPS mix, RDP session counts, file-share patterns) emitted against a cluster and correlated with MAPROOM expected capacity assertions.

**Decision: Defer to v0.3.0.** `azurelocal-loadtools` already has the most mature test infrastructure in the org (Pester + JaCoCo coverage + multi-tool CI), but it tests the *load tool itself*, not the shape of load profiles. PULSE requires a MAPROOM fixture extension for capacity expectations — design that as MAPROOM reaches its first real consumer set before adding performance semantics.

#### STORYBOARD — AVD / user-journey scenario runner · Defer to v0.3.0

| Axis | Value |
|------|-------|
| Scope | `user-journey` |
| Target | `cluster` · `node` |
| Authority | `contract` |
| Lifecycle | `post-deploy` |

Session-broker-aware journey scripts (logon, app launch, profile mount, logoff) with pass/fail gates. Conceptually TRAILHEAD applied to the AVD user plane.

**Decision: Defer to v0.3.0.** TRAILHEAD is already in scope for v0.2.0. STORYBOARD is a TRAILHEAD variant specialised for AVD user journeys, not a separate framework. In v0.3.0, evaluate whether STORYBOARD is a TRAILHEAD scenario type or a distinct harness. `azurelocal-avd` is the sole near-term consumer.

#### BLUEPRINT — IaC pre-deploy template assertion · Defer to v0.3.0

| Axis | Value |
|------|-------|
| Scope | `platform-feature` |
| Target | `repo` |
| Authority | `contract` |
| Lifecycle | `pre-deploy` |

Asserts that an IaC template (Bicep, Terraform, ARM) produces the expected Azure resource graph *before deployment*. Platform owns the assertion contract (what fields must be present in the expected output, what resource types are required); repos supply their own expected-output fixtures. Distinct from MAPROOM — MAPROOM tests the live deployed result; BLUEPRINT tests the template artifact.

Current gap: `bicep build` and `tflint` validate syntax and lint rules but make no shape assertions. There is no platform tool that says "this Bicep template must produce exactly these resource types with these properties." This gap affects `azurelocal-toolkit`, `azurelocal-avd`, and `azurelocal-sofs-fslogix` today, and every future workload repo (`azurelocal-aks`, `azurelocal-sql-ha`, `azurelocal-sql-mi`, `azurelocal-vms`, `azurelocal-ml-ai`, `azurelocal-iot`, `azurelocal-custom-images`) as they come online.

**Decision: Defer to v0.3.0.** The assertion mechanism differs per tool (`bicep what-if`, `terraform plan -json`, `arm what-if`). The multi-tool parity requirement (all IaC tools produce identical infrastructure) means BLUEPRINT must either handle all three or be a thin wrapper that delegates to tool-specific adapters. That design work belongs after Phase 3 (reusable workflow rollout) when the IaC surface across repos is fully mapped. Add `iac` as a reserved top-level section in MAPROOM fixtures (see §4) to avoid collision.

#### OUTPOST — Demo-env provisioner · Reject

| Axis | Value |
|------|-------|
| Scope | `platform-feature` |
| Target | `cluster` |
| Authority | `contract` |
| Lifecycle | `pre-deploy` |

Wraps MAPROOM fixtures into a reproducible lab deploy.

**Decision: Reject as a testing toolset.** OUTPOST is a *deployment* tool, not a testing tool. Wrapping MAPROOM fixtures into a deploy harness belongs in Phase 5 templates (specifically the `training-site` and `migration-runbook` template variants), not in `platform/testing/`. If the need is real, it surfaces as a template, not a test framework.

### 4. MAPROOM schema design constraints for v0.2.0

`fixture.schema.json` must be designed so that the deferred toolsets do not require breaking changes when they ship. Required:

1. **Type discriminator**: every fixture declares `infrastructure_type` (one of the values in the master registry — `azure_local`, `avd_azure`, `avd_azure_local`, `sofs_azure_local`, `aks_azure_local`, `loadtools`, `vm_conversion`, `copilot`). Type-specific property sets are defined under a `properties` key gated by `if/then` based on `infrastructure_type`. S2D primitives (pools, tiers, volumes, fault domains) live under `if: infrastructure_type == azure_local`.

2. **Reserved top-level sections** (empty in v0.2.0, reserved so later toolsets don't collide):
   - `compliance` — for COMPASS policy assertions
   - `performance` — for PULSE capacity expectations
   - `user_journey` — for STORYBOARD scenario expectations
   - `iac` — for BLUEPRINT pre-deploy template assertions

3. **IIC canon naming**: `iic-cluster-01.json` is renamed `iic-azure-local-01.json` to signal that domain-specific canons follow the pattern `iic-<infrastructure_type>-<##>.json`. AVD, SOFS, and Nutanix canons are authored in v0.3.0 when their consumer repos establish test surfaces.

## Consequences

### Positive

- Phase 2 can begin immediately — the rubric and decisions are locked.
- MAPROOM schema is open-ended by construction. No breaking change when COMPASS, LEDGER, PULSE, STORYBOARD ship.
- Deferred toolsets have a clear on-ramp: they each need one ready consumer repo before their contract can be designed.
- MUSTER is explicitly planned for Phase 4, so Phase 4 automation design can reference it.

### Negative

- Six repos currently have zero test infrastructure. MUSTER will flag them as non-conformant at Phase 4 drift audit. This is intentional — the Phase 3 reusable workflow rollout is the forcing function to get those repos testing.
- IIC canon rename (`iic-cluster-01.json` → `iic-azure-local-01.json`) is a breaking change for `azurelocal-s2d-cartographer`. Acceptable because S2DCartographer is migrated to the platform MAPROOM as part of Phase 2 — the rename happens once, in the migration commit.

## Status of ADR-0003

This ADR accepts the MAPROOM/TRAILHEAD centralization proposed in ADR-0003 and supplies the schema constraints that were blocking it. ADR-0003 status moves from **Proposed** to **Accepted** upon merge of this ADR.
