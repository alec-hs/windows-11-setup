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

Function Install-WSL2 {
    wsl --install -d Debian
}

Function Install-MyAppsWinget {
    # Install Autoupdating Apps with WinGet
    Write-Output "Installing desktop apps..." `n

    $wingetApps = Import-CSV ./app-files/winget-apps.csv

    foreach ($app in $wingetApps) {
        switch ($app.Scope) {
            'd' {$scope = ''}
            'm' {$scope = '--scope "machine"'}
            'u' {$scope = '--scope "user"'}
        }

        switch ($app.Interactive) {
            'n' {$interactive = ''}
            'y' {$interactive = '-i'}
        }

        switch ($app.Source) {
            's' {$source = '-s msstore'}
            'w' {$source = '-s winget'}
        }

        $appName = $app.App
        Invoke-Expression "winget install `"$appName`" $scope $interactive $source --accept-package-agreements --accept-source-agreements"
    }
}

Function Remove-WindowsBloatApps {
    Get-AppxPackage *ZuneMusic* | Remove-AppxPackage # Groove Music
    Get-AppxPackage *WindowsMaps* | Remove-AppxPackage # Maps
    Get-AppxPackage *WindowsSoundRecorder* | Remove-AppxPackage # Voice Recorder
    Get-AppxPackage *MicrosoftSolitaireCollection* | Remove-AppxPackage # Solitaire Collection
    Get-AppxPackage *BingWeather* | Remove-AppxPackage # Weather
    Get-AppxPackage *BingNews* | Remove-AppxPackage # MS News
    Get-AppxPackage *Getstarted* | Remove-AppxPackage # Get Started
    Get-AppxPackage *ZuneVideo* | Remove-AppxPackage # Films & TV
    Get-AppxPackage *windowscommunicationsapps* | Remove-AppxPackage # Mail and Calender
    Get-AppxPackage *MicrosoftStickyNotes* | Remove-AppxPackage # Sticky Notes
    Get-AppxPackage *GetHelp* | Remove-AppxPackage # Get Help
    Get-AppxPackage *WindowsFeedbackHub* | Remove-AppxPackage # Feedback Hub
}