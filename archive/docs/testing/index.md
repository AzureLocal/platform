---
title: Testing
---

# Testing

`AzureLocal/platform` ships the canonical testing toolkits used by every consumer repo. Per [ADR-0004](https://github.com/AzureLocal/platform/blob/main/decisions/0004-testing-toolset-classification.md), every toolkit is classified along four axes (scope, target, authority, lifecycle) before it ships.

## Toolkits in v0.2.0

| Toolkit | Purpose | Scope | Authority |
|---|---|---|---|
| [MAPROOM](../maproom/index.md) | Offline fixture-based contract testing for cluster shapes | infra-fabric | canonical |
| [TRAILHEAD](../trailhead/index.md) | Live-cluster validation cycles with evidence capture | workload | contract |

## Future toolkits (v0.3.0+)

Tracked as GitHub issues on this repo: MUSTER ([#10](https://github.com/AzureLocal/platform/issues/10)), COMPASS ([#11](https://github.com/AzureLocal/platform/issues/11)), LEDGER ([#12](https://github.com/AzureLocal/platform/issues/12)), PULSE ([#13](https://github.com/AzureLocal/platform/issues/13)), STORYBOARD ([#14](https://github.com/AzureLocal/platform/issues/14)), BLUEPRINT ([#15](https://github.com/AzureLocal/platform/issues/15)), OUTPOST ([#16](https://github.com/AzureLocal/platform/issues/16)).

## Repo survey

The [Repo survey](repo-survey.md) grounds testing decisions in what the 11 sibling repos actually run today (Pester counts, MAPROOM consumers, IaC validation, etc.). Re-run when adding a new toolkit.

## When to use which

| If you're testing... | Use |
|---|---|
| Expected output shape of an IaC template or planning tool | MAPROOM |
| Live cluster behaviour against expected canon | MAPROOM (offline assert) + TRAILHEAD (live cycle) |
| User journey on an AVD host pool | TRAILHEAD (or STORYBOARD when it ships) |
| Compliance / policy posture against a live tenant | COMPASS (v0.3.0) |
| Migration before/after inventory diff | LEDGER (v0.3.0) |
| Synthetic workload load profile | PULSE (v0.3.0) |
| IaC pre-deploy template assertion | BLUEPRINT (v0.3.0) |
| Repo conformance against platform standards | MUSTER (drift-audit today; standalone module v0.3.0+) |
| Demo/training environment provisioning | OUTPOST (v0.3.0+) |
