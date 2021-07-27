# Remove Desktop Shortcuts
Function Remove-DesktopShortcuts {
    # check paths first
    Write-Output "Removing Desktop shortcuts..." `n
    $paths = @("C:\Users\$env:UserName\Desktop\*.lnk","C:\Users\Public\Desktop\*.lnk","C:\Users\$env:UserName\OneDrive\$env:ComputerName\Desktop\*.lnk")
    $paths.ForEach({
        if (Test-Path $_) {
            Remove-Item $_ -Force
        }
    })
}

# Set Explorer Options in Registry
Function Set-ExplorerOptions {
    Write-Output "Setting File Explorer Options..."
    $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty $key "Hidden" 1                        # Show hidden file
    Set-ItemProperty $key "HideFileExt" 0                   # Show file extensions
    Set-ItemProperty $key "LaunchTo" 1                      # Launch Explorer to "This PC"
    Set-ItemProperty $key "AutoCheckSelect" 1               # Show check boxes in explorer
    Set-ItemProperty $key "DontPrettyPath" 1                # Keep user path case
    Set-ItemProperty $key "MultiTaskingAltTabFilter" 3      # Alt Tab to Windows only, no Edge Tabs
}

# Hide all icons from desktop
Function Set-DesktopIconsHidden {
	Write-Output "Hiding all icons from desktop..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 1
}

# Move home folders to OneDrive
Function Move-HomeFolders {
   
}

# Create additional folders
Function Add-AdditionalFolders {
    New-Item -Path "C:\" -Name "Temp" -ItemType "Directory"
    New-Item -Path "C:\" -Name "Tools" -ItemType "Directory"
    New-Item -Path $env:USERPROFILE -Name "Source" -ItemType "Directory"
}