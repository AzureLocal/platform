---
title: Emergency runbooks
---

# Emergency runbooks

These runbooks cover scenarios where something in the platform itself has broken and consumer repos are affected. All platform operations are managed by @kristopherjturner as the sole org maintainer.

!!! warning "Read before acting"
    Each runbook changes live org settings or workflow behaviour. Confirm you understand
    the scope of impact before running any command.

---

## Revert a broken reusable workflow

**Symptoms:** A recent change to a reusable workflow (e.g. `reusable-mkdocs-deploy.yml`) is causing failures in consumer repos that call it via `@main`.

**Resolution:** Pin consumer repos to the last known-good commit SHA or tag until the platform workflow is fixed.

1. Find the last good commit SHA on the platform repo:

    ```bash
    gh api repos/AzureLocal/platform/commits \
      --jq '.[].sha' | head -5
    ```

2. In each affected consumer repo, update the workflow call to pin to that SHA:

    ```yaml
    # Before (floating ref)
    uses: AzureLocal/platform/.github/workflows/reusable-mkdocs-deploy.yml@main

    # After (pinned to known-good SHA)
    uses: AzureLocal/platform/.github/workflows/reusable-mkdocs-deploy.yml@<sha>
    ```

3. Open a PR in each consumer with the pin, merge it to unblock deploys.
4. Fix the platform workflow in a separate PR and re-test.
5. Once the fix is confirmed, revert the consumer pins back to `@main` (or the new version tag).

---

## Restore branch protection on all repos

**Symptoms:** Branch protection has been accidentally removed or altered on one or more repos (e.g. after a repo transfer or settings reset).

**Resolution:** Run `Sync-BranchProtection.ps1` to restore the canonical ruleset in a single pass.

```powershell
# Restore protection on all non-archived repos
./repo-management/org-scripts/Sync-BranchProtection.ps1

# Confirm a specific repo
./repo-management/org-scripts/Sync-BranchProtection.ps1 -Repos azurelocal-ranger
```

The script reports `PASS` or `FAIL` per repo. Any `FAIL` indicates an API error — check `gh auth status` and confirm the token has `admin:org` or repo-admin scope. See [Branch protection](branch-protection.md) for full parameter details.

---

## Recover from a bad drift-audit issue flood

**Symptoms:** `drift-audit.yml` has filed a large number of `drift-report` issues incorrectly (e.g. due to a bug in `Invoke-RepoAudit.ps1` or a transient API error returning bad data).

**Resolution:**

1. Disable future runs by temporarily disabling `drift-audit.yml` in the Actions UI, or adding a `if: false` guard to the workflow job.
2. Close the spurious issues in bulk:

    ```bash
    # List open drift-report issues
    gh issue list --repo AzureLocal/platform --label drift-report --state open

    # Close them (repeat for each issue number, or use a loop)
    gh issue list --repo AzureLocal/platform --label drift-report --state open \
      --json number --jq '.[].number' | \
      xargs -I{} gh issue close {} --repo AzureLocal/platform \
        --comment "Closing — filed in error due to audit script bug. See <fix PR link>."
    ```

3. Fix the root cause in `Invoke-RepoAudit.ps1` and verify locally before re-enabling the schedule:

    ```powershell
    ./repo-management/org-scripts/Invoke-RepoAudit.ps1 -Org AzureLocal
    ```

4. Re-enable the workflow and trigger a manual run to confirm clean output.

---

## Roll back a platform module version

**Symptoms:** An updated platform module (e.g. `AzureLocal.Common`) has introduced a breaking change that affects consumer scripts or workflows.

**Resolution:** Pin consumers to a specific platform ref or SHA until a fix is released.

**For workflow consumers** — pin the `uses:` line to a tag or SHA (same as the reusable workflow runbook above).

**For script consumers** that import directly from the platform clone:

1. Check out the last known-good tag or SHA in the platform clone:

    ```bash
    cd /path/to/platform-clone
    git fetch --tags
    git checkout v0.0.1    # or the specific SHA
    ```

2. Re-run whatever script or import was failing to confirm it works on the pinned version.
3. Once a fix is merged to `main` on the platform, update the consumer to use `main` again.

!!! note "Semantic versioning"
    The platform uses release-please for versioning. Check the `CHANGELOG.md` for the
    version that introduced the breaking change and use the preceding version tag as your
    pin target.

---

## Contact / escalation

The AzureLocal org has a single maintainer. All platform operations, org settings, and emergency changes are owned by **@kristopherjturner**. There is no on-call rotation; file a GitHub Issue on the platform repo with the label `platform` for non-urgent matters.
