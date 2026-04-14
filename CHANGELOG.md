# Changelog

All notable changes to `AzureLocal/platform` are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0](https://github.com/AzureLocal/platform/compare/azurelocal-platform-v0.1.0...azurelocal-platform-v0.2.0) (2026-04-14)


### Features

* **maproom:** Phase 2 — AzureLocal.Maproom module, IIC canon, fixture schema, TRAILHEAD harness ([1812e89](https://github.com/AzureLocal/platform/commit/1812e893576a04983a9058a2a10793d0c8c32cd6))
* **platform:** Phase 3-5 rollout — reusable workflows, org automation, templates ([3e15006](https://github.com/AzureLocal/platform/commit/3e15006655e24a3c307f70892833af663cc2e484))
* **testing:** Add BLUEPRINT toolset — IaC pre-deploy assertion ([3bf44e0](https://github.com/AzureLocal/platform/commit/3bf44e0d67194a1bd6f57133f95da4a091dccb7f))
* **testing:** Classification rubric ADR + repo survey — closes [#3](https://github.com/AzureLocal/platform/issues/3) ([a6f4aeb](https://github.com/AzureLocal/platform/commit/a6f4aeb4228983a1e7dafa27447a6d965a23d593))


### Bug Fixes

* **docs:** Consolidate top nav 13 → 7 — group testing toolsets ([a551182](https://github.com/AzureLocal/platform/commit/a55118255aede40113b22d777e19048bc74edb5e))
* **docs:** Pin pygments==2.17.2 — unblock deploy-docs ([aedb256](https://github.com/AzureLocal/platform/commit/aedb2560b4081287587e73a2f1ea43448a1c387a))
* **docs:** Remove future-toolsets page — track toolsets as issues instead ([b7a2766](https://github.com/AzureLocal/platform/commit/b7a27662c27a48bec6355f1c403161b27d5fe8ae))
* **docs:** Rename docs/templates/ → docs/scaffolds/ — mkdocs reserved name ([b214c2f](https://github.com/AzureLocal/platform/commit/b214c2f637e246d91ad4e0e17efa12c65f8e4d1f))
* **lint:** Fix broken relative links in standards docs ([9ccdf1a](https://github.com/AzureLocal/platform/commit/9ccdf1a6e37319323152436dc89d3e8fcbdcbf34))
* **lint:** Remaining MD032 in variables.md + MkDocs fetch-depth ([8670899](https://github.com/AzureLocal/platform/commit/867089993008e9ca4e4eb1970597c5d0df3d4e15))
* **lint:** Trailing newlines, code fence languages, list spacing in standards docs ([db5a1e6](https://github.com/AzureLocal/platform/commit/db5a1e680fc43bbd3037d085bcd2684d1496e381))
* **structure:** Move standards/ into docs/standards/ — all docs under /docs ([#7](https://github.com/AzureLocal/platform/issues/7)) ([7f5dcff](https://github.com/AzureLocal/platform/commit/7f5dcff6012debeb2a4739feadcba4245aeec925)), closes [#6](https://github.com/AzureLocal/platform/issues/6)

## [0.1.0](https://github.com/AzureLocal/platform/compare/azurelocal-platform-v0.0.2...azurelocal-platform-v0.1.0) (2026-04-12)


### Features

* **standards:** Seed standards/ from site + add STANDARDS.md stub (Phase 1) ([#4](https://github.com/AzureLocal/platform/issues/4)) ([79a03a2](https://github.com/AzureLocal/platform/commit/79a03a219fc3f5faf3c29b22e74edfb88b606072))

## [0.0.2](https://github.com/AzureLocal/platform/compare/azurelocal-platform-v0.0.1...azurelocal-platform-v0.0.2) (2026-04-12)


### Bug Fixes

* **ci:** Recognize frontmatter title as H1 so MD025 stops firing ([d40b3f2](https://github.com/AzureLocal/platform/commit/d40b3f2fe1c63d9009bdee35358d65105ab250a5))
* **ci:** Simplify platform-ci, extract yamllint config to .yamllint.yml ([a0c239f](https://github.com/AzureLocal/platform/commit/a0c239fa02744b6d1783e1a7d4aba1c4c1b692b1))
* **docs:** Add 'text' language to fenced folder-tree blocks (MD040) ([a5aa747](https://github.com/AzureLocal/platform/commit/a5aa74784d2cd4fb32588c049e4c88a392591430))

## [Unreleased]

### Added

- Initial repository bootstrap (Phase 0 of the implementation plan).
- Full folder skeleton: `standards/`, `repo-management/`, `testing/` (maproom + trailhead + iic-canon), `templates/` (5 variants), `scripts/`, `modules/powershell/AzureLocal.Common/`, `docs/`, `decisions/`.
- MkDocs Material docs site scaffold (`mkdocs.yml`, `requirements-docs.txt`, `deploy-docs.yml`).
- Platform CI workflow (`platform-ci.yml`) — markdownlint, link-check, Pester (when modules exist).
- `release-please` wiring for version management.
- ADR 0001 — Create AzureLocal platform repo.
- ADR 0002 — Standards as single source of truth.
- `.azurelocal-platform.yml` self-descriptor.
- Canonical `.gitignore`, `.editorconfig`, `.markdownlint.json` (intended to be distributed to all repos in Phase 4).
