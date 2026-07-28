---
title: "Template: ts-web-app"
---

# Template: ts-web-app

Scaffold for a TypeScript web app (Vite / React / Next.js-style). Used by `azurelocal-surveyor`.

## When to pick this variant

- The repo's primary output is a browser-served UI.
- Built with TypeScript + a modern bundler (Vite recommended).
- Published via GitHub Pages or an equivalent static host.

## What's in the template

```text
templates/ts-web-app/
├── .github/workflows/
│   ├── ci.yml                    # Calls reusable-ts-web-ci.yml
│   └── deploy-docs.yml           # Calls reusable-mkdocs-deploy.yml
├── package.json                  # Tokenised
├── tsconfig.json
├── mkdocs.yml
└── README.md
```

## `package.json` defaults

```json
{
  "name": "{{REPO_NAME}}",
  "version": "0.1.0",
  "description": "{{DESCRIPTION}}",
  "license": "MIT",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "preview": "vite preview",
    "lint": "eslint .",
    "typecheck": "tsc --noEmit",
    "test": "vitest run"
  }
}
```

Dependencies list is empty by design — add what the app actually needs (React, Vue, Svelte, etc.).

## CI caller — `ci.yml`

```yaml
name: CI

on:
  pull_request: {}
  push:
    branches: [main]

jobs:
  ci:
    uses: AzureLocal/platform/.github/workflows/reusable-ts-web-ci.yml@main
    with:
      node-version: '20'
      package-manager: npm
      run-typecheck: true
      run-lint: true
      run-test: true
      run-build: true
      test-script: test
      test-args: '--reporter=verbose'
```

## Deploying the app vs the docs

Two different targets:

- **The app** — `vite build` produces `dist/`; deploy separately (Azure Static Web Apps, Cloudflare Pages, GitHub Pages with a bespoke `deploy.yml`).
- **The docs site** — `reusable-mkdocs-deploy.yml` builds `docs/` via MkDocs and deploys to GitHub Pages on the `/` path.

For repos that want both (surveyor is the reference), the MkDocs site typically lives under `/docs/` and the app lives at `/`. Configure GitHub Pages accordingly.

## `tsconfig.json` defaults

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"]
}
```

Adjust to taste — strict mode is the recommended default.

## Docs site

`mkdocs.yml` is a minimal Material-themed site configured for the repo URL.

## Tokens used in this variant

| Token | Usage |
|---|---|
| `{{REPO_NAME}}` | `package.json` name, `mkdocs.yml` repo_url, README |
| `{{DESCRIPTION}}` | `package.json` description, mkdocs site description, README |
| `{{YEAR}}` | Copyright lines |

## Post-scaffold steps

1. `npm init` (or paste in dependencies in `package.json` and run `npm install`)
2. Author `src/main.tsx` (or equivalent entry point)
3. Configure Vite in `vite.config.ts` — not shipped in template to avoid framework-locking
4. Create `docs/index.md` for the MkDocs site
5. Enable GitHub Pages in repo settings if using `deploy-docs.yml`

## Example consumer

- [`azurelocal-surveyor`](https://github.com/AzureLocal/azurelocal-surveyor) — React + Vite capacity planning tool

## Related

- [Reusable workflow: ts-web-ci](../reusable-workflows/ts-web-ci.md)
- [Reusable workflow: mkdocs-deploy](../reusable-workflows/mkdocs-deploy.md)
