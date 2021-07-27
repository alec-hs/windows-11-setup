## TODO ##
#dot files
#dot files repo
#scheduled task to commit dot
#gpg key
#nordpass, spotify, adobe, teamviewer all fail checksums
#mouse settings
#ps7 as default
#clean start menu
#home folders

# Start Transcript
Start-Transcript -Path ".\setup.log"

# Set execution policy to allow online PS scripts for this session
Write-Output "Setting Execution Policy for Session..."`n
Set-ExecutionPolicy -ExecutionPolicy 'Bypass' -Scope 'Process' -Force

# Import Module Files
Write-Output "Importing Modules..."
Import-Module ".\modules\core-functions.psm1"
Import-Module ".\modules\computer-functions.psm1"
Import-Module ".\modules\user-functions.psm1"
Import-Module ".\modules\app-functions.psm1"
Import-Module BitsTransfer

# Create some folders I use
# TODO - check if folders already exist 
Add-AdditionalFolders

# Set Networks to Private=
Set-NetworkTypes

# Set File Explorer options
Set-ExplorerOptions

# Hide all Desktop Icons
Set-DesktopIconsHidden

# Remove Default Programs
Remove-WindowsBloatApps

# Move Home Folders to OneDrive
Move-HomeFolders

# Restart Explorer
Restart-Explorer

# Install My Apps with Winget
Install-MyAppsWinget

# Install Choco
Install-Choco

# Install My Apps with Choclatey
Install-MyAppsChoco

# Install Logitech Gaming Hub
Install-LGHub

# Install ChoEazy
Install-ChoEazyCopy

# Enable Windows Features
Enable-HyperV
Enable-WSL2

# Reload PATH from Environment Variables
Reset-Path

# Delete Desktop Shortcuts
Remove-DesktopShortcuts

# Restart explorer
Restart-Explorer

# Delete script files
Remove-ScriptFiles

# End Transcript
Stop-Transcript

# End Script
Show-ScriptEnding

# Restart PC
Restart-Computer