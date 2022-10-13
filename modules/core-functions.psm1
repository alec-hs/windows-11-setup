# Restart Windows Explorer Process
Function Restart-Explorer {
    Write-Output "Restarting Explorer process..."
    Stop-Process -processname explorer
}

# Restart Computer
Function Restart-Computer {
    Write-Output "Restarting PC..."
    shutdown -r -t 0 
}

# Reload Path
Function Reset-Path {
    Write-Output "Reloading Path Variable..." `n
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") 
}

# Removes Script Related Files
Function Remove-ScriptFiles {
    Write-Output "Removing files related to this script..."
    Remove-Item .\app-files -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item .\modules -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item .\README.md -Force -ErrorAction SilentlyContinue
    Remove-Item .\setup.ps1 -Force -ErrorAction SilentlyContinue
    Remove-Item .\LICENSE -Force -ErrorAction SilentlyContinue
}

Function Test-CommandExists {
    Param ($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'
    try {if(Get-Command $command){RETURN $true}}
    Catch {RETURN $false}
    Finally {$ErrorActionPreference=$oldPreference}
}

# End Script
Function Show-ScriptEnding {
    # Notify User
    Write-Output " `n### Script Complete ###`n`nLog can be found here: .\setup.log`n`n### PC will now reboot ###"
    Pause
} 

# Allow code block to run as admin - note block cannot contain double quotes must use single quotes
Function Start-ElevatedCode {
    param([string]$file)
    Start-Process PowerShell -Verb RunAs "-NoExit -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$file';`"" -Wait
}

Function Stop-ElevatedCode {
    Write-Output "Elevated code completed, exiting in 10 secs..."
    Start-Sleep -Seconds 10
    Exit
}
