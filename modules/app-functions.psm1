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
    wsl --install
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
        Invoke-Expression "winget install `"$appName`" $scope $interactive $source"
    }
}

Function Remove-WindowsBloatApps {
    Remove-AppxPackage -Package "Microsoft.ZuneMusic_10.21061.10121.0_x64__8wekyb3d8bbwe" # Groove Music
    Remove-AppxPackage -Package "Microsoft.WindowsMaps_1.0.28.0_x64__8wekyb3d8bbwe" # Maps
    Remove-AppxPackage -Package "Microsoft.WindowsSoundRecorder_1.0.42.0_x64__8wekyb3d8bbwe" # Voice Recorder
    Remove-AppxPackage -Package "Microsoft.MicrosoftSolitaireCollection_4.9.6151.0_x64__8wekyb3d8bbwe" # Solitaire Collection
    Remove-AppxPackage -Package "Microsoft.BingWeather_1.0.6.0_x64__8wekyb3d8bbwe" # Weather
    Remove-AppxPackage -Package "Microsoft.BingNews_1.0.6.0_x64__8wekyb3d8bbwe" # MS News
    Remove-AppxPackage -Package "Microsoft.Getstarted_10.4.41811.0_x64__8wekyb3d8bbwe" # Get Started
    Remove-AppxPackage -Package "Microsoft.Todos_0.49.41972.0_x64__8wekyb3d8bbwe" # Todo
    Remove-AppxPackage -Package "Microsoft.ZuneVideo_10.21061.10121.0_x64__8wekyb3d8bbwe" # Films & TV
    Remove-AppxPackage -Package "microsoft.windowscommunicationsapps_16005.14228.20204.0_x64__8wekyb3d8bbwe" # Mail and Calender
    Remove-AppxPackage -Package "Microsoft.MicrosoftStickyNotes_4.0.4.0_x64__8wekyb3d8bbwe" # Sticky Notes
    Remove-AppxPackage -Package "Microsoft.GetHelp_10.2105.41472.0_x64__8wekyb3d8bbwe" # Get Help
    Remove-AppxPackage -Package "Microsoft.WindowsFeedbackHub_1.2106.1801.0_x64__8wekyb3d8bbwe" # Feedback Hub 
    Remove-AppxPackage -Package "Microsoft.549981C3F5F10_3.2106.14307.0_x64__8wekyb3d8bbwe" # Cortana
}