Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Module init
# ---------------------------------------------------------------------------

# Add exported functions below. One function per file in a src/ subfolder
# is the recommended structure:
#
#   src/
#   ├── Public/
#   │   └── Get-MyThing.ps1
#   └── Private/
#       └── Invoke-InternalHelper.ps1
#
# Then dot-source them here:
#   Get-ChildItem (Join-Path $PSScriptRoot 'src\Public\*.ps1') | ForEach-Object { . $_.FullName }
#   Get-ChildItem (Join-Path $PSScriptRoot 'src\Private\*.ps1') | ForEach-Object { . $_.FullName }
