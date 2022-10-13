## Functions Not in Use ##
# Set-DesktopIconsHidden
# Install-Choco
# Install-Dotfiles

# Import Module Files
Write-Output "Importing Modules..."
Import-Module ".\modules\core-functions.psm1"
Import-Module ".\modules\computer-functions.psm1"
Import-Module ".\modules\user-functions.psm1"
Import-Module ".\modules\app-functions.psm1"
Import-Module ".\modules\folder-paths.psm1"
Import-Module BitsTransfer

# Start Transcript
Start-Transcript -Path ".\setup.log"

# Set execution policy to allow online PS scripts for this session
Write-Output "Setting Execution Policy for Session..."`n
Set-ExecutionPolicy -ExecutionPolicy 'Bypass' -Scope 'Process' -Force

# Create some folders I use
Add-AdditionalFolders

# Set Mouse  options
Set-MouseOptions

# Set File Explorer options
Set-ExplorerOptions

# Set Theming
Set-ThemeOptions

# Remove Default Programs
Remove-WindowsBloatApps

# Move Home Folders to OneDrive
Move-HomeFolders

# Restart Explorer
Restart-Explorer

# Install VC Redist 2017
Install-VCRedist17

# Install My Apps with Winget
Install-MyAppsWinget

# Instal Beacn Software
Install-Beacn

# Install LG TV Companion App
Install-LGTVCompanion

# Reload PATH from Environment Variables
Reset-Path

# Restart explorer
Restart-Explorer

# Run as Admin Section
Write-Output "Running things that require admin..."`n
Start-ElevatedCode ".\elevated.ps1"

# Delete script files
Remove-ScriptFiles

# End Transcript
Stop-Transcript

# End Script
Show-ScriptEnding

# Restart PC
Restart-Computer