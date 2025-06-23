# Restart Windows Explorer Process
Function Restart-Explorer {
    [CmdletBinding()]
    param()
    
    Write-Verbose "Restarting Explorer process..."
    try {
        Stop-Process -Name explorer -Force -ErrorAction Stop
        Write-Verbose "Explorer process restarted successfully"
    }
    catch {
        Write-Error "Failed to restart Explorer: $_"
        throw
    }
}

# Restart Computer
Function Restart-Computer {
    [CmdletBinding()]
    param(
        [int]$Timeout = 0
    )
    
    Write-Verbose "Restarting PC..."
    try {
        shutdown -r -t $Timeout
    }
    catch {
        Write-Error "Failed to restart computer: $_"
        throw
    }
}

# Reload Path
Function Reset-Path {
    [CmdletBinding()]
    param()
    
    Write-Verbose "Reloading Path Variable..."
    try {
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
        Write-Verbose "Path variable reloaded successfully"
    }
    catch {
        Write-Error "Failed to reload Path variable: $_"
        throw
    }
}

# Removes Script Related Files
Function Remove-ScriptFiles {
    [CmdletBinding()]
    param()
    
    Write-Verbose "Removing files related to this script..."
    try {
        $filesToRemove = @(
            '.\app-files',
            '.\modules',
            '.\README.md',
            '.\setup.ps1',
            '.\LICENSE'
        )
        
        foreach ($file in $filesToRemove) {
            if (Test-Path $file) {
                Remove-Item $file -Recurse -Force -ErrorAction Stop
                Write-Verbose "Removed: $file"
            }
        }
    }
    catch {
        Write-Error "Failed to remove script files: $_"
        throw
    }
}

Function Test-CommandExists {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Command
    )
    
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'
    try {
        if (Get-Command $Command) {
            return $true
        }
    }
    catch {
        return $false
    }
    finally {
        $ErrorActionPreference = $oldPreference
    }
}

# End Script
Function Show-ScriptEnding {
    [CmdletBinding()]
    param()
    
    Write-Output "`n### Script Complete ###`n`nLog can be found here: .\setup.log`n`n### PC will now reboot ###"
    Pause
}

# Allow code block to run as admin - note block cannot contain double quotes must use single quotes
Function Start-ElevatedCode {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [string]$File
    )
    
    try {
        $currentPath = Get-Location
        $command = "-NoExit -ExecutionPolicy Bypass -Command `"cd '$currentPath'; & '$File';`""
        Start-Process PowerShell -Verb RunAs -ArgumentList $command -Wait -ErrorAction Stop
        Write-Verbose "Elevated code execution completed successfully"
    }
    catch {
        Write-Error "Failed to execute elevated code: $_"
        throw
    }
}

Function Stop-ElevatedCode {
    [CmdletBinding()]
    param(
        [int]$DelaySeconds = 10
    )
    
    Write-Output "Elevated code completed, exiting in $DelaySeconds seconds..."
    Start-Sleep -Seconds $DelaySeconds
    Exit
}

# Export functions
Export-ModuleMember -Function Restart-Explorer,
    Restart-Computer,
    Reset-Path,
    Remove-ScriptFiles,
    Test-CommandExists,
    Show-ScriptEnding,
    Start-ElevatedCode,
    Stop-ElevatedCode
