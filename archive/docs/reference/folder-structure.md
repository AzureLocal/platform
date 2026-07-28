---
title: Folder structure
---

# Folder structure

Top-level layout of the `AzureLocal/platform` repository.

```text
platform/
├── .github/
│   └── workflows/
│       ├── platform-ci.yml              # platform's own CI (markdownlint, yamllint, Pester)
│       ├── deploy-docs.yml              # deploys this docs site
│       ├── release-please.yml           # automated release PRs
│       ├── add-to-project.yml           # project-board automation
│       ├── validate-repo-structure.yml  # self-validation
│       ├── drift-audit.yml              # monthly org-wide audit
│       ├── reusable-mkdocs-deploy.yml   # reusable workflow
│       ├── reusable-iac-validate.yml    # reusable workflow
│       ├── reusable-ps-module-ci.yml    # reusable workflow
│       ├── reusable-ts-web-ci.yml       # reusable workflow
│       ├── reusable-maproom-run.yml     # reusable workflow
│       └── reusable-drift-check.yml     # reusable workflow
│
├── docs/                                # This MkDocs Material site
│   ├── getting-started/
│   ├── onboarding/
│   ├── standards/
│   ├── reusable-workflows/
│   ├── maproom/
│   ├── trailhead/
│   ├── repo-management/
│   ├── templates/
│   ├── modules/
│   ├── governance/
│   ├── reference/
│   ├── contributing/
│   └── testing/
│       └── repo-survey.md               # Repo survey that grounded ADR-0004
│
├── standards/                           # Canonical standards docs (single source of truth)
│
├── testing/
│   ├── maproom/
│   │   ├── AzureLocal.Maproom.psd1      # Module manifest
│   │   ├── AzureLocal.Maproom.psm1
│   │   ├── framework/
│   │   │   ├── Public/                  # Exported functions
│   │   │   ├── Private/                 # Internal helpers
│   │   │   └── Classes/                 # PS classes
│   │   ├── generators/
│   │   ├── harness/
│   │   ├── schema/
│   │   │   └── fixture.schema.json
│   │   └── README.md
│   │
│   ├── trailhead/
│   │   ├── scripts/
│   │   │   ├── Start-TrailheadRun.ps1
│   │   │   └── TrailheadLog-Helpers.ps1
│   │   ├── templates/
│   │   ├── docs/
│   │   └── README.md
│   │
│   └── iic-canon/
│       ├── iic-azure-local-01.json
│       └── README.md
│
├── modules/
│   └── powershell/
│       └── AzureLocal.Common/
│           ├── AzureLocal.Common.psd1
│           ├── AzureLocal.Common.psm1
│           └── README.md
│
├── repo-management/
│   └── org-scripts/
│       ├── Invoke-RepoAudit.ps1
│       ├── Sync-Labels.ps1
│       ├── Sync-BranchProtection.ps1
│       ├── Sync-CommonFiles.ps1
│       ├── New-AzureLocalRepo.ps1
│       └── labels.json                  # Canonical label set (16 labels)
│
├── templates/
│   ├── _common/                         # Files copied into every variant
│   ├── ps-module/
│   ├── ts-web-app/
│   ├── iac-solution/
│   ├── migration-runbook/
│   └── training-site/
│
├── scripts/
│   ├── Seed-DocStubs.ps1                # Original docs-stub seeder
│   └── README.md
│
├── decisions/                           # ADRs
│   ├── 0001-create-platform-repo.md
│   ├── 0002-standards-single-source.md
│   ├── 0003-maproom-iic-canon.md
│   ├── 0004-testing-toolset-classification.md
│   ├── README.md
│   └── template.md
│
├── .azurelocal-platform.yml             # Self-descriptor — platform is its own first consumer
├── .markdownlint.json
├── .yamllint.yml
├── CHANGELOG.md
├── CODEOWNERS
├── CONTRIBUTING.md
├── LICENSE
├── README.md
├── SECURITY.md
├── mkdocs.yml
├── release-please-config.json
└── requirements-docs.txt
```

## Depth limits

- Keep top-level directories flat. New things go under an existing folder when possible.
- Templates variants never nest more than 2 levels deep inside `templates/<variant>/`.
- ADRs stay at `decisions/` root — no subfolders.

## Why the split

- `testing/` (not `modules/`) holds `AzureLocal.Maproom` because MAPROOM is a testing framework, not a general helper. `AzureLocal.Common` is general — it lives under `modules/powershell/`.
- `standards/` is the **source** of standards; `docs/standards/` is the rendered navigation-friendly version. The two diverge only while docs are being authored.
- `scripts/` is for platform's own tooling (runs *on* the platform repo). `repo-management/org-scripts/` runs *against* consumer repos.
