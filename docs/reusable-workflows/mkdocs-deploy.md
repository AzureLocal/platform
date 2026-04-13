---
title: reusable-mkdocs-deploy
---

# reusable-mkdocs-deploy

Builds an MkDocs site and deploys it to GitHub Pages. The workflow runs two sequential jobs: `build` (checkout → pip install → `mkdocs build` → upload artifact) and `deploy` (deploy the uploaded artifact to the `github-pages` environment).

```text
build:  checkout → setup-python → pip install → mkdocs build [--strict] → upload-pages-artifact
deploy: download artifact → deploy-pages
```

The `deploy` job requires `pages: write` and `id-token: write` permissions in the caller workflow.

!!! note "Platform repo exception"
    The platform repo itself uses `mkdocs gh-deploy` (in `deploy-docs.yml`) rather than
    this reusable workflow, because it needs `contents: write` for the `gh-pages` branch.
    Consumer repos should use this reusable workflow.

## Inputs

| Input | Type | Default | Description |
|---|---|---|---|
| `python-version` | string | `3.12` | Python version used for the MkDocs build |
| `pip-packages` | string | `mkdocs-material` | Space-separated pip packages to install |
| `strict` | boolean | `true` | Pass `--strict` to `mkdocs build` (treats warnings as errors) |
| `fetch-depth` | number | `1` | Git fetch depth — set to `0` for full history (required by the `git-revision-date-localized` plugin) |

## Minimal caller example

```yaml
name: Deploy Docs

on:
  push:
    branches: [main]
    paths: ['docs/**', 'mkdocs.yml']

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  docs:
    uses: AzureLocal/platform/.github/workflows/reusable-mkdocs-deploy.yml@main
```

## Extended example — drawio and revision dates

```yaml
name: Deploy Docs

on:
  push:
    branches: [main]
    paths: ['docs/**', 'mkdocs.yml']

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  docs:
    uses: AzureLocal/platform/.github/workflows/reusable-mkdocs-deploy.yml@main
    with:
      pip-packages: mkdocs-material mkdocs-drawio-exporter mkdocs-git-revision-date-localized-plugin
      fetch-depth: 0       # required for git-revision-date-localized
      strict: false        # drawio warnings should not block deploy
```

!!! tip "Strict mode"
    Keep `strict: true` (the default) to catch broken links and missing references at
    build time. Only disable it if a third-party plugin generates unavoidable warnings.
