# Define log file path
$LogFile = "C:\deployment_log.txt"

# Function to write logs
function Write-Log {
    param (
        [string]$Message
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logMessage = "$timestamp - $Message"
    $logMessage | Out-File -Append -FilePath $LogFile
    Write-Host $logMessage
}

# Start logging
Write-Log "Starting script execution."

# Define script path (create the .ps1 directly in C:\)
$ScriptCreationPath = "C:\SetDateFormat.ps1"

# Ensure the folder exists (in this case, C:\ is already there)
Write-Log "Checking if C:\ exists."
if (!(Test-Path -Path "C:\")) {
    Write-Log "C:\ drive is not available. Exiting."
    Exit
}

# Define script content
$ScriptContent = @'
# Define registry paths
$RegPathCurrentUser = "HKCU\Control Panel\International"
$DefaultUserRegPath = "HKU\.DEFAULT\Control Panel\International"

# Apply to Current User
cmd.exe /c "REG ADD `"$RegPathCurrentUser`" /v sShortDate /t REG_SZ /d `"dd/MM/yyyy`" /f"
cmd.exe /c "REG ADD `"$RegPathCurrentUser`" /v sLongDate /t REG_SZ /d `"dddd, dd MMMM yyyy`" /f"
cmd.exe /c "REG ADD `"$RegPathCurrentUser`" /v sTimeFormat /t REG_SZ /d `"HH:mm:ss`" /f"
cmd.exe /c "REG ADD `"$RegPathCurrentUser`" /v LocaleName /t REG_SZ /d `"en-GB`" /f"

# Apply to Default User (for new profiles)
cmd.exe /c "REG ADD `"$DefaultUserRegPath`" /v sShortDate /t REG_SZ /d `"dd/MM/yyyy`" /f"
cmd.exe /c "REG ADD `"$DefaultUserRegPath`" /v sLongDate /t REG_SZ /d `"dddd, dd MMMM yyyy`" /f"
cmd.exe /c "REG ADD `"$DefaultUserRegPath`" /v sTimeFormat /t REG_SZ /d `"HH:mm:ss`" /f"
cmd.exe /c "REG ADD `"$DefaultUserRegPath`" /v LocaleName /t REG_SZ /d `"en-GB`" /f"

Write-Host "Date and time formats updated successfully."
'@

# Write the content to the file
Write-Log "Creating script file: $ScriptCreationPath"
$ScriptContent | Set-Content -Path $ScriptCreationPath -Force
Write-Log "Script file created: $ScriptCreationPath"

# Active Setup Configuration
$AppName = "SetDateFormat"
$RegPathActiveSetup = "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\$AppName"

# Ensure the Active Setup key exists
Write-Log "Checking if Active Setup registry path exists: $RegPathActiveSetup"
if (!(Test-Path $RegPathActiveSetup)) {
    New-Item -Path $RegPathActiveSetup -Force | Out-Null
    Write-Log "Active Setup registry path created: $RegPathActiveSetup"
} else {
    Write-Log "Active Setup registry path already exists: $RegPathActiveSetup"
}

# Set Active Setup registry values
Write-Log "Configuring Active Setup registry values for $AppName"
cmd.exe /c "REG ADD `"$RegPathActiveSetup`" /v `(Default`) /t REG_SZ /d `"Sets the UK date format`" /f"
cmd.exe /c "REG ADD `"$RegPathActiveSetup`" /v StubPath /t REG_SZ /d `"powershell.exe -ExecutionPolicy Bypass -File $ScriptCreationPath`" /f"
cmd.exe /c "REG ADD `"$RegPathActiveSetup`" /v Version /t REG_SZ /d `"1`" /f"
cmd.exe /c "REG ADD `"$RegPathActiveSetup`" /v IsInstalled /t REG_DWORD /d 1 /f"
Write-Log "Active Setup for $AppName configured successfully."

Write-Log "Script execution completed."
