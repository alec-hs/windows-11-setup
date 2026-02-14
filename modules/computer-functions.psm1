function Set-NetworkTypes {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )

    begin {
        Write-Verbose "Starting network profile configuration..."
    }

    process {
        try {
            $conns = Get-NetConnectionProfile -ErrorAction Stop

            foreach ($conn in $conns) {
                if ($conn.NetworkCategory -eq "Public") {
                    $name = $conn.Name
                    if ($Force) {
                        if ($PSCmdlet.ShouldProcess($name, "Switch network profile to Private")) {
                            Set-NetConnectionProfile -Name $name -NetworkCategory Private -ErrorAction Stop
                            Write-Verbose "Successfully switched $name to Private"
                        }
                    }
                    else {
                        $confirm = Read-Host "Would you like to switch connection - $name - to Private? (y | n)"
                        if ($confirm -eq "y") {
                            if ($PSCmdlet.ShouldProcess($name, "Switch network profile to Private")) {
                                Set-NetConnectionProfile -Name $name -NetworkCategory Private -ErrorAction Stop
                                Write-Verbose "Successfully switched $name to Private"
                            }
                        }
                    }
                }
            }
        }
        catch {
            Write-Error "An error occurred while configuring network profiles: $_"
            throw
        }
    }

    end {
        Write-Verbose "Completed network profile configuration"
    }
}

function Enable-HyperV {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $false)]
        [switch]$NoRestart
    )

    begin {
        Write-Verbose "Starting Hyper-V installation..."
    }

    process {
        try {
            if ($PSCmdlet.ShouldProcess("System", "Enable Hyper-V feature")) {
                $params = @{
                    Online      = $true
                    FeatureName = "Microsoft-Hyper-V"
                    All         = $true
                }

                if ($NoRestart) {
                    $params.Add("NoRestart", $true)
                }

                Enable-WindowsOptionalFeature @params -ErrorAction Stop
                Write-Verbose "Successfully enabled Hyper-V feature"
            }
        }
        catch {
            Write-Error "An error occurred while enabling Hyper-V: $_"
            throw
        }
    }

    end {
        Write-Verbose "Completed Hyper-V installation"
    }
}

function Set-PowerPlanHighPerformance {
    [CmdletBinding()]
    param()

    process {
        try {
            Write-Verbose "Setting power plan to High performance..."

            # Well-known GUID for High Performance power plan
            $highPerfGuid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"

            # Verify the plan exists before activating
            $planList = powercfg -list
            if ($planList -match $highPerfGuid) {
                powercfg -setactive $highPerfGuid
                Write-Verbose "Power plan set to High performance"
            }
            else {
                Write-Warning "High performance power plan not found; leaving current plan active"
            }
        }
        catch {
            Write-Error "Failed to set power plan: $_"
            throw
        }
    }
}

function Enable-Hibernation {
    [CmdletBinding()]
    param()

    process {
        try {
            Write-Verbose "Enabling hibernation..."
            powercfg /h on
            Write-Verbose "Hibernation enabled"
        }
        catch {
            Write-Error "Failed to enable hibernation: $_"
            throw
        }
    }
}

# Export the functions
Export-ModuleMember -Function Set-NetworkTypes, Enable-HyperV, Set-PowerPlanHighPerformance, Enable-Hibernation