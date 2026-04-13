---
title: Future testing toolsets
---

# Future testing toolsets

Six toolsets are classified and deferred per [ADR-0004](https://github.com/AzureLocal/platform/blob/main/decisions/0004-testing-toolset-classification.md). They will live alongside MAPROOM and TRAILHEAD when they ship in v0.3.0+. Their classification is locked; their implementation is on the roadmap.

## MUSTER — Repo conformance checker

| Axis | Value |
|---|---|
| Scope | `compliance` |
| Target | `repo` · `org` |
| Authority | `canonical` |
| Lifecycle | `drift-audit` |

Engine behind the monthly `drift-audit.yml` workflow. Asserts repos conform to platform standards: required files present, CI wired, `STANDARDS.md` stub in place, CODEOWNERS synced, `.azurelocal-platform.yml` parseable.

**Status today:** implemented inside `AzureLocal.Common` (`Test-RepoConformance`, `Get-AzureLocalRepoInventory`). Extracted as a standalone `AzureLocal.Muster` module when its surface stabilises.

## COMPASS — Compliance / policy assertion harness

| Axis | Value |
|---|---|
| Scope | `compliance` |
| Target | `cluster` |
| Authority | `canonical` |
| Lifecycle | `post-deploy` · `drift-audit` |

Azure Policy / CIS / STIG assertions against a live cluster, reported against the IIC canon. Highest value for regulated deployments.

**Deferred to v0.3.0.** Requires live cluster access and a policy-assertion vocabulary not yet designed. The MAPROOM schema reserves a `compliance` section to avoid collision when COMPASS ships. Will be a sibling module `AzureLocal.Compass`, not part of `AzureLocal.Maproom`.

## LEDGER — Migration inventory differ

| Axis | Value |
|---|---|
| Scope | `platform-feature` |
| Target | `repo` |
| Authority | `contract` |
| Lifecycle | `pre-deploy` · `post-deploy` |

Before/after inventory diffs for VM conversion and Nutanix cutover. Platform owns the diff contract (what fields must be present in before/after snapshots, what delta counts as a failure); repos supply the actual inventories.

**Deferred to v0.3.0.** `azurelocal-vm-conversion-toolkit` and `azurelocal-nutanix-migration` need to establish their own test surfaces first. The contract cannot be designed without seeing what they actually inventory.

## PULSE — Synthetic-workload load harness

| Axis | Value |
|---|---|
| Scope | `performance` |
| Target | `cluster` |
| Authority | `contract` |
| Lifecycle | `post-deploy` |

Standardised load profiles (IOPS mix, RDP session counts, file-share patterns) emitted against a cluster and correlated with MAPROOM expected capacity assertions.

**Deferred to v0.3.0.** `azurelocal-loadtools` has the most mature test infrastructure in the org but tests the *load tool itself*, not the shape of load profiles. PULSE requires a MAPROOM fixture extension for capacity expectations — design after MAPROOM reaches its first real consumer set.

## STORYBOARD — AVD / user-journey scenario runner

| Axis | Value |
|---|---|
| Scope | `user-journey` |
| Target | `cluster` · `node` |
| Authority | `contract` |
| Lifecycle | `post-deploy` |

Session-broker-aware journey scripts (logon, app launch, profile mount, logoff) with pass/fail gates. Conceptually TRAILHEAD applied to the AVD user plane.

**Deferred to v0.3.0.** TRAILHEAD ships in v0.2.0. STORYBOARD will be evaluated as either a TRAILHEAD scenario type or a distinct harness once AVD adoption gives signal. `azurelocal-avd` is the sole near-term consumer.

## BLUEPRINT — IaC pre-deploy template assertion

| Axis | Value |
|---|---|
| Scope | `platform-feature` |
| Target | `repo` |
| Authority | `contract` |
| Lifecycle | `pre-deploy` |

Asserts that an IaC template (Bicep, Terraform, ARM) produces the expected Azure resource graph **before deployment**. Distinct from MAPROOM — MAPROOM tests the live deployed result; BLUEPRINT tests the template artifact.

**Deferred to v0.3.0.** The assertion mechanism differs per tool (`bicep what-if`, `terraform plan -json`, `arm what-if`). Multi-tool parity means BLUEPRINT must either handle all three or be a thin wrapper over tool-specific adapters. Belongs after Phase 3 reusable workflow rollout when the IaC surface across repos is fully mapped.

## OUTPOST — Demo-env provisioner — REJECTED

Originally proposed as a demo-environment harness wrapping MAPROOM fixtures. Per ADR-0004: rejected as a testing toolset. OUTPOST is a **deployment** tool; its function belongs in Phase 5 templates (`training-site`, `migration-runbook` variants), not in `platform/testing/`.

## Adding a new toolset

The classification rubric (scope, target, authority, lifecycle) must be stated up front. Authority = `canonical` lives entirely in platform; `contract` splits between platform and consumers; `unit` is repo-local. See [ADR-0004](https://github.com/AzureLocal/platform/blob/main/decisions/0004-testing-toolset-classification.md) for the placement rules.

A new toolset proposal needs:

1. ADR with classification + reserved schema sections (if MAPROOM-adjacent)
2. At least one consumer ready to adopt on day one
3. Schema impact analysis — does it require a new section in `fixture.schema.json`?
4. Naming convention follows existing pattern (single uppercase noun)
