<#
.DESCRIPTION
PowerShell to install Microsoft 365 Apps for Business (NoTeams) on Multi-user Azure virtual desktop session hosts.

.NOTES
Version: 1.0
Author: Oliver Le Prevost
Creation Date: 30/04/2024
#>


# Stage 1: Create directory
$directoryPath = "C:\Resolution\M365"

# Check if the directory already exists
if (-not (Test-Path $directoryPath)) {
    Write-Output "Directory does not exist. Creating directory..."
    New-Item -Path $directoryPath -ItemType Directory
    Write-Output "Directory created successfully at $directoryPath."
} else {
    Write-Output "Directory already exists at $directoryPath."
}

# Stage 2: Download ODT and Config file
$downloadUrl = "https://github.com/Resolution-IT/AzureAutomation/raw/main/AVDOptimisations/officedeploymenttool_17531-20046.exe"
$downloadPath = "C:\Resolution\M365"
$downloadUrlXml = "https://raw.githubusercontent.com/Resolution-IT/AzureAutomation/main/AVDOptimisations/M365_NoTeams.xml"

# Use Invoke-WebRequest to download the ODT exe file
try {
    Write-Output "Starting download of ODT executable..."
    $response = Invoke-WebRequest -Uri $downloadUrl -Method Get -OutFile "$downloadPath\officedeploymenttool_17531-20046.exe"
    Write-Output "Download completed and saved to $downloadPath"
} catch {
    Write-Output "An error occurred during download: $_"

}

# Use Invoke-WebRequest to download the ODT Config XML
try {
    Write-Output "Starting download of ODT Config XML..."
    $response = Invoke-WebRequest -Uri $downloadUrlXml -Method Get -OutFile "$downloadPath\M365_NoTeams.xml"
    Write-Output "Download completed and saved to $downloadPath"
} catch {
    Write-Output "An error occurred during download: $_"


}

# Stage 3: Extract ODT
try {
cd "$downloadPath"
    .\officedeploymenttool_17531-20046.exe /quiet /norestart /extract:C:\resolution\M365
    Write-Output "Extract completed to $downloadPath"
} catch {
    Write-Output "An error occurred during extraction: $_"

}

# Stage 4: Run ODT Download
try {
    .\setup.exe /download "$downloadPath\M365_NoTeams.xml"
    Write-Output "Extract completed"
} catch {
    Write-Output "An error occurred during extraction: $_"

}

# Stage 5: Run ODT Configure
try {
    .\setup.exe /configure "$downloadPath\M365_NoTeams.xml"
    Write-Output "Install completed"
} catch {
    Write-Output "An error occurred during extraction: $_"

}
