---
title: Breaking changes
---

# Breaking changes

A breaking change in platform cascades to every consumer that pins to the affected major. This page defines what counts as breaking, how to communicate it, and the deprecation window.

## What counts as a breaking change

### Reusable workflows

| Change | Breaking? |
|---|---|
| Remove an input | Yes |
| Rename an input | Yes |
| Change a required input's type | Yes |
| Change the default of an existing input in a way callers will notice | Yes |
| Remove or rename a job | Yes — callers may reference the job in `needs:` or required-status-checks |
| Add a new optional input with a default | No |
| Add a new job | No (unless it becomes required downstream) |
| Tighten validation so previously-accepted inputs now error | Yes |

### PowerShell modules (`AzureLocal.Common`, `AzureLocal.Maproom`)

| Change | Breaking? |
|---|---|
| Remove an exported function | Yes |
| Rename an exported function | Yes |
| Change a parameter name | Yes |
| Change a parameter type | Yes |
| Remove a parameter | Yes |
| Change function return type or add new required object properties callers depend on | Yes |
| Bump required `PowerShellVersion` in the `.psd1` | Yes |

### MAPROOM schema

| Change | Breaking? |
|---|---|
| Require a property that was previously optional | Yes |
| Remove a property consumers write | Yes |
| Change the type of an existing property | Yes |
| Add a new optional property | No |
| Add a new `infrastructure_type` value | No (additive) |

### Templates

| Change | Breaking? |
|---|---|
| Remove a file from a variant | Yes (bootstrap will fail for callers expecting it) |
| Remove a token (`{{X}}`) that `New-AzureLocalRepo.ps1` substitutes | Yes |
| Add a new variant | No |

### IIC canon

Canon fixtures are frozen after publication (see [IIC canon](../maproom/iic-canon.md)). Any property change to an existing canon file is a breaking change.

## Commit convention for breaking changes

```text
feat(scope)!: short description

BREAKING CHANGE: <what breaks and what callers must do>
```

The `!` after the scope *and* the `BREAKING CHANGE:` footer are both needed for release-please to bump major.

## Deprecation window

For v1.0.0+ (not yet reached):

1. Introduce the new API in version N (additive, non-breaking).
2. Mark the old API deprecated — doc warning, optional runtime warning for modules.
3. Wait **at least one minor release** (effectively ≥ 4 weeks) before removing.
4. Remove in N+2 (major bump).

Platform is pre-stable (`v0.x.x`) today — breaking changes can happen on a minor bump with one merged ADR.

## Communication checklist before shipping a breaking change

- [ ] ADR written and merged
- [ ] `BREAKING CHANGE:` footer on the commit
- [ ] Migration guide in the new major's release notes
- [ ] Previous major tag (`v1`, `v2`, …) left in place — do not delete
- [ ] Every known consumer's main branch audited: does it still build against the *old* major after the release? (`drift-check.yml` surfaces this over the next week.)

## When a breaking change lands mid-stream

If a breaking change is merged without a major bump by accident:

1. Do not force-push to fix the tag — the tag was published.
2. Revert the commit on `main`.
3. Land a `fix:` patch that undoes the break.
4. Plan the intended change as a major bump for the next release.

See also: [reusable-workflows/versioning](../reusable-workflows/versioning.md) for the major-tag pin semantics.
