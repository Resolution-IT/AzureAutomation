# Define log file path for OneDrive script
$OneDriveLogFile = "C:\OneDriveDownloads_log.txt"

# Function to write logs for OneDrive script
function Write-LogOneDrive {
    param (
        [string]$Message
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logMessage = "$timestamp - $Message"
    $logMessage | Out-File -Append -FilePath $OneDriveLogFile
    Write-Host $logMessage
}

# Start logging for OneDrive script
Write-LogOneDrive "Starting OneDrive script execution."

# Define OneDrive path
$OneDrivePath = "$env:USERPROFILE\OneDrive - Icecap Limited\PlainSail Files"

# Ensure the OneDrive folder exists
Write-LogOneDrive "Checking if OneDrive folder exists: $OneDrivePath"
if (!(Test-Path $OneDrivePath)) {
    New-Item -ItemType Directory -Path $OneDrivePath -Force
    Write-LogOneDrive "OneDrive folder created: $OneDrivePath"
} else {
    Write-LogOneDrive "OneDrive folder already exists: $OneDrivePath"
}

# Set Downloads folder to OneDrive
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
Write-LogOneDrive "Setting Downloads folder to OneDrive"
Set-ItemProperty -Path $RegPath -Name "{374DE290-123F-4565-9164-39C4925E467B}" -Value $OneDrivePath
Write-LogOneDrive "Downloads folder set to: $OneDrivePath"

# Active Setup Configuration for OneDrive
$AppName = "SetDownloadsToOneDrive"
$ScriptCreationPath = "C:\OneDriveDownloads.ps1"
$RegPathActiveSetup = "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\$AppName"

# Ensure the script content
$ScriptContent = @'
# Define OneDrive path
$OneDrivePath = "$env:USERPROFILE\OneDrive - Icecap Limited\PlainSail Files"

# Ensure the OneDrive folder exists
if (!(Test-Path $OneDrivePath)) {
    New-Item -ItemType Directory -Path $OneDrivePath -Force
}

# Set Downloads folder to OneDrive
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
Set-ItemProperty -Path $RegPath -Name "{374DE290-123F-4565-9164-39C4925E467B}" -Value $OneDrivePath

Write-Host "Downloads folder set to: $OneDrivePath"
'@

# Write the content to the file
Write-LogOneDrive "Creating script file: $ScriptCreationPath"
$ScriptContent | Set-Content -Path $ScriptCreationPath -Force
Write-LogOneDrive "Script file created: $ScriptCreationPath"

# Ensure the Active Setup registry key exists
Write-LogOneDrive "Checking if Active Setup registry path exists: $RegPathActiveSetup"
if (!(Test-Path $RegPathActiveSetup)) {
    New-Item -Path $RegPathActiveSetup -Force | Out-Null
    Write-LogOneDrive "Active Setup registry path created: $RegPathActiveSetup"
} else {
    Write-LogOneDrive "Active Setup registry path already exists: $RegPathActiveSetup"
}

# Set Active Setup registry values
Write-LogOneDrive "Configuring Active Setup registry values for $AppName"
cmd.exe /c "REG ADD `"$RegPathActiveSetup`" /ve /t REG_SZ /d `"Setting Downloads Folder to OneDrive`" /f"
cmd.exe /c "REG ADD `"$RegPathActiveSetup`" /v StubPath /t REG_SZ /d `"powershell.exe -ExecutionPolicy Bypass -File `"$ScriptCreationPath`"`" /f"
cmd.exe /c "REG ADD `"$RegPathActiveSetup`" /v Version /t REG_SZ /d `"1`" /f"
Write-LogOneDrive "Active Setup for $AppName configured successfully."

Write-LogOneDrive "OneDrive script execution completed."
