# Changelog

All notable changes to `AzureLocal/platform` are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
