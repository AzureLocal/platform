# Testing Infrastructure — Repo Survey

> **Date**: 2026-04-13  
> **Purpose**: Ground-truth audit of current test surfaces across all AzureLocal sibling repos.  
> **Used by**: [ADR-0004](../../decisions/0004-testing-toolset-classification.md) — testing toolset classification

---

## Summary table

| Repo | Has tests | Frameworks | What it tests | CI test job | MAPROOM / TRAILHEAD |
|------|:---------:|-----------|--------------|-------------|:-------------------:|
| azurelocal-avd | ✓ | Pester 5, Python jsonschema | Config loading, schema validation, AVD deployment scripts | `ci-powershell.yml` — Pester + PSScriptAnalyzer | — |
| azurelocal-sofs-fslogix | ✓ | Pester 5 | SOFS single/triple layout, state management, schema validation | `validate-automation.yml` — Pester, PSScriptAnalyzer, Terraform, Bicep, Ansible | — |
| azurelocal-loadtools | ✓ | Pester 5, pytest | ConfigManager, Logger, ReportGenerator, StateManager modules; code coverage via JaCoCo | `run-tests.yml` — Pester with coverage, PSScriptAnalyzer | — |
| azurelocal-vm-conversion-toolkit | ✗ | — | Nothing | None (docs/structure validation only) | — |
| azurelocal-toolkit | ✗ | — | Nothing (empty `tests/`) | None (docs/structure validation only) | — |
| azurelocal-copilot | ✗ | — | Nothing | None | — |
| azurelocal-training | ✗ | — | Nothing | None | — |
| azurelocal-nutanix-migration | ✗ | — | Nothing | None | — |
| azurelocal-ranger | ✓ | Pester 5 (MAPROOM), field scripts (TRAILHEAD) | Unit (8): Config, DriftDetection, NetworkDevice, Outputs, Runtime, Simulation, StorageNetworkingCollector, WorkloadIdentityAzureCollector; Integration: EndToEnd | `publish-psgallery.yml` — Pester on release; `validate.yml` — manifest/import | ✓ Both |
| azurelocal-S2DCartographer | ✓ | Pester 5 (MAPROOM), field scripts (TRAILHEAD) | Unit (9): S2D capacity, health, disk, reserve, efficiency, storage pool, volume, FQDN resolution; Integration: synthetic cluster | `validate.yml` — Pester unit tests on PR/push with result publishing | ✓ Both (origin) |
| azurelocal-surveyor | ✓ | Vitest (TypeScript) | Parity calculations, engine logic; type checking, linting | `ci.yml` — `npm run test` (Vitest), typecheck, lint, build | — |

---

## Per-repo detail

### azurelocal-avd

**Current surface:** Pester tests cover the config-loader module and schema validation. Python `jsonschema` validates `variables.example.yml` against the JSON Schema. PSScriptAnalyzer runs on all PS scripts.

**Unmet needs:**

- No integration tests — deployment scripts aren't tested against a synthetic AVD environment.
- No fixture-based testing for host pool shape (candidate: MAPROOM `avd_azure_local` fixture type).
- No user-journey validation (candidate: STORYBOARD when it ships).

**Proposed toolset mapping:**

| Need | Toolset | Phase |
|------|---------|-------|
| Host pool shape assertions | MAPROOM (`avd_azure_local` fixture type) | Phase 2 prep (v0.2.0 schema) |
| AVD user-journey validation | STORYBOARD | v0.3.0 |

---

### azurelocal-sofs-fslogix

**Current surface:** Pester tests cover SOFS deployment scripts for single-node and triple-node layouts, plus state management. Multi-tool CI (Terraform, Bicep, Ansible) validates IaC files.

**Unmet needs:**

- No fixture-based testing for FSLogix profile container shape.
- Load validation (file-share I/O patterns) not tested (candidate: PULSE).

**Proposed toolset mapping:**

| Need | Toolset | Phase |
|------|---------|-------|
| FSLogix profile shape assertions | MAPROOM (`sofs_azure_local` fixture type) | Phase 2 prep (v0.2.0 schema) |
| File-share load profiles | PULSE | v0.3.0 |

---

### azurelocal-loadtools

**Current surface:** Most mature testing in the org — Pester with JaCoCo code coverage, PSScriptAnalyzer, multi-tool IaC validation. Tests the load tool's own modules (ConfigManager, Logger, ReportGenerator, StateManager).

**Unmet needs:**

- Tests cover the *tool*, not the load profiles it emits. No assertions about whether a given profile is valid for a given cluster shape.
- Coverage-to-expected-cluster-shape correlation is manual today (candidate: PULSE).

**Proposed toolset mapping:**

| Need | Toolset | Phase |
|------|---------|-------|
| Load-profile shape validation | PULSE | v0.3.0 |

---

### azurelocal-vm-conversion-toolkit

