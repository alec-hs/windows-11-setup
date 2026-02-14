Import-Module ".\modules\computer-functions.psm1"
Import-Module ".\modules\core-functions.psm1"
Import-Module ".\modules\app-functions.psm1"
Import-Module ".\modules\user-functions.psm1"

# Set Networks to Private
Set-NetworkTypes

# Power: High performance plan and enable hibernation
Set-PowerPlanHighPerformance
Enable-Hibernation

# Install WSL2 with Debian
Install-WSL2

# Delete Desktop Shortcuts
Remove-DesktopShortcuts

# End admin section
Stop-ElevatedCode