Write-Output "Importing Modules..."
Import-Module ".\modules\computer-functions.psm1"
Import-Module ".\modules\app-functions.psm1"

# Set Networks to Private
Set-NetworkTypes

# Enable Windows Features
Enable-HyperV

# Install WSL2 with Debian
Install-WSL2