# {{REPO_NAME}}

{{DESCRIPTION}}

[![CI — Bicep](https://github.com/AzureLocal/{{REPO_NAME}}/actions/workflows/ci-bicep.yml/badge.svg)](https://github.com/AzureLocal/{{REPO_NAME}}/actions/workflows/ci-bicep.yml)

## Prerequisites

- Azure subscription
- Azure CLI with Bicep extension
- (Optional) Terraform ≥ 1.5

## Deployment

```powershell
# Bicep
az deployment group create \
  --resource-group rg-{{REPO_NAME}} \
  --template-file src/bicep/main.bicep \
  --parameters @config/variables/variables.yml
```

## Documentation

[azurelocal.github.io/{{REPO_NAME}}](https://azurelocal.github.io/{{REPO_NAME}}/)

## License

MIT — see [LICENSE](LICENSE).
