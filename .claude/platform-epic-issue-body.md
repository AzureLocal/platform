# AzureLocal Platform — Implementation Epic

Living tracker for the full platform rollout. Based on the approved plan (local to the maintainer). Phase 0 is already done; this issue carries the complete plan forward and checks off work as it lands.

## Context

The AzureLocal organization owns ~28 active repositories and one maintainer. An audit found systemic drift across the repos:

- `/standards/` folder duplicated across 7+ repos with partial drift
- `/repo-management/` folder duplicated across 11 repos
- `CONTRIBUTING.md` has 10 unique hashes across 10 repos
- 9 repos carry near-duplicate `deploy-docs.yml` workflow files
- MAPROOM testing framework mature only in `S2DCartographer`
- 3 repos missing entire categories of standard files

`AzureLocal/.github` already owns GitHub-metadata governance (community-health files, 3 reusable workflows). `AzureLocal/platform` owns developer tooling — standards, reusable workflows, testing frameworks, templates, bootstrap scripts, shared modules.

## Decisions locked

1. **Repo name**: `platform`
2. **Visibility**: public — required for public product repos to consume reusable workflows
3. **License**: MIT
4. **Docs format**: MkDocs Material + GitHub Pages at https://azurelocal.cloud/platform/
5. **PSGallery publishing**: `AzureLocal.Common` and `AzureLocal.Maproom` stay git-sourced for v1
6. **Docs site sync**: scheduled GitHub Action pull on platform release tag (not git submodule)
7. **CONTRIBUTING strategy**: ~15-line shim per repo linking to `.github/CONTRIBUTING.md`
8. **Drift-audit routing**: issues filed in platform only (not mirrored per-repo)
9. **Template variants**: 5 (`ps-module`, `ts-web-app`, `iac-solution`, `migration-runbook`, `training-site`)

## Rollout phases

Each phase has a hard done-criterion. No phase begins until the prior meets it.

### Phase 0 — Bootstrap platform ✅

- [x] Create `AzureLocal/platform` repo (public, MIT, main)
- [x] Seed top-level skeleton (all directories + README stubs)
- [x] Repo-root files: README, CHANGELOG, CONTRIBUTING (shim), CODEOWNERS, SECURITY, LICENSE, .gitignore, .editorconfig, .markdownlint.json, .yamllint.yml, .azurelocal-platform.yml
- [x] Author `mkdocs.yml` + `requirements-docs.txt`
- [x] Seed `docs/` tree (77 stub pages across 11 sections)
- [x] Write real content for highest-value landing pages (9 pages)
- [x] Workflows: `platform-ci.yml`, `deploy-docs.yml`, `release-please.yml`, `add-to-project.yml`, `validate-repo-structure.yml`, `drift-audit.yml` (Phase 4 placeholder)
- [x] ADR 0001 (create platform repo) + 0002 (standards single source) + template
- [x] `release-please-config.json` + manifest (v0.0.1)
- [x] `scripts/Seed-DocStubs.ps1` helper
- [x] Initial commit and push
- [x] Configure branch protection on `main`
- [x] Enable GitHub Pages on `gh-pages` branch
- [x] Verify site renders at https://azurelocal.cloud/platform/
- [x] Platform CI green (Markdown lint, YAML lint, MkDocs build, Link check, Structure self-test)
- [x] Create this epic issue
- [x] Create `azurelocal-platform.code-workspace` with all 12 product repos (new primary VS Code workspace)

**Phase 0 exit criteria met.** Site live, CI green, repo conforming.

### Phase 1 — Standards consolidation (week 2)

