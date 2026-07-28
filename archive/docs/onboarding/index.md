---
title: Onboarding
---

# Onboarding

Two paths, depending on whether the repo exists yet.

## Pick your path

| Path | When |
|---|---|
| [Adopt from an existing repo](adopt-from-existing-repo.md) | You have a repo in the AzureLocal org that predates platform and want to start consuming it |
| [Create a new repo](create-new-repo.md) | You need a brand-new AzureLocal repo — use `New-AzureLocalRepo.ps1` |
| [Migration checklist](migration-checklist.md) | Step-by-step checklist version of the adoption path |
| [Rollback](rollback.md) | If something went wrong and you need to back out |

## What adoption gives you

A repo that's "onboarded" to platform has:

- `.azurelocal-platform.yml` declaring its repo type and which platform features it adopts
- `CHANGELOG.md`, `mkdocs.yml`, `deploy-docs.yml`, `drift-check.yml` — the 5 canonical required files
- At least one CI workflow calling a platform reusable workflow
- Labels and branch protection synced from the canonical set
- README badge linking to platform
- `STANDARDS.md` stub pointing at `platform/docs/standards/`

Once adopted, the repo is picked up by `drift-audit.yml`'s monthly org-wide audit.

## What it does NOT give you

- **Code changes** — adoption is additive; no existing code is removed.
- **Workflow migration** — existing CI workflows continue to work. Migration to reusable workflows is a separate, opt-in step.
- **Module rewrites** — `AzureLocal.Common` and `AzureLocal.Maproom` are optional consumption.

## Effort estimate

| Path | Wall time |
|---|---|
| Create a new repo | ~5 min (one `New-AzureLocalRepo.ps1` invocation) |
| Adopt an existing simple repo | ~15–30 min (land a PR with the 5 required files + badge) |
| Adopt an existing complex repo | ~1–2 hr (map existing CI to reusable workflows, resolve drift) |

## Next steps

Pick the path above. Each page is self-contained — no need to read both.
