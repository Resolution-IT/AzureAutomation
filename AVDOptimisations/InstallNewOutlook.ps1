<#﻿
.DESCRIPTION
PowerShell to install new Outlook on Multi-user Azure virtual desktop session hosts

.NOTES
Version: 1.1
Author: Oliver Le Prevost
Creation Date: 22/04/2024
#>

# Stage 1: Create directory
$directoryPath = "C:\Resolution\NewOutlookInstall"

# Check if the directory already exists
if (-not (Test-Path $directoryPath)) {
    Write-Output "Directory does not exist. Creating directory..."
    New-Item -Path $directoryPath -ItemType Directory
    Write-Output "Directory created successfully at $directoryPath."
} else {
    Write-Output "Directory already exists at $directoryPath."
}

# Stage 2: Download New Outlook executable
$downloadUrl = "https://go.microsoft.com/fwlink/?linkid=2207851"
$downloadPath = "C:\Resolution\NewOutlookInstall"

# Use Invoke-WebRequest to download the file
try {
    Write-Output "Starting download of New Outlook executable..."
    $response = Invoke-WebRequest -Uri $downloadUrl -Method Get -OutFile "$downloadPath\setup.exe"
    Write-Output "Download completed and saved to $downloadPath\setup.exe"
} catch {
    Write-Output "An error occurred during download: $_"
}

# Stage 3: Silently install the executable

# Define the path to the new installer
$installerPath = "C:\Resolution\NewOutlookInstall\Setup.exe"

# Check if the installer file exists
if (Test-Path $installerPath) {
    try {
        Write-Output "Starting silent installation of the application..."
        
        # Change to the directory where the installer is located
        Set-Location -Path "C:\Resolution\NewOutlookInstall"

        # Start the installation with the new parameters
        Start-Process '.\Setup.exe' -ArgumentList "--provision true --quiet --start-*" -Wait -NoNewWindow
        Write-Output "Installation completed successfully."
    } catch {
        Write-Output "An error occurred during installation: $_"
    }
} else {
    Write-Output "Installer file not found at $installerPath"
}