- [ ] Copy 11 `.mdx` files from `azurelocal.github.io/standards/` → `platform/standards/` (site version wins on conflict)
- [ ] Author new `standards/testing.mdx` capturing MAPROOM / TRAILHEAD / IIC rules
- [ ] Add scheduled sync workflow in `azurelocal.github.io` pulling `platform/standards/*.mdx`
- [ ] Audit the 7 repos with local `/standards/` folders
- [ ] In each: delete `/standards/` folder, add `STANDARDS.md` stub (breadcrumb)
  - [ ] azurelocal-avd
  - [ ] azurelocal-sofs-fslogix
  - [ ] azurelocal-loadtools
  - [ ] azurelocal-vm-conversion-toolkit
  - [ ] azurelocal-copilot
  - [ ] azurelocal-nutanix-migration
  - [ ] (one more per audit)
- [ ] Verify `azurelocal.github.io` still renders the standards section (live site smoke-test)
- [ ] Tag `platform` as `v0.1.0`

**Exit criteria**: 7 repos no longer contain standards content; docs site still renders standards.

### Phase 2 — MAPROOM framework (weeks 3-4)

- [ ] Extract shared classes from `azurelocal-s2d-cartographer/tests/maproom/` → `platform/testing/maproom/framework/Classes/`
- [ ] Extract generators → `platform/testing/maproom/generators/`
- [ ] Extract harness + contract assertions → `platform/testing/maproom/harness/`
- [ ] Author `fixture.schema.json` and `iic-canon.schema.json` under `platform/testing/maproom/schema/`
- [ ] Publish `AzureLocal.Maproom` as internal PS module (manifest + psm1)
- [ ] Populate `testing/iic-canon/` with `iic-org.json`, `iic-cluster-01.json`, `iic-networks.json`
- [ ] Port TRAILHEAD templates from `S2DCartographer/tests/trailhead/` → `platform/testing/trailhead/templates/`
- [ ] Port TRAILHEAD scripts → `platform/testing/trailhead/scripts/`
- [ ] Update `azurelocal-s2d-cartographer` to consume platform MAPROOM via reference
- [ ] Update `azurelocal-ranger` to consume platform MAPROOM (second consumer — proves generalization)
- [ ] Write docs: `docs/maproom/framework-architecture.md`, `authoring-fixtures.md`, `writing-unit-tests.md`, `iic-canon.md`
- [ ] Tag `platform` as `v0.2.0`

**Exit criteria**: both S2DCartographer and Ranger green against platform MAPROOM harness. IIC canon validates against schema.

### Phase 3 — Reusable workflow rollout (weeks 5-7)

Author and ship each reusable workflow, then convert consumers one-by-one. Each workflow ships with its own docs page under `docs/reusable-workflows/`.

#### 3a. `reusable-mkdocs-deploy.yml` (lowest risk, 9 near-identical consumers)

- [ ] Author workflow with inputs: python-version, requirements-file
- [ ] Tag as `v1`
- [ ] Write full docs page `docs/reusable-workflows/mkdocs-deploy.md`
- [ ] Migrate consumer: azurelocal-avd
- [ ] Migrate consumer: azurelocal-sofs-fslogix
- [ ] Migrate consumer: azurelocal-loadtools
- [ ] Migrate consumer: azurelocal-vm-conversion-toolkit
- [ ] Migrate consumer: azurelocal-training
- [ ] Migrate consumer: azurelocal-nutanix-migration
- [ ] Migrate consumer: azurelocal-copilot
- [ ] Migrate consumer: azurelocal-ranger (if applicable)
- [ ] Migrate consumer: azurelocal-s2d-cartographer (docs site exists)
- [ ] Migrate platform itself (dogfood — replaces standalone `deploy-docs.yml`)

#### 3b. `reusable-iac-validate.yml`

- [ ] Author workflow (bicep build + tflint/tfsec + arm-ttk)
- [ ] Tag as `v1`
- [ ] Docs page
- [ ] Migrate: azurelocal-avd
- [ ] Migrate: azurelocal-sofs-fslogix
- [ ] Migrate: azurelocal-aks (when cloned)
- [ ] Migrate: azurelocal-sql-ha, azurelocal-sql-mi, azurelocal-vms, azurelocal-ml-ai, azurelocal-iot, azurelocal-custom-images

