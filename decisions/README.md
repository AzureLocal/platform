# Architecture Decision Records

Lightweight, numbered, immutable records of cross-cutting decisions that affect the AzureLocal platform and its consumer repos.

## Index

| # | Title | Status |
|---|---|---|
| [0001](./0001-create-platform-repo.md) | Create AzureLocal platform repo | Accepted |
| [0002](./0002-standards-single-source.md) | Standards as single source of truth | Accepted |
| `0003` | MAPROOM & IIC canon (pending Phase 2) | Proposed |
| `0004` | Reusable workflow split between .github and platform | Proposed |

## When to write an ADR

- Any change to `standards/*.mdx` beyond typo fixes
- New reusable workflow, new input, or breaking change to an existing one
- Any change to `testing/iic-canon/*.json`
- New template variant, or breaking change to an existing variant
- Cross-repo architecture decisions that don't fit neatly in any one repo

## Format

See [`template.md`](./template.md). Sections:

1. **Context** — what problem, what constraints
2. **Decision** — what we chose
3. **Consequences** — what changes, what trade-offs, who is affected
4. **Status** — Proposed, Accepted, Superseded

ADRs are never edited after acceptance — supersede with a new ADR instead.
