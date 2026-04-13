---
title: TRAILHEAD post-run review
---

# TRAILHEAD post-run review

Every TRAILHEAD cycle ends with a post-run review. The review determines whether the
cycle result is a **go** (release or promotion can proceed) or a **no-go** (blockers
must be resolved first).

## Review output

The review produces one of three verdicts:

| Verdict | Meaning |
|---------|---------|
| **Go** | All tests passed; cycle evidence is sufficient; proceed |
| **Go with notes** | Minor issues noted; non-blocking; proceed with awareness |
| **No-go** | One or more blocking failures; cycle must re-run after fixes |

## Review steps

### 1. Read the run log

Open `tests/trailhead/logs/<date>-<scenario>/run.log`. Check:

- All `[PHASE]` sections completed
- `[FAIL]` count is zero (or all failures are documented as known/accepted)
- `[SKIP]` entries have a logged reason
- `Close-THRun` footer is present (confirms the cycle completed, not aborted)

### 2. Compare against the prior cycle

If a prior cycle exists for the same scenario:

```powershell
# Compare PASS/FAIL counts between runs
$current = Select-String -Path .\logs\2026-04-13-pre-release-v0.3.0\run.log -Pattern '^\d+:\d+:\d+ \[FAIL\]'
$prior   = Select-String -Path .\logs\2026-03-15-pre-release-v0.2.0\run.log -Pattern '^\d+:\d+:\d+ \[FAIL\]'
"Current failures : $($current.Count)  |  Prior failures: $($prior.Count)"
```

New failures compared to the prior cycle are **regressions** and block the release
unless explicitly accepted with a written rationale.

### 3. Verify cluster recovery

Confirm the cluster is in the same or better state than before the cycle:

```powershell
Get-ClusterNode  | Select-Object Name, State
Get-StoragePool  | Select-Object FriendlyName, HealthStatus, OperationalStatus
Get-VirtualDisk  | Select-Object FriendlyName, HealthStatus, ResiliencySettingName
```

### 4. Document the verdict

Record the verdict in the tracking issue opened by `Start-TrailheadRun.ps1`.
Include:

- Verdict (Go / Go with notes / No-go)
- Link to evidence directory
- Summary of any failures and their disposition
- Reviewer name and date

### 5. Gate the release (if applicable)

If this cycle is a pre-release gate:

- **Go**: merge the release-please PR and tag the release
- **No-go**: close the release-please PR, resolve blockers, re-run the cycle
