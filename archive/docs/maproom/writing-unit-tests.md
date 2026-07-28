---
title: Writing unit tests
---

# Writing MAPROOM unit tests

MAPROOM unit tests use Pester 5 to test your module's functions against
in-memory mock data — no live cluster, no CIM sessions, no WinRM. They live
in `tests/maproom/unit/` and run on every PR.

## File naming

Each test file covers one function or class:

```text
tests/maproom/unit/
├── Get-S2DCapacityWaterfall.Tests.ps1
├── Get-S2DHealthStatus.Tests.ps1
└── ConvertTo-S2DCapacity.Tests.ps1
```

## Test structure

```powershell
#Requires -Modules @{ModuleName='Pester';ModuleVersion='5.0'}

BeforeAll {
    $psm1 = Resolve-Path (Join-Path $PSScriptRoot '..\..\..\MyModule.psm1')
    Import-Module $psm1 -Force
}

Describe 'Get-MyFunction' {

    BeforeEach {
        InModuleScope MyModule {
            # Set up internal state the function reads from
            $Script:MySession = @{
                IsConnected = $true
                Data        = @{ Key = 'Value' }
            }
        }
    }

    Context 'Happy path' {
        It 'returns expected result' {
            InModuleScope MyModule {
                $result = Get-MyFunction
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context 'Edge cases' {
        It 'handles empty data gracefully' {
            InModuleScope MyModule {
                $Script:MySession.Data = @{}
                { Get-MyFunction } | Should -Not -Throw
            }
        }
    }
}
```

## Key conventions

**Use `InModuleScope`** for anything that touches internal module state or private
functions. This is the core MAPROOM pattern — you assert on outputs and state
transitions without exposing internals as public API.

**Build data inline** in `BeforeAll` / `BeforeEach`. Do not import fixture JSON
files in unit tests. Fixtures are for integration tests and the synthetic cluster
scripts. Unit tests construct minimal in-memory objects.

**No live cluster.** Unit tests must run offline — no `New-CimSession`, no
`Invoke-Command`, no WinRM. Mock anything that requires connectivity.

**Pester 5 syntax only.** Use `Should -Be`, `Should -Not -BeNullOrEmpty`,
`Should -Throw`, `Should -Match`. Do not use legacy Pester 4 `Should Be` syntax.

## Running tests

```powershell
# All maproom tests
Invoke-Pester -Path .\tests\maproom -Output Detailed

# Unit tests only
Invoke-Pester -Path .\tests\maproom\unit -Output Detailed
```

## CI integration

Consumer CI runs unit tests via the `pester-unit` job in `validate.yml`. The
platform `reusable-ps-module-ci.yml` workflow (Phase 3) will standardize this.

```yaml
- name: Run unit tests
  shell: pwsh
  run: |
    Import-Module .\MyModule.psd1 -Force
    $config = New-PesterConfiguration
    $config.Run.Path = '.\tests\maproom\unit'
    $config.Output.Verbosity = 'Detailed'
    $config.TestResult.Enabled = $true
    $config.TestResult.OutputPath = 'TestResults\pester-results.xml'
    $result = Invoke-Pester -Configuration $config
    if ($result.FailedCount -gt 0) { exit 1 }
```
