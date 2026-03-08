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

Function Get-RepoRootPath {
    [CmdletBinding()]
    param()

    return (Split-Path -Parent $PSScriptRoot)
}

Function Get-LatestFileFromGitHubRepo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$repo,
    
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$extension,

        [Parameter(Mandatory=$false)]
        [ValidateSet('x64', 'arm64', 'any')]
        [string]$Architecture = 'any'
    )
    
    try {
        Write-Log "Fetching latest release from GitHub repository: $repo"
        $releases_url = "https://api.github.com/repos/$repo/releases"
        $releases = Invoke-RestMethod -Uri $releases_url -ErrorAction Stop

        $stableReleases = $releases | Where-Object { $_.prerelease -eq $false } | Sort-Object -Property published_at -Descending
        if (-not $stableReleases) {
            throw "No stable releases found for repository: $repo"
        }

        $extensionRegex = [regex]::Escape($extension) + '$'

        foreach ($release in $stableReleases) {
            $assets = @($release.assets) | Where-Object {
                $_.browser_download_url -match $extensionRegex
            }

            if (-not $assets) {
                continue
            }

            if ($Architecture -ne 'any') {
                $archMatches = $assets | Where-Object {
                    $_.name -match "(?i)$Architecture" -or $_.browser_download_url -match "(?i)$Architecture"
                }
                if ($archMatches) {
                    return $archMatches[0].browser_download_url
                }

                # Architecture requested, but not present in this release: keep searching older stable releases.
                continue
            }

            return $assets[0].browser_download_url
        }

        if ($Architecture -ne 'any') {
            throw "No matching files found with extension: $extension and architecture: $Architecture"
        }

        throw "No matching files found with extension: $extension"
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
        $repoRoot = Get-RepoRootPath
        $path = Join-Path $repoRoot "app-files\BEACN+Setup+V1.2.62.0.exe"
        
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
        $repoRoot = Get-RepoRootPath
        $architecturePreference = if ($env:PROCESSOR_ARCHITECTURE -match "ARM64") { "arm64" } else { "x64" }
        $url = Get-LatestFileFromGitHubRepo -repo "JPersson77/LGTVCompanion" -extension ".msi" -Architecture $architecturePreference

        if (-not $url) {
            throw "Failed to get download URL from GitHub"
        }

        $path = Join-Path $repoRoot "app-files\lgtv.msi"
        $directory = Split-Path -Parent $path
        if (-not (Test-Path $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }

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
    $repoRoot = Get-RepoRootPath
    $path = Join-Path $repoRoot "app-files\vc_redist.x64.exe"
    $directory = Split-Path -Parent $path
    if (-not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    Start-BitsTransfer -Source $url -Destination $path -ErrorAction Stop
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
        $repoRoot = Get-RepoRootPath
        $wingetAppsPath = Join-Path $repoRoot "app-files\winget-apps.csv"
        
        if (-not (Test-Path $wingetAppsPath)) {
            throw "WinGet apps CSV file not found at: $wingetAppsPath"
        }
        
        $wingetApps = @(Import-CSV $wingetAppsPath -ErrorAction Stop)
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            throw "winget command not found in PATH"
        }

        for ($i = 0; $i -lt $wingetApps.Count; $i++) {
            $app = $wingetApps[$i]
            $rowNumber = $i + 2

            try {
                $appName = $app.App
                if ([string]::IsNullOrWhiteSpace($appName)) {
                    throw "Missing app ID in App column"
                }

                $scopeValue = "$($app.Scope)".Trim().ToLowerInvariant()
                $interactiveValue = "$($app.Interactive)".Trim().ToLowerInvariant()
                $sourceValue = "$($app.Source)".Trim().ToLowerInvariant()

                Write-Log "Installing app: $appName"

                $scope = switch ($scopeValue) {
                    'd' { @() }
                    'm' { @('--scope', 'machine') }
                    'u' { @('--scope', 'user') }
                    default { throw "Invalid scope value: $scopeValue (expected d/m/u)" }
                }

                $interactive = switch ($interactiveValue) {
                    'n' { @() }
                    'y' { @('-i') }
                    default { throw "Invalid interactive value: $interactiveValue (expected y/n)" }
                }

                $source = switch ($sourceValue) {
                    's' { @('-s', 'msstore') }
                    'w' { @('-s', 'winget') }
                    default { throw "Invalid source value: $sourceValue (expected s/w)" }
                }

                # Build argument list as array for proper argument passing
                $argList = @("install", $appName)
                if ($scope.Count -gt 0) { $argList += $scope }
                if ($interactive.Count -gt 0) { $argList += $interactive }
                if ($source.Count -gt 0) { $argList += $source }
                $argList += "--accept-package-agreements"
                $argList += "--accept-source-agreements"

                Write-Log "Executing: winget $($argList -join ' ')"
                $wingetOutput = & winget @argList 2>&1
                $exitCode = $LASTEXITCODE

                if ($exitCode -ne 0) {
                    $summary = (($wingetOutput | Select-Object -First 8) -join " | ")
                    if ([string]::IsNullOrWhiteSpace($summary)) {
                        $summary = "No output captured."
                    }
                    Write-Log "Failed to install $appName (exit code $exitCode). Output: $summary" -Level Warning
                }
                else {
                    Write-Log "Successfully installed $appName"
                }
            }
            catch {
                Write-Log "Skipping row $rowNumber for app '$($app.App)': $_" -Level Warning
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
                Write-Log "No packages found for $($app.Description)"
            }
        }
        
        Write-Log "Completed removal of Windows bloatware apps"
    }
    catch {
        Write-Log "Failed during bloatware removal: $_" -Level Error
        throw
    }
}