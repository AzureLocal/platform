---
title: Rollback
---

# Rollback

If adopting platform breaks something in a consumer repo, this is how to back out. The good news: adoption is additive, so rollback is just "remove the files you added."

## When to roll back

| Symptom | Action |
|---|---|
| `drift-check.yml` fails because a required file's content is wrong | **Fix forward** — edit the file |
| Reusable workflow call fails because platform ref is unavailable | **Fix forward** — change `@main` to a last-known-good SHA |
| Existing CI stopped working after workflow migration | **Roll back the CI migration** (keep the required files) |
| Branch protection settings broke the maintainer's own flow | **Roll back branch protection** only |
| Whole adoption PR caused cascading breakage | **Roll back everything** |

Prefer the smallest rollback that unblocks the team.

## Full rollback

1. Revert the adoption PR:

    ```powershell
    cd <consumer-repo>
    git revert <adoption-merge-sha>
    git push origin main
    ```

2. Remove branch protection (if it was applied and is blocking):

    ```powershell
    gh api --method DELETE "repos/AzureLocal/<repo>/branches/main/protection"
    ```

    Then re-apply once the rollback lands, using platform defaults:

    ```powershell
    ./repo-management/org-scripts/Sync-BranchProtection.ps1 -Repo <repo>
    ```

3. Remove labels that were synced from platform (optional — they're harmless):

    ```powershell
    # Only if labels actively conflict with existing ones
    gh label delete <label-name> --repo AzureLocal/<repo>
    ```

4. The repo is now in its pre-adoption state. `drift-audit.yml` will flag it as non-conformant; that's the expected signal that it needs re-adoption.

## Partial rollback — CI migration only

Sometimes adoption went fine but a subsequent CI migration to reusable workflows broke. Keep the 5 required files, roll back only the CI change:

```powershell
cd <consumer-repo>
git revert <ci-migration-sha>
git push origin main
```

Leave `.azurelocal-platform.yml`, `CHANGELOG.md`, `drift-check.yml`, `mkdocs.yml`, `deploy-docs.yml` in place. The repo remains adopted; only the workflow migration is reverted.

## Partial rollback — branch protection

If branch protection is the only problem:

```powershell
# Relax temporarily
gh api --method PUT "repos/AzureLocal/<repo>/branches/main/protection" `
    -F required_pull_request_reviews.required_approving_review_count=0

# Fix the underlying issue, then re-tighten
./repo-management/org-scripts/Sync-BranchProtection.ps1 -Repo <repo>
```

## Partial rollback — labels

Labels are additive — sync-labels never deletes. Rolling back is just deleting the conflicting label.

```powershell
gh label delete <label-name> --repo AzureLocal/<repo>
```

## What NOT to do

- **Do not delete `.azurelocal-platform.yml` without also reverting the adoption PR.** If you leave the other 4 required files in place but delete the descriptor, `drift-audit.yml` will flag the repo in a confusing partial state.
- **Do not force-push to `main`** to hide the adoption. Revert properly with a new commit so the history is readable.
- **Do not disable `drift-check.yml`** as a way to silence drift warnings. Remove the adoption entirely or fix the underlying issue.

## After rolling back

- [ ] Record *why* you rolled back — an issue or a note on the revert commit is enough.
- [ ] If the rollback exposes a bug in platform (bad reusable workflow, bad template), open a platform issue.
- [ ] Plan the re-adoption. A failed adoption is a signal, not a verdict.
