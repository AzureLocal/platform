# TRAILHEAD

Live-cluster validation framework. Structured cycles of "bring a tool to a real cluster, run it, capture evidence, compare to prior runs."

## Structure

```
trailhead/
├── templates/   — cycle plan, field testing, evidence capture
├── scripts/     — cycle runner, evidence capture, run comparator
└── docs/        — live validation model, safety checklist
```

## When to use TRAILHEAD vs MAPROOM

| Need | Framework |
|---|---|
| Deterministic, offline, CI-friendly test | MAPROOM |
| Behavior against real cluster state, hardware quirks, real network | TRAILHEAD |
| Regression testing of the module itself | MAPROOM |
| Validation that a release is safe to ship | TRAILHEAD |

Both are routinely used together — a MAPROOM suite gates CI, a TRAILHEAD cycle gates a release.

## Consumer pattern

A product repo clones the templates into its own `tests/trailhead/` and runs cycles per release:

```powershell
./tests/trailhead/scripts/Start-TrailheadCycle.ps1 -Scenario 'pre-release' -ClusterFqdn tplabs-clus01.azrl.mgmt
```

Cycle outputs go into `tests/trailhead/logs/<date>/` in the product repo (never in platform).

## Safety

TRAILHEAD touches live clusters. Always review [`docs/trailhead/safety-checklist.md`](../../docs/trailhead/safety-checklist.md) before running a cycle.

## Documentation

- [Overview](../../docs/trailhead/overview.md)
- [Cycle planning](../../docs/trailhead/cycle-planning.md)
- [Evidence capture](../../docs/trailhead/evidence-capture.md)
- [Safety checklist](../../docs/trailhead/safety-checklist.md)
