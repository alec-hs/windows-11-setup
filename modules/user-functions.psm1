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
    Write-Output "Setting File Explorer Options..." `n
    $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty $key "Hidden" 1                        # Show hidden file
    Set-ItemProperty $key "HideFileExt" 0                   # Show file extensions
    Set-ItemProperty $key "LaunchTo" 1                      # Launch Explorer to "This PC"
    Set-ItemProperty $key "AutoCheckSelect" 1               # Show check boxes in explorer
    Set-ItemProperty $key "DontPrettyPath" 1                # Keep user path case
    Set-ItemProperty $key "MultiTaskingAltTabFilter" 3      # Alt Tab to Windows only, no Edge Tabs
    $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
    Set-ItemProperty $key "ShowRecent" 0                    # Hide recent files in quick access
    Set-ItemProperty $key "ShowFrequent" 0                  # Hide frequent folder in quick access
}

# Set Theme Options 
Function Set-ThemeOptions {
    Write-Output "Setting Theme Options..." `n
    $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    Set-ItemProperty $key "AppsUseLightTheme" 0             # Set to Dark 
    Set-ItemProperty $key "ColorPrevalence" 0               # Set to Dark
    Set-ItemProperty $key "SystemUsesLightTheme" 0          # Set to Dark
    # Update Background - will update on reboot
    $key = "HKCU:\Control Panel\Desktop"
    $bkgrnd = "C:\Users\alec-hs\OneDrive\Documents\Backgrounds + Avatars\Other\Abstract\AbstractTBW1.png"
    attrib.exe $bkgrnd +P /s
    Set-ItemProperty $key "WallPaper" $bkgrnd
}

# Set Mouse Options in Registry to disable acceleration
Function Set-MouseOptions {
    Write-Output "Setting Mouse options..." `n
    $key = "HKCU:\Control Panel\Mouse"
    Set-ItemProperty $key "MouseSpeed" 0
    Set-ItemProperty $key "MouseThreshold1" 0
    Set-ItemProperty $key "MouseThreshold2" 0
}

# Hide all icons from desktop
Function Set-DesktopIconsHidden {
	Write-Output "Hiding all icons from desktop..." `n
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 1
}

# Move home folders to OneDrive
Function Move-HomeFolders {
   $hostname = $env:computername.ToLower()
   $user = $env:username
   $path = "C:\Users\$user\OneDrive\Computers\$hostname"
   $folders = "Desktop","Documents","Music","Pictures","Videos"

   ForEach ($folder in $folders) {
    New-Item -Path "$path" -Name $folder -ItemType "Directory" -Force
    Set-KnownFolderPath -KnownFolder $folder -Path "$path\$folder"
   }   
}

# Create additional folders and pin to quick access
Function Add-AdditionalFolders {
    New-Item -Path "C:\" -Name "Temp" -ItemType "Directory" -Force
    $srcPath = [Environment]::GetFolderPath("MyDocuments")
    New-Item -Path $srcPath -Name "Source" -ItemType "Directory" -Force
    $o = New-Object -ComObject Shell.Application
    $o.NameSpace("C:\Temp").Self.InvokeVerb("pintohome")
    $o.NameSpace("$srcPath\Source").Self.InvokeVerb("pintohome")
}

# Setup dotfile repo
Function Install-Dotfiles {
    Write-Output "Installing dotfiles..." `n
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/alec-hs/dotfiles/main/runOnce.ps1'))
}