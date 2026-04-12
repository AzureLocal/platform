# Changelog

All notable changes to `AzureLocal/platform` are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
