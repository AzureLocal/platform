# Testing

Two complementary testing frameworks for AzureLocal repos.

## MAPROOM — offline, fixture-based

Used when: cluster state can be modeled deterministically and test execution must not touch a live cluster. Works on Linux CI runners.

Lives under [`maproom/`](./maproom). Canonical implementation derived from `azurelocal-S2DCartographer/tests/maproom/` in Phase 2 of the rollout.

## TRAILHEAD — live field validation

Used when: behavior must be validated against a real Azure Local cluster. Checklist-driven, evidence-capturing, manual or semi-automated cycles.

Lives under [`trailhead/`](./trailhead). Templates derived from `azurelocal-S2DCartographer/tests/trailhead/`.

## IIC canon — canonical synthetic identity data

All MAPROOM fixtures and TRAILHEAD templates use the **Infinite Improbability Corp** fictional company, domain `iic.local`, cluster `azlocal-iic-s2d-01`, nodes `azl-iic-n01`..`n04`. Never real customer names in committed test data.

Lives under [`iic-canon/`](./iic-canon). Treated as frozen post-v1 — ADR required for any change.

## Documentation

See [`docs/maproom/`](../docs/maproom) and [`docs/trailhead/`](../docs/trailhead) for authoring guides, harness details, and adoption patterns.
