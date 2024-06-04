<#
.DESCRIPTION
PowerShell to check for and remove bloat from Windows 11 multi session hosts.

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
$directoryPath = "C:\Resolution\BloatRemoval"

# Stage 2: Download SaRa, extract and run

# Define paths and other variables
$directoryPath = "C:\Resolution\OfficeDeploymentTool"
$zipFilePath = "$directoryPath\SaRACmd.zip"
$downloadUrl = "https://aka.ms/SaRA_EnterpriseVersionFiles"
$exePath = "$directoryPath\SaRACmd.exe"

# Ensure the directory exists
if (-Not (Test-Path -Path $directoryPath)) {
    try {
        New-Item -ItemType Directory -Path $directoryPath -Force
        Log-Message "Created directory: $directoryPath"
    } catch {
        Log-Message "Error creating directory $directoryPath $_"
        exit 1
    }
} else {
    Log-Message "Directory already exists: $directoryPath"
}

# Download the SaRA Command-Line Tool zip file
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFilePath -ErrorAction Stop
    Log-Message "Downloaded file from $downloadUrl to $zipFilePath"
} catch {
    Log-Message "Error downloading file from $downloadUrl $_"
    exit 1
}

# Unzip the SaRA Command-Line Tool
try {
    Expand-Archive -Path $zipFilePath -DestinationPath $directoryPath -Force
    Log-Message "Extracted $zipFilePath to $directoryPath"
} catch {
    Log-Message "Error extracting $zipFilePath $_"
    exit 1
}

# Change directory to the specified path
try {
    Set-Location -Path $directoryPath
    Log-Message "Changed directory to $directoryPath"
} catch {
    Log-Message "Error changing directory to $directoryPath $_"
    exit 1
}

# Run the SaRA Command-Line Tool with specified parameters
try {
    & $exePath -S OfficeScrubScenario -AcceptEula -OfficeVersion M365
    Log-Message "Executed SaRACmd.exe with parameters successfully."
} catch {
    Log-Message "Error executing SaRACmd.exe: $_"
    exit 1
}

Log-Message "Process completed successfully."


#Stage 3: Attempt to remove OneDrive
# Attempt to uninstall OneDrive using winget

try {
    winget uninstall OneDriveSetup.exe --accept-source-agreements --accept-package-agreements -ErrorAction Stop
    Log-Message "Successfully uninstalled OneDrive."
} catch {
    Log-Message "Error uninstalling OneDrive: $_"
}
