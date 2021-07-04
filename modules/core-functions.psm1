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
    Remove-Item .\app-files -Recurse -Force
    Remove-Item .\modules -Recurse -Force
    Remove-Item .\README.md -Force
    Remove-Item .\setup.ps1 -Force
}

# End Script
Function Show-ScriptEnding {
    # Notify User
    Write-Output " `n### Script Complete ###`n`nLog can be found here: .\setup.log`n`n### PC will now reboot ###"
    Pause
} 
