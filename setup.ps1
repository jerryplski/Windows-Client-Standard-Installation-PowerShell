<#
.SYNOPSIS
    Windows Client Provisioning Script

.DESCRIPTION
    Automates the setup of Windows clients including updates,
    software installation, network configuration and system preparation.

.NOTES
    Author: Jeremy
#>

param(
    [string[]]$Packages = @(
        "7zip",
        "firefox",
        "adoptopenjdk",
        "adobereader",
        "irfanview",
        "irfanviewplugins"
    ),
    [switch]$SkipUpdates,
    [switch]$SkipSoftware,
    [switch]$SkipRestorePoints
)

# ==================== Initial Setup ====================
$LogPath = "C:\Temp\client-setup.log"
New-Item -ItemType Directory -Path "C:\Temp" -Force | Out-Null
Start-Transcript -Path $LogPath -Append

Write-Host "Starting Client Provisioning..." -ForegroundColor Cyan

# ==================== Elevation ====================
function Ensure-Admin {
    if (-not ([Security.Principal.WindowsPrincipal] 
        [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

        Write-Host "Restarting as Administrator..." -ForegroundColor Yellow

        Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit
    }
}

# ==================== Restore Point ====================
function Create-RestorePoint {
    param([string]$Description)

    if ($SkipRestorePoints) { return }

    Write-Host "Creating restore point: $Description" -ForegroundColor Yellow

    try {
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        vssadmin Resize ShadowStorage /For=C: /On=C: /MaxSize=10% | Out-Null
        Checkpoint-Computer -Description $Description -ErrorAction SilentlyContinue
    } catch {
        Write-Host "Restore point failed: $_" -ForegroundColor Red
    }
}

# ==================== Network ====================
function Configure-Network {
    Write-Host "Configuring network..." -ForegroundColor Yellow

    try {
        Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
        Set-NetFirewallRule -DisplayGroup "Netzwerkerkennung" -Enabled True
    } catch {
        Write-Host "Network configuration failed: $_" -ForegroundColor Red
    }
}

# ==================== Windows Updates ====================
function Install-WindowsUpdates {
    if ($SkipUpdates) { return }

    Write-Host "Installing Windows Updates..." -ForegroundColor Yellow

    try {
        Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

        if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
            Install-Module PSWindowsUpdate -Force -Confirm:$false
        }

        Import-Module PSWindowsUpdate

        Get-WindowsUpdate -Install -AcceptAll -IgnoreReboot -Confirm:$false
    } catch {
        Write-Host "Windows Update failed: $_" -ForegroundColor Red
    }
}

# ==================== Chocolatey ====================
function Install-Chocolatey {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Chocolatey already installed" -ForegroundColor Green
        return
    }

    Write-Host "Installing Chocolatey..." -ForegroundColor Yellow

    try {
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
        Invoke-RestMethod 'https://community.chocolatey.org/install.ps1' | Invoke-Expression
    } catch {
        Write-Host "Chocolatey installation failed: $_" -ForegroundColor Red
    }
}

# ==================== Software ====================
function Install-Software {
    if ($SkipSoftware) { return }

    Write-Host "Installing software..." -ForegroundColor Yellow

    try {
        choco install $Packages -y
        choco upgrade all -y
    } catch {
        Write-Host "Software installation failed: $_" -ForegroundColor Red
    }
}

# ==================== Main ====================
try {
    Ensure-Admin

    Create-RestorePoint -Description "Before Provisioning"

    Configure-Network

    Install-WindowsUpdates

    Install-Chocolatey

    Install-Software

    Create-RestorePoint -Description "After Provisioning"

    Write-Host "Provisioning completed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "Critical error: $_" -ForegroundColor Red
}
finally {
    Stop-Transcript
}
