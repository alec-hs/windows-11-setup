Function Get-LatestFileFromGitHubRepo {
    param(
        [Parameter(Mandatory)]
        [string]$repo,
    
        [Parameter(Mandatory)]
        [string]$extension
    )
    
    $releases_url = "https://api.github.com/repos/$repo/releases"
    $releases = Invoke-RestMethod -uri "$($releases_url)"
    $file = $releases | Where-Object {$_.prerelease -ne "false" -and $_.assets.browser_download_url -match ".*$extension$"} | Sort-Object -Property assets.updated_at | Select-Object @{N='link';E={$_.assets.browser_download_url}} -First 1 
    return $file.link | Where-Object {$_ -match ".*$extension$"}
}

Function Install-Beacn {
    Write-Output "Installing BEACN software..." `n
    $url = "https://beacn-app-public-download.s3.us-west-1.amazonaws.com/BEACN+Setup+V1.0.238.0.exe"
    $path = ".\app-files\BEACN+Setup+V1.0.238.0.exe"
    Start-BitsTransfer $url $path
    Start-Process -FilePath $path -Wait
}

Function Install-LGTVCompanion {
    Write-Output "Installing LG TV Companion..." `n
    $url = Get-LatestFileFromGitHubRepo -repo "JPersson77/LGTVCompanion" -extension ".msi"
    $path = ".\app-files\lgtv.msi"
    Start-BitsTransfer $url $path
    Start-Process -FilePath $path -Wait
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
    Get-AppxPackage *MicrosoftTeams* | Remove-AppxPackage # Remove Teams Consumer
    Get-AppxPackage *PowerAutomateDesktop* | Remove-AppxPackage # Remove Power Automate Desktop
    Get-AppxPackage *WindowsSoundRecorder* | Remove-AppxPackage # Remove Sound Recorder
}

Function Install-Choco {
    # Setup Chocolatey Package Manager
    Write-Output "Installing Chocolatey Package Manager..." `n
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}