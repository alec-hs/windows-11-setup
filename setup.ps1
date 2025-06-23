## Functions Not in Use ##
# Install-Dotfiles

# Import Module Files
Write-Output "Importing Modules..."
Import-Module ".\modules\core-functions.psm1"
Import-Module ".\modules\computer-functions.psm1"
Import-Module ".\modules\user-functions.psm1"
Import-Module ".\modules\app-functions.psm1"
Import-Module ".\modules\folder-paths.psm1"
Import-Module BitsTransfer

# Start Transcript with timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Start-Transcript -Path ".\setup_$timestamp.log"

# Function to verify module imports
function Test-ModuleImports {
    $requiredModules = @(
        "core-functions",
        "computer-functions",
        "user-functions",
        "app-functions",
        "folder-paths"
    )
    
    foreach ($module in $requiredModules) {
        if (-not (Get-Module -Name $module)) {
            throw "Required module '$module' was not imported successfully"
        }
    }
}

# Function to handle script cleanup
function Invoke-ScriptCleanup {
    param (
        [string]$ErrorMessage
    )
    
    Write-Error $ErrorMessage
    Stop-Transcript
    Show-ScriptEnding
    exit 1
}

try {
    # Set execution policy to allow online PS scripts for this session
    Write-Output "Setting Execution Policy for Session..."`n
    if ((Get-ExecutionPolicy -Scope Process) -ne 'Bypass') {
        Set-ExecutionPolicy -ExecutionPolicy 'Bypass' -Scope 'Process' -Force
    }

    # Import Module Files with progress tracking
    Write-Output "Importing Modules..."
    $modules = @(
        ".\modules\core-functions.psm1",
        ".\modules\computer-functions.psm1",
        ".\modules\user-functions.psm1",
        ".\modules\app-functions.psm1",
        ".\modules\folder-paths.psm1"
    )
    
    for ($i = 0; $i -lt $modules.Count; $i++) {
        $module = $modules[$i]
        Write-Progress -Activity "Importing Modules" -Status "Importing $module" -PercentComplete (($i + 1) / $modules.Count * 100)
        Import-Module $module -ErrorAction Stop
    }
    Write-Progress -Activity "Importing Modules" -Completed
    
    # Verify all modules were imported
    Test-ModuleImports
    
    # Import BitsTransfer
    Import-Module BitsTransfer

    # Create some folders I use
    Write-Output "Creating additional folders..."`n
    Add-AdditionalFolders

    # Set Mouse options
    Write-Output "Configuring mouse settings..."`n
    Set-MouseOptions

    # Set File Explorer options
    Write-Output "Configuring File Explorer settings..."`n
    Set-ExplorerOptions

    # Set Theming
    Write-Output "Configuring theme settings..."`n
    Set-ThemeOptions

    # Remove Default Programs
    Write-Output "Removing bloatware..."`n
    Remove-WindowsBloatApps

    # Move Home Folders to OneDrive
    Write-Output "Moving home folders to OneDrive..."`n
    Move-HomeFolders

    # Restart Explorer
    Restart-Explorer

    # Install VC Redist 2017
    Write-Output "Installing Visual C++ Redistributable 2017..."`n
    Install-VCRedist17

    # Install My Apps with Winget
    Write-Output "Installing applications via Winget..."`n
    Install-MyAppsWinget

    # Install Beacn Software
    Write-Output "Installing Beacn software..."`n
    Install-Beacn

    # Install LG TV Companion App
    Write-Output "Installing LG TV Companion..."`n
    Install-LGTVCompanion

    # Reload PATH from Environment Variables
    Reset-Path

    # Restart explorer
    Restart-Explorer

    # Run as Admin Section
    Write-Output "Running elevated tasks..."`n
    Start-ElevatedCode ".\elevated.ps1"

    # Delete script files
    Write-Output "Cleaning up script files..."`n
    Remove-ScriptFiles

    # End Transcript
    Stop-Transcript

    # End Script
    Show-ScriptEnding

    # Restart PC
    Restart-Computer
}
catch {
    Invoke-ScriptCleanup "An error occurred during script execution: $_"
}