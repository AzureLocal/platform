---
title: TRAILHEAD evidence capture
---

# TRAILHEAD evidence capture

Evidence is what makes a TRAILHEAD cycle auditable. Without captured evidence,
a "it passed" is just an assertion — you can't compare runs, detect regressions,
or hand off results to a reviewer.

## What counts as evidence

| Type | Required | How captured |
|------|----------|--------------|
| Run log (structured) | Yes | `Write-TH*` helpers → `.log` file |
| Command output | Yes | Redirect stdout/stderr into log |
| Error detail | Yes | `Write-THFail` with full error message |
| Screenshots | Recommended | Manual, stored in `evidence/` subfolder |
| Cluster state snapshot | Recommended | `Get-ClusterNode`, `Get-StoragePool` output |

## Log helpers

The platform provides structured log helpers in `TrailheadLog-Helpers.ps1`:

```powershell
# Dot-source the helpers
. (Join-Path $env:PLATFORM_ROOT 'testing\trailhead\scripts\TrailheadLog-Helpers.ps1')

# Mark the start of a phase
Write-THPhase -Name 'S2D Health Check'

# Record a passing assertion
Write-THPass -Test 'Storage pool is Healthy' -Detail "HealthStatus=Healthy, OperationalStatus=OK"

# Record a failure
Write-THFail -Test 'VirtualDisk resiliency' -Detail "Expected 3-way mirror, got 2-way mirror"

# Record a note (informational, not pass/fail)
Write-THNote -Message "Cluster has 4 nodes, reserve capacity = Adequate"

# Close the run (writes summary footer)
Close-THRun -RunPath $logPath
```

## Log format

Each log line is tab-separated: `timestamp [LEVEL] message`

```text
10:23:41 [PHASE] S2D Health Check
10:23:42 [PASS]  Storage pool is Healthy — HealthStatus=Healthy, OperationalStatus=OK
10:23:43 [FAIL]  VirtualDisk resiliency — Expected 3-way mirror, got 2-way mirror
```

Levels: `PHASE`, `PASS`, `FAIL`, `FIX`, `NOTE`, `SKIP`

## Evidence directory layout

```text
tests/trailhead/logs/
└── 2026-04-13-pre-release-v0.3.0/
    ├── run.log               ← structured log (Write-TH* output)
    ├── evidence/
    │   ├── storage-pool.txt  ← Get-StoragePool output
    │   ├── cluster-nodes.txt ← Get-ClusterNode output
    │   └── screenshot-01.png
    └── summary.md            ← human-readable summary (optional)
```

## Comparing runs

The `Start-TrailheadRun.ps1` script accepts a `-CompareTo` path to diff the current
run log against a prior run. Differences in PASS/FAIL counts are flagged as regressions.
