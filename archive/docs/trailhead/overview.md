---
title: TRAILHEAD overview
---

# TRAILHEAD overview

TRAILHEAD is the AzureLocal live-cluster validation framework. Where [MAPROOM](../maproom/overview.md)
runs offline against synthetic fixture data, TRAILHEAD runs against **real hardware** —
real cluster state, real network conditions, real hardware quirks.

## When to use TRAILHEAD

| Scenario | Use |
|----------|-----|
| Test module logic offline, no cluster needed | MAPROOM |
| Validate behavior against real cluster state | TRAILHEAD |
| Regression testing in CI (offline, fast) | MAPROOM |
| Validate a release is safe to ship to customers | TRAILHEAD |

Both are routinely used together: MAPROOM gates CI, TRAILHEAD gates a release.

## Core concept: the cycle

A **TRAILHEAD cycle** is one structured run of a tool against a real cluster. Each cycle:

1. Has a named **scenario** (e.g., `pre-release`, `post-upgrade`, `regression`)
2. Produces **evidence** — timestamped logs, command output, screenshots
3. Is **compared** against prior cycles to detect regressions
4. Results in a **GitHub Issue** that records pass/fail/notes

Cycles are repeatable. Running the same scenario against the same cluster twice should produce
the same evidence unless the cluster or tool changed.

## Framework location

```text
platform/testing/trailhead/
├── scripts/
│   ├── TrailheadLog-Helpers.ps1   — Write-TH*, Close-THRun helpers
│   └── Start-TrailheadRun.ps1     — parameterized run initializer
```

Consumer repos keep their own scenario scripts in `tests/trailhead/scripts/` and dot-source
the platform helpers.

## Safety

TRAILHEAD touches live clusters. Read the [safety checklist](safety-checklist.md) before every
cycle — especially the pre-run isolation checklist.

## Further reading

- [Cycle planning](cycle-planning.md)
- [Evidence capture](evidence-capture.md)
- [Safety checklist](safety-checklist.md)
- [Post-run review](post-run-review.md)
