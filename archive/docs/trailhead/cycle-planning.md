---
title: TRAILHEAD cycle planning
---

# TRAILHEAD cycle planning

A TRAILHEAD cycle must be planned before it runs. Unplanned runs produce evidence that
can't be compared to anything — which defeats the purpose of structured validation.

## Cycle anatomy

Every cycle has:

| Field | Description |
|-------|-------------|
| **Scenario** | Named test scenario (e.g., `pre-release-v0.3.0`, `post-upgrade-hci-23h2`) |
| **Cluster** | Target cluster FQDN (e.g., `tplabs-clus01.azrl.mgmt`) |
| **Phase** | Which phase of validation this represents (smoke, full, regression) |
| **Environment** | lab, staging, or production |
| **Operator** | Who is running the cycle |

## Starting a cycle

The platform script `Start-TrailheadRun.ps1` initialises a cycle, creates the log directory,
and optionally files a tracking issue on GitHub:

```powershell
./tests/trailhead/scripts/Start-TrailheadRun.ps1 `
    -Version '0.3.0' `
    -ManifestPath ./MyModule.psd1 `
    -Environment lab `
    -Phase smoke
```

Outputs go to `tests/trailhead/logs/<date>-<scenario>/` in the consumer repo — **never in platform**.

## Scenario naming convention

```text
<type>-<version-or-date>
```

Examples:

- `pre-release-v0.3.0`
- `post-upgrade-hci-23h2`
- `regression-2026-04-13`
- `smoke-daily`

## Planning checklist

Before scheduling a cycle:

- [ ] Target cluster is identified and accessible
- [ ] Cluster is not in use for production workloads during the cycle window
- [ ] Tool version to validate is pinned (tagged commit or specific PSGallery version)
- [ ] Scenario script matches the named scenario
- [ ] Safety checklist has been reviewed
- [ ] Evidence capture location is writable and has sufficient disk space

## Frequency guidance

| Phase | Frequency |
|-------|-----------|
| Pre-release smoke | Every release candidate |
| Pre-release full | Every minor/major release |
| Regression | After any platform or dependency upgrade |
| Post-upgrade | After cluster OS or firmware upgrade |
