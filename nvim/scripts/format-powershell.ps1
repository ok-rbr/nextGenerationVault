#!/usr/bin/env pwsh
#Requires -Version 5.1

<#
.SYNOPSIS
    PowerShell formatter script for Neovim conform.nvim integration
.DESCRIPTION
    This script formats PowerShell code using PowerShell Script Analyzer
    and the configured formatting rules.
.PARAMETER FilePath
    Path to the PowerShell file to format
.PARAMETER SettingsPath
    Path to the PowerShell Script Analyzer settings file
.PARAMETER LogPath
    Optional path to the log file for diagnostic output
.EXAMPLE
    .\format-powershell.ps1 -FilePath "script.ps1" -SettingsPath "settings.psd1"
.EXAMPLE
    .\format-powershell.ps1 -FilePath "script.ps1" -SettingsPath "settings.psd1" -LogPath "formatter.log"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ })]
    [string]$FilePath,

    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ })]
    [string]$SettingsPath,

    [Parameter(Mandatory = $false)]
    [string]$LogPath
)

function Write-Log {
    param([string]$Message)
    if ($LogPath) {
        $logDir = Split-Path -Path $LogPath -Parent
        if (-not (Test-Path $logDir)) {
            New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        }
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "$timestamp - $Message" | Add-Content -Path $LogPath -ErrorAction SilentlyContinue
    }
}

try {
    Write-Log "START: Formatting $FilePath"

    # Import the settings file
    $settings = Import-PowerShellDataFile -Path $SettingsPath -ErrorAction Stop
    Write-Log "Settings loaded from $SettingsPath"

    # Read the content to format
    $content = Get-Content -Path $FilePath -Raw -ErrorAction Stop
    $originalHash = ($content | Get-FileHash -Algorithm MD5).Hash
    Write-Log "Original content hash: $originalHash"

    if ($content) {
        # Format the content using PowerShell Script Analyzer
        $formatted = Invoke-Formatter -ScriptDefinition $content -Settings $settings -ErrorAction Stop
        $formattedHash = ($formatted | Get-FileHash -Algorithm MD5).Hash
        Write-Log "Formatted content hash: $formattedHash"

        $changed = $originalHash -ne $formattedHash
        Write-Log "Changed: $changed"

        # Write the formatted content back to the file
        $formatted | Set-Content -Path $FilePath -NoNewline -ErrorAction Stop

        Write-Verbose "Successfully formatted PowerShell file: $FilePath"
        Write-Log "END: Success (Changed=$changed)"
        exit 0
    } else {
        Write-Warning "File $FilePath is empty or could not be read"
        Write-Log "END: File empty or unreadable"
        exit 0
    }
} catch {
    Write-Error "PowerShell formatting failed: $($_.Exception.Message)"
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Log "END: Failed"
    exit 1
}
