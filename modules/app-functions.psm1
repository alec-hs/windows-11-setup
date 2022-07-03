Function Install-Choco {
    # Setup Chocolatey Package Manager
    Write-Output "Installing Chocolatey Package Manager..." `n
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
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