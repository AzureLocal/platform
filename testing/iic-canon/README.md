# IIC Canon

**Canonical synthetic identity data for all AzureLocal test fixtures.**

Treated as frozen post-v1. Any change requires an ADR in [`decisions/`](../../decisions) — one edit here can cascade across every MAPROOM run in every product repo.

## Why canonical

Every AzureLocal repo needs fake data for tests. Without a canonical standard, each repo invents its own — "acme.local", "contoso", "demo-cluster-01" — and drift accumulates. IIC is the one shared fiction.

- **Company**: Infinite Improbability Corp
- **Domain**: `iic.local`
- **NetBIOS**: `IMPROBABLE`
- **Public domain**: `improbability.cloud`
- **Cluster**: `azlocal-iic-s2d-01`
- **Nodes**: `azl-iic-n01`, `azl-iic-n02`, `azl-iic-n03`, `azl-iic-n04`
- **FQDNs**: `azl-iic-n01.iic.local` …

## Files

| File | Content |
|---|---|
| `iic-org.json` | Company metadata, domain, users, tenants, subscriptions |
| `iic-cluster-01.json` | Full topology of `azlocal-iic-s2d-01` — nodes, drives, pool, volumes |
| `iic-networks.json` | Management, storage, compute network definitions |

## Consumer pattern

```powershell
$iic = Get-Content ../../platform/testing/iic-canon/iic-org.json | ConvertFrom-Json
$clusterFqdn = (Get-Content ../../platform/testing/iic-canon/iic-cluster-01.json | ConvertFrom-Json).ClusterFqdn
```

Or through the helper:

```powershell
Import-Module AzureLocal.Common
$identity = Resolve-IICIdentity -Object Cluster01
```

## Schema

Validated by [`../maproom/schema/iic-canon.schema.json`](../maproom/schema/iic-canon.schema.json). Schema violation fails platform CI.
