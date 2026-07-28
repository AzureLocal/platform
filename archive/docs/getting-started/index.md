---
title: Getting started
---

# Getting started

New to `AzureLocal/platform`? Start here.

## Pick your path

| If you want to... | Read |
|---|---|
| Understand what platform is and isn't | [What is platform](what-is-platform.md) |
| Understand why it exists (~28 repos, 7 duplicate `standards/` folders, etc.) | [Why platform exists](why-platform-exists.md) |
| See how the pieces fit together | [Architecture overview](architecture-overview.md) |
| Look up terminology (MAPROOM, TRAILHEAD, IIC, etc.) | [Glossary](glossary.md) |
| Jump straight to links and shortcuts | [Quick links](quick-links.md) |

## Then decide your action

| Role | Next step |
|---|---|
| **Consumer repo owner** — adopting platform from an existing repo | [Onboarding → Adopt from an existing repo](../onboarding/adopt-from-existing-repo.md) |
| **Repo creator** — spinning up a new AzureLocal repo | [Onboarding → Create a new repo](../onboarding/create-new-repo.md) |
| **Platform contributor** — editing platform itself | [Contributing → Local setup](../contributing/local-setup.md) |
| **Operator** — running org-scripts, reading drift reports | [Repo management → Overview](../repo-management/overview.md) |

## Ten-minute tour

1. [`README`](https://github.com/AzureLocal/platform/blob/main/README.md) — what lives here
2. [Standards index](../standards/index.md) — canonical rules
3. [Reusable workflows index](../reusable-workflows/index.md) — the six workflows
4. [MAPROOM overview](../maproom/overview.md) — fixture-based testing
5. [TRAILHEAD overview](../trailhead/overview.md) — live-cluster cycles

## Repo map

| Folder | Purpose |
|---|---|
| `docs/` | This site (MkDocs Material) |
| `standards/` | Canonical standards markdown |
| `.github/workflows/reusable-*.yml` | The six reusable workflows |
| `testing/maproom/` | `AzureLocal.Maproom` PS module + schema |
| `testing/trailhead/` | Live-cluster harness |
| `testing/iic-canon/` | Canonical fictional-company fixtures |
| `modules/powershell/AzureLocal.Common/` | Shared PS helpers |
| `repo-management/org-scripts/` | `Invoke-RepoAudit`, `Sync-Labels`, etc. |
| `templates/` | 5 variants + `_common` for `New-AzureLocalRepo.ps1` |
| `decisions/` | ADRs |
