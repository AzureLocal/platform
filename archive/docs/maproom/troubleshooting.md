---
title: MAPROOM troubleshooting
---

# MAPROOM troubleshooting

Common failure modes and the fix for each.

## `Import-Module` fails — module not found

**Symptom:**

```text
Import-Module: The specified module 'AzureLocal.Maproom.psd1' was not loaded because
no valid module file was found in any module directory.
```

**Cause:** Path to the `.psd1` is wrong, or `PLATFORM_ROOT` isn't set in CI.

**Fix:**

- Locally: `Import-Module ./testing/maproom/AzureLocal.Maproom.psd1 -Force` from the platform repo root.
- In CI via the reusable workflow: the workflow sets `PLATFORM_ROOT`. Access the module with `Import-Module (Join-Path $env:PLATFORM_ROOT 'testing/maproom/AzureLocal.Maproom.psd1') -Force`.

## `Test-MaproomFixture` fails schema validation

**Symptom:**

```text
Test-MaproomFixture: fixture does not match schema:
- required property 'infrastructure_type' missing
- property 'nodeCount' should be integer, got string
```

**Cause:** Fixture is missing a required field or has a type mismatch.

**Fix:** Open the fixture JSON and compare against `testing/maproom/schema/fixture.schema.json`. Every fixture must declare:

- `infrastructure_type` (one of the registered values)
- `_metadata` (with at least `name`, `author`, `createdAt`)

If the type you want isn't in the enum, see [Extending the framework → Adding a new infrastructure_type](extending-the-framework.md#adding-a-new-infrastructure_type).

## `Get-IICCanonPath` returns nothing

**Symptom:**

```text
Get-IICCanonPath: no canon file found for infrastructure_type 'avd_azure_local'
```

**Cause:** The canon for that type hasn't been authored yet. Only `azure_local` is present in v0.2.0.

**Fix:** AVD and SOFS canons are scheduled for v0.3.0 (see ADR-0004). Either:

- Use `azure_local` canon if your assertions are at the infra-fabric layer.
- Author a consumer-local fixture rather than referencing a canon.
- Contribute the missing canon via a platform PR.

## Pester discovers no tests

**Symptom:** `Invoke-Pester` completes with "0 tests run."

**Cause:** Test file naming convention not followed, or wrong path.

**Fix:**

- File must end with `.Tests.ps1`.
- Place under `tests/maproom/unit/` or the path configured in the reusable workflow's `pester-test-path` input.
- Check `BeforeAll` hasn't thrown silently — add `Write-Host` at the top of `BeforeAll` to confirm it runs.

## Fixture is valid but tests fail

**Symptom:** `Test-MaproomFixture` passes, but `Import-MaproomFixture` returns an object whose properties don't match what the Pester test expects.

**Cause:** Casing mismatch. JSON property names are case-sensitive when projected into PowerShell.

**Fix:** The schema and canon use camelCase (`nodeCount`, not `NodeCount`). Match exactly:

```powershell
$script:canon.nodeCount        # works
$script:canon.NodeCount        # returns $null
```

## CI passes locally, fails on GitHub — path separators

**Symptom:** Tests pass on Windows locally but fail on `ubuntu-latest` in CI with "file not found" errors.

**Cause:** Backslashes in `Join-Path` literals don't work on Linux.

**Fix:** Use forward slashes or `Join-Path` with multiple arguments (never literal `\`):

```powershell
# Bad
$p = "$env:PLATFORM_ROOT\testing\maproom\AzureLocal.Maproom.psd1"

# Good
$p = Join-Path $env:PLATFORM_ROOT 'testing/maproom/AzureLocal.Maproom.psd1'
```

## Reusable workflow fails — "unable to find reusable workflow"

**Symptom:**

```text
error: .github/workflows/ci.yml:7:5: unable to find reusable workflow
'AzureLocal/platform/.github/workflows/reusable-maproom-run.yml@main'
```

**Cause:** Consumer is pinning to a tag or branch that doesn't exist yet, or the platform repo is private.

**Fix:**

- Verify platform repo is public (required for cross-repo reusable workflow calls from public consumers).
- Confirm the ref exists: `git ls-remote https://github.com/AzureLocal/platform main`.
- For pre-stable, use `@main`. For post-stable, use `@v1`.

## Fixture schema changed — old fixtures break

**Symptom:** After a platform minor bump, previously-green consumer fixtures fail `Test-MaproomFixture`.

**Cause:** Schema tightening is a breaking change and should have bumped major. If it was merged as minor, that's a release bug.

**Fix:**

1. File an issue on platform.
2. Pin consumer's platform reference to the previous tag (e.g., `@v0.2.0`) until platform releases a fix.
3. Platform rollback or forward-fix; see [breaking changes](../governance/breaking-changes.md).

## `powershell-yaml` not installed

**Symptom:** `Get-AzureLocalRepoInventory` warns about falling back to the minimal YAML parser.

**Cause:** `AzureLocal.Common` supports two code paths — full `powershell-yaml` parsing and a minimal regex fallback. CI usually has the module; dev machines may not.

**Fix:** `Install-Module powershell-yaml -Scope CurrentUser`. The fallback is intentional for minimal environments — it's correct for simple `.azurelocal-platform.yml` files but does not handle all YAML.

## Still stuck

- Ask in an issue on [AzureLocal/platform](https://github.com/AzureLocal/platform/issues) with the full error, the fixture, and the Pester output.
- Check existing issues labeled `bug` or `maproom` first.
