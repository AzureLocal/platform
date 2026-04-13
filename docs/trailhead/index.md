---
title: TRAILHEAD
---

# TRAILHEAD

TRAILHEAD is the AzureLocal **live-cluster** validation framework. Unlike MAPROOM (which is fixture-based and runs in CI), TRAILHEAD runs structured cycles against real target clusters and captures timestamped evidence.

## Start here

| Read | When |
|---|---|
| [Overview](overview.md) | What TRAILHEAD is, how it differs from MAPROOM, when to use it |
| [Cycle planning](cycle-planning.md) | Plan a cycle — scenario, cluster, phase, operator |
| [Evidence capture](evidence-capture.md) | How logs, timings, and outputs are recorded |
| [Safety checklist](safety-checklist.md) | Pre-flight before running against a real cluster |
| [Post-run review](post-run-review.md) | After-action: comparing runs, filing issues, regressions |

## Key facts

- **Harness**: `testing/trailhead/scripts/` — platform-owned helpers
- **Scripts**: `Start-TrailheadRun.ps1`, `TrailheadLog-Helpers.ps1`
- **Evidence location**: consumer repo's `tests/trailhead/logs/<date>-<scenario>/`
- **Authority**: `contract` — platform owns the harness; consumers supply scenario scripts
- **Typical cadence**: pre-release smoke, pre-release full, regression after upgrade, post-upgrade HCI

## Relationship to MAPROOM

| | MAPROOM | TRAILHEAD |
|---|---|---|
| Input | JSON fixture | Live cluster |
| Runs in | CI | Operator workstation / bastion |
| Output | Pester pass/fail | Evidence artifacts + pass/fail |
| Duration | Seconds | Minutes to hours |
| Frequency | Every PR | Scheduled cycles |
| Classification (ADR-0004) | Scope: infra-fabric, Authority: canonical | Scope: workload, Authority: contract |

## Current consumers

All PS module and IaC solution repos that deploy or validate against a cluster:

- `azurelocal-s2d-cartographer`
- `azurelocal-ranger`
- Additional consumers onboard as their deploy paths mature

## Next steps

- [Overview](overview.md) — what TRAILHEAD is
- [Safety checklist](safety-checklist.md) — before your first run
- [Cycle planning](cycle-planning.md) — plan your first cycle
