---
title: Contributing to standards
---

# Contributing to standards

Propose a new standard or change an existing one in `AzureLocal/platform/docs/standards/`.

## Before you start

- Read [authoring guide](authoring-guide.md) for the file structure and voice.
- Read [consuming](consuming.md) to understand what a standard is promising to consumers.
- Skim existing ADRs in [`decisions/`](https://github.com/AzureLocal/platform/tree/main/decisions) — similar proposals may have been discussed.

## When an ADR is required

| Change | ADR? |
|---|---|
| Fixing a typo | No |
| Clarifying existing prose | No |
| Adding an example to an existing rule | No |
| Tightening a rule (narrower scope) | Yes — behaviour-affecting |
| Loosening a rule (wider scope) | Yes — may require consumer changes |
| Adding a new standard on an existing topic | Sometimes — depends on whether it alters consumer obligations |
| New standards topic (new file) | Yes |
| Deprecating a standard | Yes |

When in doubt, write the ADR. They are short and cheap.

## Proposal process

1. **Open an issue.** Brief description: the current state, the proposed change, the motivation.
2. **Draft the PR.** Include:
    - The standards file change (source in `standards/`, rendered copy in `docs/standards/`)
    - An ADR if required (see above)
    - Updates to `mkdocs.yml` nav if adding a new file
3. **Tag `standards` label.** CI runs the usual lint checks.
4. **Review.** @kristopherjturner reviews; comments get resolved; PR merges.

## Drafting the change

### For a clarification or typo fix

Just edit the file. Commit message:

```text
docs(standards): clarify <topic> — <reason>
```

### For a rule change

Edit the file, then add an ADR in `decisions/`:

```markdown
# ADR NNNN — <Change summary>

- **Status**: Proposed
- **Date**: <yyyy-mm-dd>
- **Deciders**: @kristopherjturner

## Context
What the current rule is and why it's insufficient.

## Decision
The new rule.

## Consequences
- What consumers must do (or can now do)
- Affected repos

## Alternatives considered
Other rules we could have adopted.
```

Commit message:

```text
feat(standards)!: <topic> — <summary>

BREAKING CHANGE: <how consumers must adapt>
```

### For a new standard

Create `standards/<topic>.md` and `docs/standards/<topic>.md`. Update `mkdocs.yml` nav. Add the topic to `docs/standards/index.md`. ADR + PR.

## Testing

```powershell
# Lint
npx markdownlint-cli2 "standards/**/*.md" "docs/standards/**/*.md"

# Link check
npx markdown-link-check docs/standards/<your-page>.md

# Render locally
mkdocs serve
```

Navigate to `http://127.0.0.1:8000/standards/<your-page>/` — verify.

## Propagation after merge

No sync job runs. Consumers read live via their `STANDARDS.md` breadcrumb. The only action a consumer maintainer takes is auditing their own repo if the rule change is behaviour-affecting — [drift-check](../reusable-workflows/drift-check.md) cannot detect content-level compliance, only file presence.

For enforceable rules (lint rules, file-presence checks), update the enforcement alongside the standard — e.g., a new markdownlint rule in platform's `.markdownlint.json` and optionally the `_common` template so new repos pick it up.

## Dual-venue updates

A standard that also appears on [azurelocal.github.io](https://azurelocal.cloud/standards/) is synced from `platform/standards/` by a scheduled workflow on the .github.io repo. No manual sync needed — merge on platform and wait for the next sync.

## Review rubric

Reviewers check:

1. Is the rule concrete enough to follow without interpretation?
2. Is the rationale specific (cites an incident, an ADR, or an industry reference)?
3. Are both ✓ Good and ✗ Bad examples present (when the rule isn't self-evident)?
4. Is enforcement documented (even if it's "manual review")?
5. Are exceptions documented (even if it's "no exceptions")?
6. Does the change match what the ADR decided?

## Related

- [Authoring guide](authoring-guide.md) — file skeleton
- [Propagation](propagation.md) — how a merged change reaches consumers
- [Governance → ADR process](../governance/adr-process.md)