#### 3c. `reusable-ps-module-ci.yml`

- [ ] Author workflow (Pester + PSScriptAnalyzer + optional PSGallery publish)
- [ ] Tag as `v1`
- [ ] Docs page
- [ ] Migrate: azurelocal-ranger
- [ ] Migrate: azurelocal-s2d-cartographer
- [ ] Migrate: azurelocal-toolkit

#### 3d. `reusable-ts-web-ci.yml`

- [ ] Author workflow (install + lint + typecheck + vitest + build)
- [ ] Tag as `v1`
- [ ] Docs page
- [ ] Migrate: azurelocal-surveyor
- [ ] Migrate: azurelocal-azloflows (when cloned)

#### 3e. `reusable-maproom-run.yml`

- [ ] Author workflow wrapping `AzureLocal.Maproom` harness
- [ ] Tag as `v1`
- [ ] Docs page
- [ ] Migrate: azurelocal-s2d-cartographer
- [ ] Migrate: azurelocal-ranger

#### 3f. `reusable-drift-check.yml`

- [ ] Author single-repo conformance report
- [ ] Tag as `v1`
- [ ] Docs page
- [ ] Schedule weekly in every product repo (Phase 4 will wire the monthly org-wide version)

**Exit criteria**: all `deploy-docs.yml`, IaC validators, PS module CIs, TS web CIs are ≤10-line calls to reusables.

### Phase 4 — Org-wide automation (week 8)

- [ ] Author `repo-management/org-scripts/Invoke-RepoAudit.ps1` (drift detection across all repos)
- [ ] Author `repo-management/org-scripts/Sync-Labels.ps1` + canonical `labels.json`
- [ ] Author `repo-management/org-scripts/Sync-BranchProtection.ps1`
- [ ] Author `repo-management/org-scripts/Sync-CommonFiles.ps1`
- [ ] Implement `modules/powershell/AzureLocal.Common/` public functions:
  - [ ] `Get-AzureLocalRepoInventory`
  - [ ] `Test-RepoConformance`
  - [ ] `Write-AzureLocalLog`
  - [ ] `Resolve-IICIdentity`
- [ ] Replace `drift-audit.yml` placeholder with real implementation (monthly cron, files an issue)
- [ ] Add `.azurelocal-platform.yml` to every non-archived org repo
- [ ] Run first monthly audit; triage any delta
- [ ] Write docs: `docs/repo-management/drift-audit.md`, `label-sync.md`, `branch-protection.md`, `common-file-sync.md`, `emergency-runbooks.md`

**Exit criteria**: first monthly audit runs clean or with known triaged deltas.

### Phase 5 — Templates + new-repo creation (week 9)

