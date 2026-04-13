---
title: TRAILHEAD safety checklist
---

# TRAILHEAD safety checklist

TRAILHEAD runs against live clusters. Mistakes can disrupt workloads, corrupt storage,
or trigger unexpected failovers. Run through this checklist before **every** cycle.

!!! danger "Never skip this checklist"
    The checklist exists because past incidents happened without it. A 3-minute review
    prevents hours of recovery work.

## Pre-run checklist

### Cluster state

- [ ] Cluster is **not** hosting production workloads during the cycle window
- [ ] All cluster nodes are online (`Get-ClusterNode | Where-Object State -ne 'Up'` returns nothing)
- [ ] Storage pool is Healthy (`Get-StoragePool | Select-Object HealthStatus, OperationalStatus`)
- [ ] No pending storage repairs (`Get-StorageJob` returns nothing or only scheduled tasks)
- [ ] No active cluster events with severity Error or Critical in the last 30 minutes

### Tool version

- [ ] The tool version being tested is pinned (commit SHA, PSGallery version, or tagged release)
- [ ] The tool version matches the cycle scenario — not HEAD/main unless intentional
- [ ] Any `-WhatIf` flags are confirmed appropriate for the scenario

### Evidence capture

- [ ] Evidence log path exists and is writable
- [ ] Sufficient disk space (>500 MB free) on the log destination
- [ ] `Start-TrailheadRun.ps1` has been invoked to initialise the run log

### Communication

- [ ] Other team members know a TRAILHEAD cycle is in progress on this cluster
- [ ] A rollback plan is documented if the tool under test makes cluster changes

## During the run

- Do not run other tests or management operations on the cluster simultaneously
- If a step fails and you don't understand why — **stop the cycle**, investigate, then restart
- All failures must be logged with `Write-THFail` before continuing or aborting

## Post-run checklist

- [ ] `Close-THRun` was called to write the summary footer to the log
- [ ] All evidence files are saved in the run's evidence directory
- [ ] Cluster state is verified healthy after the run
- [ ] Log directory is committed/pushed to the consumer repo (or retained per team procedure)
- [ ] If failures occurred: a GitHub issue is open with the cycle log attached or linked
