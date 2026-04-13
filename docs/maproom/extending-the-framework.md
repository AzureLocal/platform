---
title: Extending the MAPROOM framework
---

# Extending the MAPROOM framework

MAPROOM v0.2.0 is intentionally minimal — three functions, one schema, one canon. Extending it means adding an `infrastructure_type`, a canon file, a helper function, or a schema section.

## Adding a new `infrastructure_type`

The type registry is:

```text
azure_local · avd_azure · avd_azure_local · sofs_azure_local · aks_azure_local · loadtools · vm_conversion · copilot
```

To add a new type (e.g., `sql_azure_local`):

1. **Schema.** Edit `testing/maproom/schema/fixture.schema.json`:

    ```json
    {
      "properties": {
        "infrastructure_type": { "enum": [..., "sql_azure_local"] }
      },
      "allOf": [
        {
          "if": { "properties": { "infrastructure_type": { "const": "sql_azure_local" } } },
          "then": { "properties": { "sql_instances": { "type": "array" } } }
        }
      ]
    }
    ```

2. **Canon.** Author `testing/iic-canon/iic-sql-azure-local-01.json`. Freeze it before shipping.

3. **Docs.** Add a row to the canon table in [IIC canon](iic-canon.md) and update [overview](overview.md).

4. **ADR.** New `infrastructure_type` values are additive, so no major bump — but document the consumer that drove it and the canon in an ADR or release note.

5. **Consumer.** Land at least one consumer using the new type before publishing — otherwise you're designing without feedback.

## Adding a canon file for an existing type

Canon files are **frozen after publication**. To add a second canon for an existing type (e.g., a two-node variant of `azure_local`):

1. New filename: `iic-azure-local-02.json`. Never edit the existing `-01.json`.
2. Validates against the same schema.
3. Consumers opt in by switching their `Get-IICCanonPath` call once the new canon is ready.

## Adding a new public function

New function = new `feat(maproom):` commit = minor bump.

1. Add the function to `testing/maproom/framework/Public/<FunctionName>.ps1`.
2. Dot-source it from `AzureLocal.Maproom.psm1` (or rely on the existing `Public/*.ps1` loader).
3. Export from `AzureLocal.Maproom.psd1` under `FunctionsToExport`.
4. Add Pester tests under `testing/maproom/tests/`.
5. Document it in [framework architecture](framework-architecture.md).

## Reserved schema sections — filling them in

The four reserved top-level sections (`compliance`, `performance`, `user_journey`, `iac`) are **empty** in v0.2.0. They exist so that deferred toolsets (COMPASS, PULSE, STORYBOARD, BLUEPRINT) do not require a breaking schema change when they ship.

To fill one (v0.3.0+):

1. Propose via ADR (see ADR-0004 for the pattern).
2. Define the sub-schema inside `fixture.schema.json` under the reserved key.
3. Update at least one canon file to include a representative (possibly minimal) example under that key.
4. Publish the helper module (e.g., `AzureLocal.Compass`) as a sibling to `AzureLocal.Maproom`.

## Adding a primitive

Primitives are domain concepts like "pool", "tier", "volume", "witness." In v0.2.0 these are S2D-specific and live under `if: infrastructure_type == azure_local`.

Adding a primitive to a non-S2D type:

1. Decide the shape in ADR.
2. Add it under the appropriate `if/then` branch in `fixture.schema.json`.
3. Author a canon example.
4. Only then extend PS helper functions if needed.

## Breaking changes to the framework

See [governance/breaking-changes](../governance/breaking-changes.md) for the full list.

Framework changes that are **not** breaking:

- Adding a new function
- Adding a new `infrastructure_type` value
- Adding a new canon file
- Adding an optional property to the schema

Framework changes that **are** breaking:

- Renaming an existing function or parameter
- Removing a function or canon file
- Tightening schema (previously-accepted fixtures now fail)
- Changing an existing property's type

## Deprecation pattern

When replacing a function, ship the replacement first, then mark the old one deprecated:

```powershell
function Get-MaproomCanonPath {
    [CmdletBinding()]
    param(...)

    Write-Warning "Get-MaproomCanonPath is deprecated; use Get-IICCanonPath instead."
    Get-IICCanonPath @PSBoundParameters
}
```

Keep the deprecated function through one minor release, remove it on the next major.

## When to punt an extension

If a consumer is asking for a framework change that only they will use:

- Fold it into their repo as a local helper, not MAPROOM.
- Revisit centralising once a second consumer asks for the same shape.

Two consumers is the minimum signal that a primitive belongs in platform, per ADR-0003.
