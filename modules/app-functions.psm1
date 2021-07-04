Function Install-LGHub {
    # Manually install Logitech Gaming Hub
    Write-Output "Installing Logitech G HUB..." `n
    $url = "https://download01.logi.com/web/ftp/pub/techsupport/gaming/lghub_installer.exe"
    $path = ".\app-files\lghub_installer.exe"
    Start-BitsTransfer $url $path
    Start-Process $path -Wait
}

Function Install-ChoEazyCopy {
    # Manually install ChoEazyCopy
    Write-Output "Installing ChoEazyCopy..." `n
    $url = "https://github.com/Cinchoo/ChoEazyCopy/releases/latest/download/ChoEazyCopy.zip"
    $path = ".\app-files\ChoEazyCopy.zip"
    Start-BitsTransfer $url $path
    $installPath = "C:\Tools\"
    if (!(Test-Path $installPath)) {
        New-Item -ItemType Directory -Path $installPath -Force
    }
    Expand-Archive -LiteralPath $path -DestinationPath "$installPath\ChoEazyCopy"
}

Function Set-PS7Default {
    # Set Powershell 7 to Default
    Write-Output "Setting PS7 as Default..." `n
    $key = "HKLM:\Software\Classes\Microsoft.PowerShellScript.1\Shell\Open\Command"
    Set-ItemProperty $key '(Default)' '"C:\Program Files\PowerShell\7\pwsh.exe" "%1"'
}

Function Install-Choco {
    # Setup Chocolatey Package Manager
    Write-Output "Installing Chocolatey Package Manager..." `n
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

Function Install-MyAppsChoco {
    # Update Choco Packages
    Write-Output "Updating Chocolatey Package List..." `n
    choco upgrade all -y

    # Install Apps using Chocolatey
    # GUI Package Manager
    Write-Output "Installing Chocolatey GUI..." `n
    choco install chocolateygui -y

    # Utility Apps
    Write-Output "Installing Utility Apps..." `n
    choco install aida64-extreme -y
    choco install scrcpy -y
    choco install hcloud -y
    choco install evga-precision-x1 -y
    choco install amd-ryzen-chipset -y

    # Upgrade Choco Packages
    Write-Output "Updating Chocolatey Packages..." `n
    choco upgrade all -y
}

Function Install-Office {
    $path = "C:\Program Files\OfficeDeploymentTool\setup.exe"
    Copy-Item ".\app-files\odt\m365.xml" -Destination "C:\Program Files\OfficeDeploymentTool\m365.xml"
    Start-Process -FilePath $path -ArgumentList "/download m365.xml" -Wait
    Start-Process -FilePath $path -ArgumentList "/configure m365.xml" -Wait
}

Function Install-MyAppsWinget {
    # Install Autoupdating Apps with WinGet
    Write-Output "Installing desktop apps..." `n

    # Install Utility Apps
    # -i : interative install for setting options
    winget install 'odt'
    winget install 'Microsoft Edge'
    winget install 'PowerToys'
    winget install '7zip'
    winget install 'TreeSize Free'
    winget install 'PuTTY'
    winget install 'Link Shell Extension'
    winget install 'WinSCP'
    winget install 'CPU-Z'
    winget install 'zerotier'
    winget install 'CrystalDiskInfo'
    winget install 'CrystalDiskMark'
    winget install 'Powershell' -i
    winget install 'Windows Terminal'
    winget install 'Google Chrome'
    winget install 'NordVPN'
    winget install 'Dropbox'
    winget install 'Rufus'
    winget install 'Slack'
    winget install 'Streamdeck'
    winget install 'Wavelink' -i
    winget install 'Gyazo'
    winget install 'Nordpass'
    winget install 'AMD Ryzen Master'

    # Install Gaming Apps
    winget install 'Nvidia GeForce Experience'
    winget install 'Steam'
    winget install 'Ubisoft Connect'

    # Install Comms Apps
    winget install 'Teamspeak Client'
    winget install 'Discord'

    # Install Dev Apps
    winget install 'Visual Studio Code (System Installer - x64)' -i
    winget install 'Visual Studio Community'
    winget install 'Git' -i
    winget install 'gpg4win'
    winget install 'GitHub Desktop'
    winget install 'Python' -i
    winget install 'AzureDataStudio'
    winget install 'Amazon.AWSCLI'
    winget install 'Docker Desktop'

    # Install Media Apps
    winget install 'Plex For Windows'
    winget install 'OBS Studio'
    winget install 'Audacity'
    winget install 'VLC'
    winget install 'Adobe.AdobeAcrobatReaderDC'
}