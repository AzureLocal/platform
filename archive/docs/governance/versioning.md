---
title: Versioning
---

# Versioning

`AzureLocal/platform` follows [Semantic Versioning 2.0](https://semver.org/spec/v2.0.0.html) with additional rules specific to a reusable-workflow platform.

## Tag format

```text
azurelocal-platform-v<MAJOR>.<MINOR>.<PATCH>
```

release-please uses the `simple` release type with the tag prefix `azurelocal-platform`. The leading `v` inside the suffix is conventional.

## SemVer mapping

| Bump | When |
|---|---|
| **MAJOR** | Any [breaking change](breaking-changes.md) in reusable workflows, PS modules, MAPROOM schema, templates, or IIC canon |
| **MINOR** | New feature, new workflow, new module function, new template variant, new IIC canon file |
| **PATCH** | Bug fix, performance improvement, doc-only fix inside a published module |

Docs-only commits (`docs:`) do not bump. Chore/ci/refactor commits do not bump.

## Short major tags (`v1`, `v2`, …)

In addition to the full semver tag, a **short major tag** is maintained:

- `v1` → latest `v1.x.y`
- `v2` → latest `v2.x.y`

This is how consumers pin. Example:

```yaml
uses: AzureLocal/platform/.github/workflows/reusable-ps-module-ci.yml@v1
```

The short tag is force-moved forward on each release within a major. It is **not** moved across majors — `v1` stops updating once `v2.0.0` ships.

## Pre-stable (`v0.x.x`) — current state

While platform is in v0.x.x:

- Consumers pin `@main`.
- Breaking changes are allowed on a **minor** bump (v0.2.x → v0.3.0) with an ADR.
- The `@v1` pin rule is not yet active.
- `drift-check.yml` is configured to *not* flag `@main` as drift.

## Post-stable (`v1.0.0+`) — future state

When platform tags v1.0.0:

- Consumers pin `@v1` (short major tag).
- `drift-check.yml` flags `@main` as drift.
- Breaking changes require a major bump.
- Old major tags (`v1`, `v2`, …) are retained indefinitely so late migrators can still build.

## What v1.0.0 means

Declaring v1.0.0 implies:

- The interface of all 6 reusable workflows is stable.
- `AzureLocal.Common` and `AzureLocal.Maproom` function signatures are stable.
- MAPROOM `fixture.schema.json` is frozen (additive only within the major).
- IIC canon files are frozen.
- Template token set is stable.

Target for v1.0.0 is after the deferred toolsets ship in v0.3.0 (see ADR-0004) and at least one full quarter of consumer use has surfaced the real breakage points.

## Consumer-side versioning

Consumer repos version **their own releases** via release-please — independent of platform.

| Example | Interpretation |
|---|---|
| `AzureLocal.Maproom@0.2.0` + `azurelocal-ranger@1.3.0` | ranger is a consumer on v1.3.0 of its own release line, using platform v0.2.0 |
| Platform bumps to v0.3.0 with breaking MAPROOM changes | ranger stays on v0.2.0 platform (pinned to SHA or old tag) until it can upgrade |

## ADRs that touch versioning

- [ADR 0001 — Create platform repo](https://github.com/AzureLocal/platform/blob/main/decisions/0001-create-platform-repo.md) — initial stance
- [ADR 0004 — Testing toolset classification](https://github.com/AzureLocal/platform/blob/main/decisions/0004-testing-toolset-classification.md) — defers toolsets to v0.3.0

## See also

- [Reusable workflows → Versioning](../reusable-workflows/versioning.md) — the consumer-facing perspective
- [Release cycle](release-cycle.md) — when releases happen
- [Breaking changes](breaking-changes.md) — what counts as major
