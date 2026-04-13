---
title: Consuming standards
---

# Consuming standards

How a consumer repo adopts the AzureLocal standards maintained in `platform/docs/standards/`.

## The contract

A consumer repo does **not** vendor standards content. It points at platform via a `STANDARDS.md` stub at the repo root:

```markdown
# Standards

This repo follows the [AzureLocal platform standards](https://github.com/AzureLocal/platform/tree/main/docs/standards).

- [Naming conventions](https://github.com/AzureLocal/platform/blob/main/docs/standards/naming.md)
- [Scripting standards](https://github.com/AzureLocal/platform/blob/main/docs/standards/scripting.md)
- [Variables](https://github.com/AzureLocal/platform/blob/main/docs/standards/variables.md)
- [Testing](https://github.com/AzureLocal/platform/blob/main/docs/standards/testing.md)
```

This is the entire "adoption" — a file that links out. Deep-copying standards into the consumer is explicitly wrong (it's the drift problem that triggered [ADR-0002](https://github.com/AzureLocal/platform/blob/main/decisions/0002-standards-single-source.md)).

## Why no vendoring

Before platform, every consumer had its own `/standards/` folder. Seven of the ~28 repos had partially-drifted copies. That state — stale forks of the same standard — is the failure mode. Linking instead of copying makes drift impossible.

## What consumers DO author locally

Consumer-specific conventions that layer on top of platform standards belong in the consumer repo's `README.md` or a `docs/conventions.md`. Examples:

- Which IaC tool is used (Bicep vs Terraform)
- Directory layout specific to the repo's domain
- Deploy pipelines unique to the product

These **never** go in `STANDARDS.md` — that file is reserved for the upstream breadcrumb.

## When a platform standard conflicts with consumer reality

Three valid responses:

1. **Fix the consumer** — most common; the standard exists for a reason.
2. **Propose a platform change** — open a PR on `docs/standards/<topic>.md` with the new rule + rationale + ADR.
3. **Request an exception** — file an issue on platform explaining why; discuss before forking.

Forking the standard silently into the consumer is not a valid response. The drift audit will flag it, and the repo falls out of conformance.

## Verifying conformance

```powershell
Import-Module ./modules/powershell/AzureLocal.Common/AzureLocal.Common.psd1 -Force
Test-RepoConformance -Org AzureLocal -RepoName <consumer-name>
```

The check validates the presence of `STANDARDS.md`, among the other 5 required files.

## When the consumer's README needs a standards reference

Link the specific standard with a full URL (not `STANDARDS.md`, which is a one-file breadcrumb):

```markdown
See [AzureLocal naming conventions](https://github.com/AzureLocal/platform/blob/main/docs/standards/naming.md#module-naming).
```

## Stability guarantee

Standards URLs are treated as a stable API:

- Never rename a standards page without a redirect (MkDocs supports this).
- Anchor IDs inside pages are stable — `naming.md#module-naming` won't change unless the section is deleted.
- Deprecated standards remain in place for one release cycle with a banner before deletion.

This is what makes consumer `STANDARDS.md` stubs reliable.

## Related

- [Standards propagation](propagation.md) — how a change reaches every consumer
- [Authoring guide](authoring-guide.md) — how to write a standard
- [Contributing to standards](contributing.md) — how to propose changes
