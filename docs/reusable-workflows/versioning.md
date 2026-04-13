---
title: Workflow versioning
---

# Workflow versioning

Reusable workflows in the AzureLocal org are versioned by the git tag on the repo that
owns them. Consumers pin to a **major version tag** (`@main` is forbidden in all product
repos — drift-check will flag it).

## How versioning works

The platform repo uses [release-please](https://github.com/googleapis/release-please) with
Conventional Commits. Every push to `main` that contains a `feat:`, `fix:`, or `feat!:`
commit triggers a release PR. When merged, release-please creates the git tag and GitHub
release automatically.

Tags follow `azurelocal-platform-v<MAJOR>.<MINOR>.<PATCH>`. The reusable workflows are
pinned by consumers using the short major tag `v1`, `v2`, etc. — not the full semver.

```yaml
# Correct — pins to the latest v1.x.x release
uses: AzureLocal/platform/.github/workflows/reusable-mkdocs-deploy.yml@v1

# Wrong — pins to HEAD; drift-check will fail
uses: AzureLocal/platform/.github/workflows/reusable-mkdocs-deploy.yml@main
```

!!! note "Current state — v0.x.x"
    While the platform is still in v0.x.x (pre-stable), consumers reference `@main`.
    The `@v1` pin rule takes effect when the platform tags v1.0.0. Until then, `@main`
    is acceptable and drift-check is configured accordingly.

## Breaking vs non-breaking changes

| Change | SemVer bump | Example |
|--------|-------------|---------|
| New optional input | patch | Adding `fetch-depth` with a default |
| Changed default for existing input | minor | Changing `strict` default from `true` to `false` |
| Removed input or changed required input | **major** | Removing `pip-packages`, renaming `module-manifest` |
| Job renamed or removed | **major** | Renaming `pester-unit` → `unit-tests` |

Removing or renaming jobs is a breaking change because consumers may depend on job names
in `needs:` blocks or branch protection required status checks.

## Migrating across major versions

When a breaking change ships (e.g., `v1` → `v2`):

1. The release notes document exactly what changed and the migration path.
2. `v1` major tag is not deleted — it stays pointing at the last v1.x.x commit.
3. Consumers migrate on their own schedule by updating the `@v1` → `@v2` pin.
4. Drift-check will not flag `@v1` as drift — only `@main` is flagged.

```yaml
# Before
uses: AzureLocal/platform/.github/workflows/reusable-ps-module-ci.yml@v1

# After migrating to v2
uses: AzureLocal/platform/.github/workflows/reusable-ps-module-ci.yml@v2
```

## Checking the current version

```bash
# Latest platform release
gh release list --repo AzureLocal/platform --limit 5

# What version a consumer is pinned to
grep 'AzureLocal/platform' .github/workflows/*.yml
```

## Related

- [Consumer patterns](consumer-patterns.md) — copy-paste examples
- [Workflow split rule](split-rule.md) — which repo owns which workflow
- [Governance — release cycle](../governance/release-cycle.md)
