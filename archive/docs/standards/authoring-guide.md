---
title: Standards authoring guide
---

# Standards authoring guide

How to author or edit a standards document inside `AzureLocal/platform`.

## Where standards live

Two locations:

- **Canonical source**: `standards/` at the platform repo root — the authoritative content.
- **Rendered docs**: `docs/standards/` — the MkDocs-friendly copies served at [azurelocal.github.io/platform/standards/](https://azurelocal.github.io/platform/standards/).

Edit the source, then mirror into `docs/`. The two locations exist because standards are ingested verbatim into docs plus some other surfaces (e.g., `azurelocal.github.io` syncs from `standards/`).

## File naming

```text
<kebab-case-topic>.md
```

Examples: `naming.md`, `repository-management.md`, `variables.md`. Avoid `.mdx` unless the standard genuinely needs React components (it rarely does).

## Frontmatter

Every standards doc needs:

```yaml
---
title: <Human-friendly title>
sidebar_label: <Short label for nav>   # optional, defaults to title
sidebar_position: <int>                # optional, orders in nav
description: <One-sentence summary>    # optional, used by search
---
```

## Structure

Use this skeleton:

```markdown
---
title: <Title>
---

# <Title>

> One-sentence purpose statement.

## Scope

What this standard covers and what it doesn't.

## Rule

The normative statement. Use MUST / SHOULD / MAY (RFC 2119) where the distinction matters.

## Rationale

Why this rule exists. Reference ADRs when available.

## Examples

### ✓ Good

<code example>

### ✗ Bad

<code example>

## Enforcement

How this is checked (CI job, drift audit, manual review, etc.).

## Exceptions

When the rule explicitly does not apply, and how to request exemption.

## Related

- [Other standard](other.md)
- [ADR link]
```

Not every section is mandatory — `Rationale` and `Examples` in particular are optional when the rule is self-evident.

## Voice

- **Imperative, not descriptive.** "Use 2 spaces for indentation," not "2-space indentation is used."
- **Specific, not aspirational.** Don't say "code should be clean" — define what clean means in the context.
- **Lead with the rule.** Rationale comes after the rule, not before.
- **Say MUST / SHOULD / MAY when the difference matters** — otherwise plain imperative is fine.

## Linking

- Cross-link to other standards docs with relative paths (`[Variables](variables.md)`, not the rendered URL).
- Link ADRs with absolute GitHub paths (`https://github.com/AzureLocal/platform/blob/main/decisions/0001-create-platform-repo.md`) so they work in both the source and the rendered docs.
- Link external sites with `https://` explicitly; never bare URLs.

## Linting

Every standards doc must pass:

- `markdownlint-cli2` with the repo's `.markdownlint.json`
- Link-check (no broken cross-refs)

`platform-ci.yml` enforces both on PR.

## When to update vs create

| Scenario | Action |
|---|---|
| Adding a new rule under an existing topic | Edit the existing file |
| Tightening/loosening an existing rule | Edit + capture why in an ADR if it changes behaviour |
| New topic that doesn't fit any existing file | New file + add to `mkdocs.yml` nav + add to `standards/` canonical |
| Deprecating a rule | Mark with admonition at the top; keep the content for one release cycle; remove on the next minor |

## Testing a standards change locally

```powershell
mkdocs serve
```

Navigate to `http://127.0.0.1:8000/standards/<your-page>/` — verify rendering and links.

## Promoting a standards change

1. PR on platform.
2. Green CI (lint + link-check).
3. Merge.
4. release-please picks it up as a `docs:` change (no version bump) — unless the standard is enforceable and the enforcement changes, in which case use `feat:` or `feat!:`.
5. Standards propagate to consumer repos via the breadcrumb pattern (`STANDARDS.md` stub). No active sync job — consumer reads live.

## Related

- [Standards propagation](propagation.md)
- [Consuming standards](consuming.md)
- [Contributing to standards](contributing.md)
