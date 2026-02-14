Function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet('Info', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Output $logMessage
}

Function Get-LatestFileFromGitHubRepo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$repo,
    
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$extension
    )
    
    try {
        Write-Log "Fetching latest release from GitHub repository: $repo"
        $releases_url = "https://api.github.com/repos/$repo/releases"
        $releases = Invoke-RestMethod -Uri $releases_url -ErrorAction Stop
        
        $file = $releases | Where-Object {
            $_.prerelease -eq $false -and
            $_.assets.browser_download_url -match ".*$extension$"
        } | Sort-Object -Property assets.updated_at | 
        Select-Object @{N='link';E={$_.assets.browser_download_url}} -First 1 
        
        if (-not $file) {
            throw "No matching files found with extension: $extension"
        }
        
        return $file.link | Where-Object {$_ -match ".*$extension$"}
    }
    catch {
        Write-Log "Failed to fetch latest file from GitHub: $_" -Level Error
        throw
    }
}

Function Install-Beacn {
    [CmdletBinding()]
    param()
    
    try {
        Write-Log "Starting BEACN software installation"
        $url = "https://beacn-app-public-download.s3.us-west-1.amazonaws.com/BEACN+Setup+V1.2.62.0.exe"
        $path = Join-Path $PSScriptRoot "app-files\BEACN+Setup+V1.2.62.0.exe"
        
        # Ensure directory exists
        $directory = Split-Path -Parent $path
        if (-not (Test-Path $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }
        
        Write-Log "Downloading BEACN installer"
        Start-BitsTransfer -Source $url -Destination $path -ErrorAction Stop
        
        Write-Log "Running BEACN installer"
        $process = Start-Process -FilePath $path -Wait -PassThru -ErrorAction Stop
        
        if ($process.ExitCode -ne 0) {
            throw "Installation failed with exit code: $($process.ExitCode)"
        }
        
        Write-Log "BEACN software installation completed successfully"
    }
    catch {
        Write-Log "Failed to install BEACN software: $_" -Level Error
        throw
    }
}

Function Install-LGTVCompanion {
    [CmdletBinding()]
    param()

    try {
        Write-Log "Starting LG TV Companion installation"
        $url = Get-LatestFileFromGitHubRepo -repo "JPersson77/LGTVCompanion" -extension ".msi"

        if (-not $url) {
            throw "Failed to get download URL from GitHub"
        }

        $path = Join-Path $PSScriptRoot "app-files\lgtv.msi"

        Write-Log "Downloading LG TV Companion from: $url"
        Start-BitsTransfer -Source $url -Destination $path -ErrorAction Stop

        if (-not (Test-Path $path)) {
            throw "Download failed - file not found at: $path"
        }

        Write-Log "Running LG TV Companion installer"
        $process = Start-Process -FilePath $path -Wait -PassThru -ErrorAction Stop

        if ($process.ExitCode -ne 0) {
            throw "Installation failed with exit code: $($process.ExitCode)"
        }

        Write-Log "LG TV Companion installation completed successfully"
    }
    catch {
        Write-Log "Failed to install LG TV Companion: $_" -Level Error
        throw
    }
}

Function Install-Office {
    $path = "C:\Program Files\OfficeDeploymentTool\setup.exe"
    Copy-Item ".\app-files\odt\m365.xml" -Destination "C:\Program Files\OfficeDeploymentTool\m365.xml"
    Start-Process -FilePath $path -ArgumentList "/download m365.xml" -Wait
    Start-Process -FilePath $path -ArgumentList "/configure m365.xml" -Wait
}

Function Install-VCRedist {
    Write-Output "Installing Visual C++ Redistributable 2015-2022 (latest v14)..." `n
    # Permalink for latest supported v14 (covers VS 2017, 2019, 2022) - see https://aka.ms/vcredist
    $url = "https://aka.ms/vc14/vc_redist.x64.exe"
    $path = ".\app-files\vc_redist.x64.exe"
    Start-BitsTransfer $url $path
    Start-Process -FilePath $path -Wait
}

Function Install-WSL2 {
    [CmdletBinding()]
    param()
    wsl --install -d Debian --no-launch
}

Function Install-MyAppsWinget {
    [CmdletBinding()]
    param()
    
    try {
        Write-Log "Starting WinGet app installations"
        $wingetAppsPath = Join-Path $PSScriptRoot "app-files/winget-apps.csv"
        
        if (-not (Test-Path $wingetAppsPath)) {
            throw "WinGet apps CSV file not found at: $wingetAppsPath"
        }
        
        $wingetApps = Import-CSV $wingetAppsPath -ErrorAction Stop
        
        foreach ($app in $wingetApps) {
            Write-Log "Installing app: $($app.App)"
            
            $scope = switch ($app.Scope) {
                'd' { @() }
                'm' { @('--scope', 'machine') }
                'u' { @('--scope', 'user') }
                default { throw "Invalid scope value: $($app.Scope)" }
            }

            $interactive = switch ($app.Interactive) {
                'n' { @() }
                'y' { @('-i') }
                default { throw "Invalid interactive value: $($app.Interactive)" }
            }

            $source = switch ($app.Source) {
                's' { @('-s', 'msstore') }
                'w' { @('-s', 'winget') }
                default { throw "Invalid source value: $($app.Source)" }
            }
            
            $appName = $app.App

            # Build argument list as array for proper argument passing
            $argList = @("install", $appName)
            if ($scope.Count -gt 0) { $argList += $scope }
            if ($interactive.Count -gt 0) { $argList += $interactive }
            if ($source.Count -gt 0) { $argList += $source }
            $argList += "--accept-package-agreements"
            $argList += "--accept-source-agreements"

            Write-Log "Executing: winget $($argList -join ' ')"
            $process = Start-Process -FilePath "winget" -ArgumentList $argList -Wait -PassThru -ErrorAction Stop
            
            if ($process.ExitCode -ne 0) {
                Write-Log "Failed to install $appName" -Level Warning
            }
            else {
                Write-Log "Successfully installed $appName"
            }
        }
    }
    catch {
        Write-Log "Failed during WinGet app installation: $_" -Level Error
        throw
    }
}

Function Remove-WindowsBloatApps {
    [CmdletBinding()]
    param()
    
    try {
        Write-Log "Starting removal of Windows bloatware apps"
        
        $appsToRemove = @(
            @{Name = "*ZuneMusic*"; Description = "Groove Music"},
            @{Name = "*WindowsMaps*"; Description = "Maps"},
            @{Name = "*WindowsSoundRecorder*"; Description = "Voice Recorder"},
            @{Name = "*MicrosoftSolitaireCollection*"; Description = "Solitaire Collection"},
            @{Name = "*BingWeather*"; Description = "Weather"},
            @{Name = "*BingNews*"; Description = "MS News"},
            @{Name = "*Getstarted*"; Description = "Get Started"},
            @{Name = "*ZuneVideo*"; Description = "Films & TV"},
            @{Name = "*windowscommunicationsapps*"; Description = "Mail and Calendar"},
            @{Name = "*MicrosoftStickyNotes*"; Description = "Sticky Notes"},
            @{Name = "*GetHelp*"; Description = "Get Help"},
            @{Name = "*WindowsFeedbackHub*"; Description = "Feedback Hub"},
            @{Name = "*MicrosoftTeams*"; Description = "Teams Consumer"},
            @{Name = "*PowerAutomateDesktop*"; Description = "Power Automate Desktop"},
            @{Name = "*Microsoft.BingFinance*"; Description = "Bing Finance"}
        )
        
        foreach ($app in $appsToRemove) {
            Write-Log "Removing $($app.Description)"
            $packages = Get-AppxPackage $app.Name
            if ($packages) {
                $packages | Remove-AppxPackage -ErrorAction Stop
                Write-Log "Successfully removed $($app.Description)"
            }
            else {
                Write-Log "No packages found for $($app.Description)" -Level Warning
            }
        }
        
        Write-Log "Completed removal of Windows bloatware apps"
    }
    catch {
        Write-Log "Failed during bloatware removal: $_" -Level Error
        throw
    }
}