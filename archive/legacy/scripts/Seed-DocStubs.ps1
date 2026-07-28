<#
.SYNOPSIS
    Seeds the docs/ tree with stub pages so MkDocs nav resolves cleanly from
    day one. Real content replaces these stubs in later phases.

.DESCRIPTION
    Used once during Phase 0 bootstrap. Safe to re-run — overwrites only files
    that still contain the 'status: stub' frontmatter marker.
#>
[CmdletBinding()]
param(
    [string] $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
    [switch] $Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$pages = [ordered]@{
    'docs/getting-started/index.md'                 = 'Getting started'
    'docs/getting-started/what-is-platform.md'      = 'What is platform'
    'docs/getting-started/why-platform-exists.md'   = 'Why platform exists'
    'docs/getting-started/architecture-overview.md' = 'Architecture overview'
    'docs/getting-started/glossary.md'              = 'Glossary'
    'docs/getting-started/quick-links.md'           = 'Quick links'
    'docs/onboarding/index.md'                      = 'Onboarding'
    'docs/onboarding/adopt-from-existing-repo.md'   = 'Adopt from an existing repo'
    'docs/onboarding/create-new-repo.md'            = 'Create a new repo'
    'docs/onboarding/migration-checklist.md'        = 'Migration checklist'
    'docs/onboarding/rollback.md'                   = 'Rollback'
    'docs/standards/index.md'                       = 'Standards'
    'docs/standards/consuming.md'                   = 'Consuming standards'
    'docs/standards/contributing.md'                = 'Contributing to standards'
    'docs/standards/propagation.md'                 = 'Standards propagation'
    'docs/standards/authoring-guide.md'             = 'Standards authoring guide'
    'docs/reusable-workflows/index.md'              = 'Reusable workflows'
    'docs/reusable-workflows/split-rule.md'         = 'Workflow split rule'
    'docs/reusable-workflows/versioning.md'         = 'Workflow versioning'
    'docs/reusable-workflows/consumer-patterns.md'  = 'Consumer patterns'
    'docs/reusable-workflows/ps-module-ci.md'       = 'reusable-ps-module-ci'
    'docs/reusable-workflows/ts-web-ci.md'          = 'reusable-ts-web-ci'
    'docs/reusable-workflows/iac-validate.md'       = 'reusable-iac-validate'
    'docs/reusable-workflows/mkdocs-deploy.md'      = 'reusable-mkdocs-deploy'
    'docs/reusable-workflows/maproom-run.md'        = 'reusable-maproom-run'
    'docs/reusable-workflows/drift-check.md'        = 'reusable-drift-check'
    'docs/maproom/index.md'                         = 'MAPROOM'
    'docs/maproom/overview.md'                      = 'MAPROOM overview'
    'docs/maproom/framework-architecture.md'        = 'MAPROOM framework architecture'
    'docs/maproom/iic-canon.md'                     = 'IIC canon'
    'docs/maproom/authoring-fixtures.md'            = 'Authoring MAPROOM fixtures'
    'docs/maproom/writing-unit-tests.md'            = 'Writing MAPROOM unit tests'
    'docs/maproom/integration-model.md'             = 'MAPROOM integration model'
    'docs/maproom/extending-the-framework.md'       = 'Extending the MAPROOM framework'
    'docs/maproom/troubleshooting.md'               = 'MAPROOM troubleshooting'
    'docs/trailhead/index.md'                       = 'TRAILHEAD'
    'docs/trailhead/overview.md'                    = 'TRAILHEAD overview'
    'docs/trailhead/cycle-planning.md'              = 'TRAILHEAD cycle planning'
    'docs/trailhead/evidence-capture.md'            = 'TRAILHEAD evidence capture'
    'docs/trailhead/safety-checklist.md'            = 'TRAILHEAD safety checklist'
    'docs/trailhead/post-run-review.md'             = 'TRAILHEAD post-run review'
    'docs/repo-management/index.md'                 = 'Repo management'
    'docs/repo-management/overview.md'              = 'Repo management overview'
    'docs/repo-management/new-repo-bootstrap.md'    = 'New-repo bootstrap'
    'docs/repo-management/drift-audit.md'           = 'Drift audit'
    'docs/repo-management/label-sync.md'            = 'Label sync'
    'docs/repo-management/branch-protection.md'     = 'Branch protection'
    'docs/repo-management/common-file-sync.md'      = 'Common file sync'
    'docs/repo-management/emergency-runbooks.md'    = 'Emergency runbooks'
    'docs/templates/index.md'                       = 'Templates'
    'docs/templates/overview.md'                    = 'Templates overview'
    'docs/templates/ps-module.md'                   = 'Template: ps-module'
    'docs/templates/ts-web-app.md'                  = 'Template: ts-web-app'
    'docs/templates/iac-solution.md'                = 'Template: iac-solution'
    'docs/templates/migration-runbook.md'           = 'Template: migration-runbook'
    'docs/templates/training-site.md'               = 'Template: training-site'
    'docs/templates/authoring-new-variant.md'       = 'Authoring a new template variant'
    'docs/modules/index.md'                         = 'Modules'
    'docs/modules/AzureLocal.Common.md'             = 'AzureLocal.Common'
    'docs/governance/index.md'                      = 'Governance'
    'docs/governance/adr-process.md'                = 'ADR process'
    'docs/governance/release-cycle.md'              = 'Release cycle'
    'docs/governance/versioning.md'                 = 'Versioning'
    'docs/governance/breaking-changes.md'           = 'Breaking changes'
    'docs/governance/codeowners-and-reviewers.md'   = 'CODEOWNERS and reviewers'
    'docs/reference/index.md'                       = 'Reference'
    'docs/reference/folder-structure.md'            = 'Folder structure'
    'docs/reference/file-manifest.md'               = 'File manifest'
    'docs/reference/workflow-matrix.md'             = 'Workflow matrix'
    'docs/reference/env-secrets.md'                 = 'Env and secrets'
    'docs/reference/troubleshooting.md'             = 'Reference troubleshooting'
    'docs/reference/faq.md'                         = 'FAQ'
    'docs/contributing/index.md'                    = 'Contributing'
    'docs/contributing/local-setup.md'              = 'Local setup'
    'docs/contributing/pr-workflow.md'              = 'PR workflow'
    'docs/contributing/testing-platform.md'         = 'Testing platform'
    'docs/contributing/release-process.md'          = 'Release process'
}

$written = 0
$skipped = 0

foreach ($rel in $pages.Keys) {
    $title = $pages[$rel]
    $full  = Join-Path $RepoRoot $rel
    $dir   = Split-Path -Parent $full

    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }

    if ((Test-Path $full) -and -not $Force) {
        $existing = Get-Content $full -Raw -ErrorAction SilentlyContinue
        if ($existing -notmatch 'status:\s*stub') {
            Write-Verbose "Skipping $rel (already has real content)"
            $skipped++
            continue
        }
    }

    $content = @"
---
title: $title
status: stub
---

# $title

!!! warning "Stub page"
    This page is seeded for navigation. Real content lands in a later phase of the platform rollout. Track progress in the implementation plan.

## What belongs on this page

TODO — fill in during the appropriate rollout phase.
"@

    Set-Content -Path $full -Value $content -Encoding UTF8
    $written++
}

Write-Host "Seeded $written stub pages, skipped $skipped" -ForegroundColor Green
