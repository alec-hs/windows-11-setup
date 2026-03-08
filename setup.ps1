# Script-level transcript path for cleanup and Show-ScriptEnding
$script:transcriptPath = $null
$script:scriptRoot = Split-Path -Parent $PSCommandPath
$script:startedOutsideScriptRoot = ((Get-Location).Path -ne $script:scriptRoot)

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
    if ($script:transcriptPath) { Stop-Transcript }
    Show-ScriptEnding -LogPath $script:transcriptPath
    exit 1
}

try {
    # Always anchor to repository root so relative paths are stable
    if ($script:startedOutsideScriptRoot) {
        Write-Output "Switching to script directory: $script:scriptRoot"
        Set-Location -Path $script:scriptRoot
    }

    # Set execution policy to allow online PS scripts for this session
    Write-Output "Setting Execution Policy for Session..."`n
    if ((Get-ExecutionPolicy -Scope Process) -ne 'Bypass') {
        try {
            Set-ExecutionPolicy -ExecutionPolicy 'Bypass' -Scope 'Process' -Force
        }
        catch {
            throw "Unable to set process execution policy to Bypass. Run: Set-ExecutionPolicy Bypass -Scope Process -Force"
        }
    }

    # Start Transcript with timestamp
    $script:transcriptPath = Join-Path $script:scriptRoot "setup_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Start-Transcript -Path $script:transcriptPath

    # Import Module Files with progress tracking
    Write-Output "Importing Modules..."
    $modules = @(
        (Join-Path $script:scriptRoot "modules\core-functions.psm1"),
        (Join-Path $script:scriptRoot "modules\computer-functions.psm1"),
        (Join-Path $script:scriptRoot "modules\user-functions.psm1"),
        (Join-Path $script:scriptRoot "modules\app-functions.psm1"),
        (Join-Path $script:scriptRoot "modules\folder-paths.psm1")
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

    # Restart Explorer
    Restart-Explorer

    # Install VC Redist 2015-2022 (latest v14)
    Write-Output "Installing Visual C++ Redistributable 2015-2022..."`n
    Install-VCRedist

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
    Start-ElevatedCode (Join-Path $script:scriptRoot "elevated.ps1")

    # End Transcript before cleanup so log is fully written
    Stop-Transcript

    # Delete script files
    Write-Output "Cleaning up script files..."`n
    Remove-ScriptFiles

    # End Script
    Show-ScriptEnding -LogPath $script:transcriptPath

    # Reminder for manual debloat tools
    Write-Output ""
    Write-Output "========================================"
    Write-Output "OPTIONAL: Run Debloat Tools Now"
    Write-Output "========================================"
    Write-Output "You can run these debloat/privacy tools now in a separate terminal,"
    Write-Output "or skip and run them after reboot."
    Write-Output ""
    Write-Output "1. Chris Titus Windows Utility:"
    Write-Output "   https://christitus.com/windows-tool/"
    Write-Output "   Run: irm christitus.com/win | iex"
    Write-Output ""
    Write-Output "2. Raphi.re Debloat Script:"
    Write-Output "   https://debloat.raphi.re/"
    Write-Output "   Run: irm debloat.raphi.re | iex"
    Write-Output "========================================"
    Write-Output ""
    Read-Host "Press Enter to reboot when ready"

    # Restart PC
    Restart-Computer -Force
}
catch {
    Invoke-ScriptCleanup "An error occurred during script execution: $_"
}