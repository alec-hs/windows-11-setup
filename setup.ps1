## TODO ##
#adobe
#mouse settings
#ps7 as default
#clean start menu
#home folders
#link shell extension - VS2017 Sp1 Redis

# Import Module Files
Write-Output "Importing Modules..."
Import-Module ".\modules\core-functions.psm1"
Import-Module ".\modules\computer-functions.psm1"
Import-Module ".\modules\user-functions.psm1"
Import-Module ".\modules\app-functions.psm1"
Import-Module BitsTransfer

# Start Transcript
Start-Transcript -Path ".\setup.log"

# Set execution policy to allow online PS scripts for this session
Write-Output "Setting Execution Policy for Session..."`n
Set-ExecutionPolicy -ExecutionPolicy 'Bypass' -Scope 'Process' -Force

# Create some folders I use
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

# Install WSL2 with Debian
Install-WSL2

# Install My Apps with Winget
Install-MyAppsWinget

# Install LG TV Companion App
Install-LGTVCompanion

# Install Choco
#Install-Choco

# Enable Windows Features
Enable-HyperV

# Reload PATH from Environment Variables
Reset-Path

# Delete Desktop Shortcuts
Remove-DesktopShortcuts

# Install dotfiles
Install-Dotfiles

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