**Current surface:** None. No test files, no test CI step.

**Unmet needs (everything):**

- Script-level unit tests for the conversion toolkit scripts.
- Pre/post inventory diffing — assert no workloads, disks, or NICs are dropped during conversion (candidate: LEDGER).

**Proposed toolset mapping:**

| Need | Toolset | Phase |
|------|---------|-------|
| Unit tests (repo-local first) | Pester 5 (repo-local) | Phase 3 forcing function |
| Inventory diffing contract | LEDGER | v0.3.0 (after local tests established) |

---

### azurelocal-toolkit

**Current surface:** None. Empty `tests/` directory.

**Unmet needs:** Unit tests for shared PS modules (CanonicalVariable, config-loader, registry-variable, Generate-SolutionConfig). PSScriptAnalyzer at minimum.

**Proposed toolset mapping:** Pester 5 (repo-local), no platform toolset needed until module contracts are defined.

---

### azurelocal-copilot

**Current surface:** None.

**Unmet needs:** Copilot instructions validation — assert `.github/copilot-instructions.md` is well-formed, references valid platform paths. No platform toolset maps cleanly today; this is repo-local work.

---

### azurelocal-training

**Current surface:** None.

**Unmet needs:** Lab environment reproducibility tests — assert a training lab can be stood up cleanly (candidate: OUTPOST, rejected as testing tool; this belongs in Phase 5 templates). Docs build CI is the primary quality gate.

---

### azurelocal-nutanix-migration

**Current surface:** None.

**Unmet needs:**

- Migration runbook validation — assert checklists are complete, scripts are syntactically valid.
- Post-migration inventory diffing (candidate: LEDGER).

**Proposed toolset mapping:**

| Need | Toolset | Phase |
|------|---------|-------|
| Script/checklist validation (repo-local) | Pester 5 | Phase 3 |
| Post-migration inventory diff | LEDGER | v0.3.0 |

---

### azurelocal-ranger

**Current surface:** MAPROOM unit tests (8 test files) and TRAILHEAD field validation scripts. Confirms that the MAPROOM/TRAILHEAD pattern generalises beyond S2D — Ranger is an assessment tool, not a cluster fabric. This is the second consumer that proves the framework abstraction holds.

**Unmet needs:** None critical for Phase 2. Ranger will be the second consumer migrated to platform MAPROOM in Phase 2.

---

### azurelocal-S2DCartographer

**Current surface:** Origin of MAPROOM and TRAILHEAD. Nine Pester unit test files covering S2D capacity, health, disk management, storage pool, and volume calculations. Integration test via synthetic cluster fixture. TRAILHEAD field scripts for live cluster validation.

**Phase 2 action:** S2DCartographer migrates from its own MAPROOM copy to the platform-managed `AzureLocal.Maproom` module. The IIC canon moves to `platform/testing/iic-canon/` and `iic-cluster-01.json` is renamed to `iic-azure-local-01.json` (see ADR-0004 §consequences).

---

### azurelocal-surveyor

**Current surface:** Vitest (TypeScript/React) — unit tests for parity calculations and engine logic. Type checking, linting, and build validation in CI.

**Notes:** Surveyor is a web application. The MAPROOM/TRAILHEAD/Pester paradigm does not apply. Surveyor's test surface is complete for its paradigm. No platform testing toolset maps to it.

---

## IaC pre-deploy assertion gap

`azurelocal-toolkit`, `azurelocal-avd`, and `azurelocal-sofs-fslogix` all run IaC (Bicep, Terraform, ARM, Ansible) through CI. Current CI validates syntax (`bicep build`, `tflint`, `arm-ttk`) but makes no shape assertions — there is no check that a template produces the expected resource types and properties before it is deployed. This gap will affect every future workload repo (`azurelocal-aks`, `azurelocal-sql-ha`, `azurelocal-sql-mi`, `azurelocal-vms`, `azurelocal-ml-ai`, `azurelocal-iot`, `azurelocal-custom-images`). Addressed by BLUEPRINT (ADR-0004, deferred to v0.3.0).

---

## Observations for Phase 2

1. **MAPROOM generalises cleanly to at least one non-S2D consumer today** (Ranger). The pattern holds.
2. **Six repos have zero test infrastructure.** Phase 3's reusable workflow rollout (`reusable-ps-module-ci.yml`, `reusable-iac-validate.yml`) is the practical forcing function to get them testing — the workflows require test hooks.
3. **IIC canon rename** (`iic-cluster-01.json` → `iic-azure-local-01.json`) is the only breaking change Phase 2 introduces to existing consumers. Both S2DCartographer and Ranger are migrated in Phase 2, so the break is absorbed in the same phase.
4. **Deferred toolsets (COMPASS, LEDGER, PULSE, STORYBOARD) each have exactly one or two plausible consumers today.** None are ready to design a platform contract without the consumer repos establishing their own test surfaces first.
