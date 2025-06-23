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
            $_.prerelease -ne "false" -and 
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
        $url = "https://beacn-app-public-download.s3.us-west-1.amazonaws.com/BEACN+Setup+V1.0.238.0.exe"
        $path = Join-Path $PSScriptRoot "app-files\BEACN+Setup+V1.0.238.0.exe"
        
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

Function Install-VCRedist17 {
    Write-Output "Installing Visual C++ Redistributable 2017..." `n
    $url = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
    $path = ".\app-files\vc_redist.x64.exe"
    Start-BitsTransfer $url $path
    Start-Process -FilePath $path -Wait
}

Function Install-WSL2 {
    wsl --install -d Debian
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
                'd' { '' }
                'm' { '--scope "machine"' }
                'u' { '--scope "user"' }
                default { throw "Invalid scope value: $($app.Scope)" }
            }
            
            $interactive = switch ($app.Interactive) {
                'n' { '' }
                'y' { '-i' }
                default { throw "Invalid interactive value: $($app.Interactive)" }
            }
            
            $source = switch ($app.Source) {
                's' { '-s msstore' }
                'w' { '-s winget' }
                default { throw "Invalid source value: $($app.Source)" }
            }
            
            $appName = $app.App
            $command = "winget install `"$appName`" $scope $interactive $source --accept-package-agreements --accept-source-agreements"
            
            Write-Log "Executing command: $command"
            $process = Start-Process -FilePath "winget" -ArgumentList $command -Wait -PassThru -ErrorAction Stop
            
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