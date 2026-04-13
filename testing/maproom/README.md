# MAPROOM

Offline, fixture-based testing framework for AzureLocal repos. Ships as the
`AzureLocal.Maproom` PowerShell module (v0.2.0).

## Layout

```text
maproom/
├── AzureLocal.Maproom.psd1   ← module manifest
├── AzureLocal.Maproom.psm1   ← module source
└── schema/
    └── fixture.schema.json   ← JSON Schema (draft-07) for all fixture files
```

IIC canon fixtures live alongside in `../iic-canon/`.

## Consumer pattern

A product repo imports the module and writes its own fixtures:

```yaml
# In consumer CI (validate.yml):
- uses: actions/checkout@v4
  with: { repository: AzureLocal/platform, path: _platform, ref: main }
- shell: pwsh
  run: |
    Import-Module .\_platform\testing\maproom\AzureLocal.Maproom.psd1 -Force
    Test-MaproomFixture -Path .\tests\maproom\Fixtures\my-cluster.json
```

Product repos keep their own `tests/maproom/Fixtures/*.json`. The platform
provides the schema, module, and canonical IIC fixtures.

## Documentation

- [Framework architecture](../../docs/maproom/framework-architecture.md)
- [Authoring fixtures](../../docs/maproom/authoring-fixtures.md)
- [Writing unit tests](../../docs/maproom/writing-unit-tests.md)
- [IIC canon](../../docs/maproom/iic-canon.md)
