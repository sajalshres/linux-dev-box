<#
.SYNOPSIS
    Setup Linux Dev Box
.DESCRIPTION
    This script install the requirements of the linux-dev-box.
.PARAMETER ImagePath
    Path of the vhd file to mount.
.NOTES
    Version:        1.0
    Author:         Sajal N. Shrestha
    Creation Date:  2/24/2020
    Purpose/Change: Initial Version

.EXAMPLE
    .\setup.ps1
#>
Param (
	[Parameter(Mandatory = $False)]
	[alias("i")]
	[switch]$Install
)

$Script:ValidateOnly = $True
$LogFileName = "setup-linux-dev-box.log"
$Script:CurrentLocation = (Get-Item -Path ".\").FullName
$Script:LogLocation = $Script:CurrentLocation
$Script:LogFile = $Script:LogLocation + "\" + $LogFileName
$Script:InstallLocation = $Script:CurrentLocation

if ($InstallMode) { $Script:ValidateOnly = $False }

$Script:Requirements = @{
    vagrant    = @{
        Name = 'Vagrant'
        Version = '2.2.7'
        InstallType = 'msi'
        URL         = 'https://releases.hashicorp.com/vagrant/2.2.7/vagrant_2.2.7_x86_64.msi'
        InstallArgs = "/qn /norestart"
    }
    virutalbox = @{
        Name = 'Oracle VM VirtualBox'
        Version = '6.0.16'
        InstallType = 'exe'
        URL         = 'https://download.virtualbox.org/virtualbox/6.0.16/VirtualBox-6.0.16-135674-Win.exe'
        InstallArgs = (
            '-s -l -msiparams REBOOT=ReallySuppress ' +
            'ALLUSERS=2 ' +
            'VBOX_INSTALLDESKTOPSHORTCUT=0 ' +
            'VBOX_INSTALLQUICKLAUNCHSHORTCUT=0 ' +
            'VBOX_REGISTERFILEEXTENSIONS=0 '
        )
    }
}

###############################################################################
# Utility Functions
###############################################################################
# Write Log
function Write-Log {
    Param(
        [Parameter(Mandatory = $true)]
        [String]$Message
    )
    $timestamp = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
    Write-Output "$timestamp $Message"
    Write-Output "$timestamp $Message" | Out-file $Script:LogFile -append
}

# Returns a list of installed application or a given application
function Get-InstalledApp() {
    Param(
        [Parameter(Mandatory = $false)]
        [String]$AppName
    )

    $Apps = @()
    $PATH_32 = 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    $PATH_64 = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    if (Get-Item Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node -ErrorAction SilentlyContinue) {
        $Apps += Get-ItemProperty $PATH_64 |
        Where-Object DisplayName -ne $null |
        Where-Object DisplayName -ne ""
    }
    $Apps += Get-ItemProperty $PATH_32 |
    Where-Object DisplayName -ne $null |
    Where-Object DisplayName -ne ""
    if ($PSBoundParameters.ContainsKey('AppName')) {
        $AppName = $AppName.Split(" ")[0]

        $App = $Apps | Where-Object DisplayName -match $AppName | Select-Object -First 1
        if ($null -ne $App) {
            return $App
        }
        return $false
    }
    return $Apps
}

# Installs the requirement of the linux development box.
function Install-Requirements() {
    foreach($Requirement in $Script:Requirements.Keys) {
        foreach($App in $Script:Requirements[$Requirement]) {
            $InstallApp = Get-InstalledApp -AppName $App.Name
            if ($InstallApp -eq $false) {
                if (-not $Script:ValidateOnly) {
                    if ($App.URL -like 'https://*' -or $App.URL -like 'http://*') {
                        Import-Module BitsTransfer
                        $InstallerFileName = $App.URL.Substring($App.URL.LastIndexOf("/") + 1)
				        $TempInstallerPath = $Script:CurrentLocation + "\" + $installerFileName
                        Start-BitsTransfer -Source $App.URL -Destination $Script:CurrentLocation -ErrorVariable Err
                        if (-not (Test-Path $tempInstallerPath))
                        {
                            Write-Log -Message "Failed to download file $InstallerFileName"
                            return
                        }
                        $Installer = $TempInstallerPath
                        $InstallArgs = $App.InstallArgs
                        if($App.InstallType -eq 'msi') {
                            $Installer = "msiexec.exe"
                            $InstallArgs = "/i $(TempInstallerPath) $($App.InstallArgs)"
                        }
                        Write-Log -Message "Starting Installation: $Installer, Argument: $InstallArgs"
                        Start-Process -FilePath $Installer -ArgumentList $InstallArgs -Wait
                        if(Get-InstalledApp -AppName $App.Name) {
                            Write-Log -Message "Install $App.Name $App.Version -> SUCCESS"
                        }
                        else {
                            Write-Log -Message "Install $App.Name $App.Version -> FAILED"
                        }
                    }
                }
                else {
                    Write-Log -Message "Application $($App.Name) to be installed."
                }
            }
            else {
                Write-Log -Message "Application $($App.Name) is already installed."
            }
        }
    }
}

###############################################################################
# Start Configuration
###############################################################################
Install-Requirements
