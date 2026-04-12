# Contributing to AzureLocal Platform

Organization-wide contribution rules live in [`AzureLocal/.github/CONTRIBUTING.md`](https://github.com/AzureLocal/.github/blob/main/CONTRIBUTING.md). Read that first. This file adds only the rules specific to `platform`.

## Platform-specific rules

### 1. Changes to standards, reusable workflows, or IIC canon require an ADR

If your PR touches any of the following, open an ADR in [`decisions/`](./decisions) first:

- `standards/*.mdx` — any substantive change (not just typos)
- `.github/workflows/reusable-*.yml` — new workflow, new input, or breaking change
- `testing/iic-canon/*.json` — ANY change (frozen post-v1)
- `templates/` — new variant or breaking change to an existing variant

Minor doc edits and typo fixes do not need an ADR.

### 2. Reusable workflows are versioned by tag

Consumer repos pin by major tag (`@v1`). This means:

- Backward-compatible additions → minor/patch release (consumers unaffected)
- **Breaking changes require a new `v2` major tag** plus a six-month dual-support window on `v1`
- Never reference `@main` from a consumer repo

See [`docs/governance/breaking-changes.md`](./docs/governance/breaking-changes.md).

### 3. Local development

```powershell
# Clone
gh repo clone AzureLocal/platform

# Build docs locally
pip install -r requirements-docs.txt
mkdocs serve

# Run platform CI checks locally
./scripts/Test-PlatformStructure.ps1
```

See [`docs/contributing/local-setup.md`](./docs/contributing/local-setup.md).

### 4. Commit messages

[Conventional Commits](https://www.conventionalcommits.org/), per the org-wide rule. `release-please` reads the history — keep it clean.

### 5. CODEOWNERS review

All PRs require approval from `@AzureLocal/maintainers` (per [`CODEOWNERS`](./CODEOWNERS)). Solo-maintainer self-merge is permitted via admin override; document non-trivial self-merges in the PR description.

## PR checklist (enforced by `platform-ci.yml`)

- [ ] ADR added or updated if required (see rule 1)
- [ ] `CHANGELOG.md` updated
- [ ] Docs page updated if behavior changed
- [ ] `mkdocs build` succeeds (CI runs this automatically)
- [ ] Markdown lint passes
- [ ] Link check passes
- [ ] Pester tests pass if `modules/` was touched
