# User Functions Module for Windows 11 Setup
# This module contains functions for customizing Windows 11 user settings

# Remove Desktop Shortcuts
Function Remove-DesktopShortcuts {
    [CmdletBinding()]
    param()
    
    Write-Output "Removing Desktop shortcuts..." `n
    $paths = @(
        "C:\Users\$env:UserName\Desktop\*.lnk",
        "C:\Users\Public\Desktop\*.lnk",
        "C:\Users\$env:UserName\OneDrive\$env:ComputerName\Desktop\*.lnk"
    )
    
    foreach ($path in $paths) {
        try {
            if (Test-Path $path) {
                Remove-Item $path -Force -ErrorAction Stop
                Write-Verbose "Successfully removed shortcuts from $path"
            }
        }
        catch {
            Write-Warning "Failed to remove shortcuts from $path : $_"
        }
    }
}

# Set Explorer Options in Registry
Function Set-ExplorerOptions {
    [CmdletBinding()]
    param()
    
    Write-Output "Setting File Explorer Options..." `n
    try {
        $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        $settings = @{
            "Hidden" = 1                    # Show hidden files
            "LaunchTo" = 1                  # Launch Explorer to "This PC"
            "DontPrettyPath" = 1            # Keep user path case
            "MultiTaskingAltTabFilter" = 3  # Alt Tab to Windows only, no Edge Tabs
        }
        
        foreach ($setting in $settings.GetEnumerator()) {
            Set-ItemProperty -Path $key -Name $setting.Key -Value $setting.Value -ErrorAction Stop
            Write-Verbose "Set $($setting.Key) to $($setting.Value)"
        }
        
        $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
        Set-ItemProperty -Path $key -Name "ShowRecent" -Value 0 -ErrorAction Stop
        Set-ItemProperty -Path $key -Name "ShowFrequent" -Value 0 -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to set Explorer options: $_"
    }
}

# Set Theme Options 
Function Set-ThemeOptions {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$BackgroundPath
    )
    
    Write-Output "Setting Theme Options..." `n
    try {
        $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        $settings = @{
            "AppsUseLightTheme" = 0
            "ColorPrevalence" = 0
            "SystemUsesLightTheme" = 0
        }
        
        foreach ($setting in $settings.GetEnumerator()) {
            Set-ItemProperty -Path $key -Name $setting.Key -Value $setting.Value -ErrorAction Stop
            Write-Verbose "Set $($setting.Key) to $($setting.Value)"
        }
        
        if ($BackgroundPath) {
            $key = "HKCU:\Control Panel\Desktop"
            if (Test-Path $BackgroundPath) {
                attrib.exe $BackgroundPath +P /s
                Set-ItemProperty -Path $key -Name "WallPaper" -Value $BackgroundPath -ErrorAction Stop
                Write-Verbose "Set background to $BackgroundPath"
            }
            else {
                Write-Warning "Background file not found at: $BackgroundPath"
            }
        }
    }
    catch {
        Write-Error "Failed to set Theme options: $_"
    }
}

# Set Mouse Options in Registry to disable acceleration
Function Set-MouseOptions {
    [CmdletBinding()]
    param()
    
    Write-Output "Setting Mouse options..." `n
    try {
        $key = "HKCU:\Control Panel\Mouse"
        $settings = @{
            "MouseSpeed" = 0
            "MouseThreshold1" = 0
            "MouseThreshold2" = 0
        }
        
        foreach ($setting in $settings.GetEnumerator()) {
            Set-ItemProperty -Path $key -Name $setting.Key -Value $setting.Value -ErrorAction Stop
            Write-Verbose "Set $($setting.Key) to $($setting.Value)"
        }
    }
    catch {
        Write-Error "Failed to set Mouse options: $_"
    }
}

# Hide all icons from desktop
Function Set-DesktopIconsHidden {
    [CmdletBinding()]
    param()
    
    Write-Output "Hiding all icons from desktop..." `n
    try {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 1 -ErrorAction Stop
        Write-Verbose "Successfully hidden desktop icons"
    }
    catch {
        Write-Error "Failed to hide desktop icons: $_"
    }
}

# Move home folders to OneDrive
Function Move-HomeFolders {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$OneDriveBasePath = "C:\Users\$env:USERNAME\OneDrive\Computers"
    )
    
    try {
        $hostname = $env:computername.ToLower()
        $path = Join-Path $OneDriveBasePath $hostname
        $folders = "Desktop","Documents","Music","Pictures","Videos"

        foreach ($folder in $folders) {
            $folderPath = Join-Path $path $folder
            New-Item -Path $path -Name $folder -ItemType "Directory" -Force -ErrorAction Stop
            Set-KnownFolderPath -KnownFolder $folder -Path $folderPath -ErrorAction Stop
            Write-Verbose "Successfully moved $folder to $folderPath"
        }
    }
    catch {
        Write-Error "Failed to move home folders: $_"
    }
}

# Create additional folders and pin to quick access
Function Add-AdditionalFolders {
    [CmdletBinding()]
    param()
    
    try {
        $tempPath = "C:\Temp"
        $sourcePath = Join-Path [Environment]::GetFolderPath("MyDocuments") "Source"
        
        New-Item -Path "C:\" -Name "Temp" -ItemType "Directory" -Force -ErrorAction Stop
        New-Item -Path $sourcePath -ItemType "Directory" -Force -ErrorAction Stop
        
        $shell = New-Object -ComObject Shell.Application
        $shell.NameSpace($tempPath).Self.InvokeVerb("pintohome")
        $shell.NameSpace($sourcePath).Self.InvokeVerb("pintohome")
        
        Write-Verbose "Successfully created and pinned additional folders"
    }
    catch {
        Write-Error "Failed to create additional folders: $_"
    }
}

# Setup dotfile repo
Function Install-Dotfiles {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$DotfilesUrl = "https://raw.githubusercontent.com/alec-hs/dotfiles/main/runOnce.ps1"
    )
    
    Write-Output "Installing dotfiles..." `n
    try {
        $script = Invoke-WebRequest -Uri $DotfilesUrl -UseBasicParsing -ErrorAction Stop
        Invoke-Expression $script.Content
        Write-Verbose "Successfully installed dotfiles"
    }
    catch {
        Write-Error "Failed to install dotfiles: $_"
    }
}