- [ ] Finalize `templates/_common/` with LICENSE, .gitignore, .editorconfig, CODEOWNERS, STANDARDS.md, CHANGELOG.md, .azurelocal-platform.yml, .github/workflows/*
- [ ] Finalize `templates/ps-module/` (Modules/, Pester structure, `ps-module-ci.yml`)
- [ ] Finalize `templates/ts-web-app/` (package.json, vite.config.ts, tsconfig.json, src/, `ts-web-ci.yml`)
- [ ] Finalize `templates/iac-solution/` (bicep/, terraform/, arm/, mkdocs.yml, `iac-validate.yml`)
- [ ] Finalize `templates/migration-runbook/` (playbooks/, scripts/, mkdocs.yml)
- [ ] Finalize `templates/training-site/` (docs/, mkdocs.yml, `deploy-docs.yml`)
- [ ] Author `repo-management/org-scripts/New-AzureLocalRepo.ps1` (token substitution + `gh repo create` + apply branch protection + apply labels)
- [ ] Test each variant produces a buildable skeleton
- [ ] Test end-to-end: `New-AzureLocalRepo.ps1 -Type iac-solution -Name azurelocal-test-scratch -DryRun`, then without `-DryRun`, in a throwaway test org
- [ ] Write docs: `docs/templates/*.md` for each variant
- [ ] Delete the test-scratch repo

**Exit criteria**: creating a new repo is one command with zero manual follow-up.

## Docs completion

The 77 stub pages in `docs/` fill in alongside the phases. Per page, real content lands when the corresponding feature ships:

- [ ] Fill remaining stubs under `docs/getting-started/` — quick-links, index
- [ ] Fill `docs/onboarding/` — create-new-repo (when Phase 5 ships), migration-checklist, rollback
- [ ] Fill `docs/standards/` — consuming, contributing, propagation, authoring-guide (Phase 1)
- [ ] Fill `docs/reusable-workflows/` detail pages (Phase 3, one per workflow)
- [ ] Fill `docs/maproom/` pages (Phase 2)
- [ ] Fill `docs/trailhead/` pages (Phase 2)
- [ ] Fill `docs/repo-management/` pages (Phase 4)
- [ ] Fill `docs/templates/` pages (Phase 5)
- [ ] Fill `docs/modules/AzureLocal.Common.md` (Phase 4 when module ships)
- [ ] Fill `docs/governance/` — release-cycle, versioning, breaking-changes, codeowners-and-reviewers
- [ ] Fill `docs/reference/` — folder-structure, file-manifest, workflow-matrix, env-secrets, troubleshooting, faq
- [ ] Fill `docs/contributing/` — local-setup, pr-workflow, testing-platform, release-process

## Post-Phase-0 immediate TODOs

- [ ] Update `.github/workflows/add-to-project.yml` — replace `REPLACE_WITH_SOLUTION_OPTION_ID` with the real project board option GUID for Platform
- [ ] Watch Node.js 20 deprecation warnings; bump actions when upstream publishes Node 24 versions (before 2026-09-16)

## Ongoing maintenance

- **Workflow updates**: platform releases via release-please → new tag on `v1`. Consumers pin `@v1`, unaffected. Breaking change → `v2` + 6-month dual-support.
- **Standards updates**: PR against `platform/standards/`. Merge triggers sync workflow in `azurelocal.github.io`.
- **Common file updates**: changes in `platform/templates/_common/` trigger `Sync-CommonFiles.ps1` which opens identical PRs across all repos.
- **Drift detection**: monthly `drift-audit.yml`. Delta → GitHub Issue with checklist.
- **ADR process**: cross-repo decisions require an ADR in `decisions/`.

## Risks (tracked; not action items)

| Risk | Mitigation |
|---|---|
| Sync workflow drift in `azurelocal.github.io` | Sync overwrites not merge; CI asserts parity |
| Breaking reusable-workflow change ships silently | Mandatory major-version tags; drift audit fails if any repo pins `@main` |
| MAPROOM generalization leaks S2D-specific assumptions | Phase 2 requires Ranger adoption before exit |
| IIC canon edits break every MAPROOM run | Treat `testing/iic-canon/*.json` frozen post-v1; ADR required; JSON Schema validation in platform CI |
| Template variant explosion | Cap at 5 variants for v1; new variant requires ADR |
| `azurelocal-copilot` private repo can't consume public reusables | Confirmed org setting enabled |

## Current status

**Phase 0 done.** Site live at https://azurelocal.cloud/platform/. CI green. Ready to begin Phase 1.

## Related

- ADR 0001: [decisions/0001-create-platform-repo.md](../blob/main/decisions/0001-create-platform-repo.md)
- ADR 0002: [decisions/0002-standards-single-source.md](../blob/main/decisions/0002-standards-single-source.md)
- Docs site: https://azurelocal.cloud/platform/
- Companion repo: [AzureLocal/.github](https://github.com/AzureLocal/.github)
