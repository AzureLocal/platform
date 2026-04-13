---
title: reusable-ts-web-ci
---

# reusable-ts-web-ci

Provides a single `ci` job for TypeScript web applications. The job runs on `ubuntu-latest` and executes up to four steps in order — typecheck, lint, test, build — each independently gated by a boolean input.

```text
npm ci (or pnpm ci)
  → typecheck  (npm run typecheck)
  → lint       (npm run lint)
  → test       (npm run <test-script> -- <test-args>)
  → build      (npm run build)
```

`actions/setup-node@v4` is used with built-in caching for the chosen package manager.

## Inputs

| Input | Type | Default | Description |
|---|---|---|---|
| `node-version` | string | `20` | Node.js version to install |
| `package-manager` | string | `npm` | Package manager (`npm` or `pnpm`) |
| `run-typecheck` | boolean | `true` | Run `npm run typecheck` |
| `run-lint` | boolean | `true` | Run `npm run lint` |
| `run-test` | boolean | `true` | Run unit tests |
| `test-script` | string | `test` | npm script name for the test step |
| `test-args` | string | `--reporter=verbose` | Additional arguments appended after `--` to the test command |
| `run-build` | boolean | `true` | Run `npm run build` |

## Caller example — Surveyor

```yaml
name: CI

on: [pull_request]

permissions:
  contents: read

jobs:
  ci:
    uses: AzureLocal/platform/.github/workflows/reusable-ts-web-ci.yml@main
    with:
      node-version: '20'
      package-manager: npm
      test-script: test
      test-args: --reporter=verbose --coverage
```

## Caller example — pnpm workspace, no typecheck step

```yaml
name: CI

on: [pull_request]

permissions:
  contents: read

jobs:
  ci:
    uses: AzureLocal/platform/.github/workflows/reusable-ts-web-ci.yml@main
    with:
      package-manager: pnpm
      run-typecheck: false   # tsc integrated into the build step
      test-script: test:unit
```

!!! note "Script names must exist in package.json"
    The workflow runs `npm run <script>` verbatim. Ensure `typecheck`, `lint`, and your
    chosen `test-script` are defined in your `package.json` before enabling those steps.
    Disable any step that has no corresponding script rather than leaving it enabled.
