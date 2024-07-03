<#
.DESCRIPTION
PowerShell to install onedrive for all users on Windows 11 multi session hosts.

.NOTES
Version: 1.0
Author: Oliver Le Prevost
Creation Date: 04/06/2024
#>

# Declare Log Function
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Write-Host $logMessage
}

# Stage 1: Create directory
$directoryPath = "C:\Resolution\OneDrive"
# Check if the directory already exists
if (-not (Test-Path $directoryPath)) {
    Write-Output "Directory does not exist. Creating directory..."
    New-Item -Path $directoryPath -ItemType Directory
    Write-Output "Directory created successfully at $directoryPath."
} else {
    Write-Output "Directory already exists at $directoryPath."
}

# Stage 2: Download OneDrive

# Define paths and other variables
$downloadUrl = "https://go.microsoft.com/fwlink/p/?LinkID=2182910&clcid=0x809&culture=en-gb&country=gb"
$exePath = "$directoryPath\OneDriveSetup.exe"

#Attempt to download

try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $exePath -ErrorAction Stop
    Log-Message "Downloaded file from $downloadUrl to $zipFilePath"
} catch {
    Log-Message "Error downloading file from $downloadUrl $_"
    exit 1
}

# Attempt to install

cd directoryPath

try {
    .\OneDriveSetup.exe /allusers
    Log-Message "Downloaded file from $downloadUrl to $zipFilePath"
} catch {
    Log-Message "Error downloading file from $downloadUrl $_"
    exit 1
}
