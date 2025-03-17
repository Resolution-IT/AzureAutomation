# Define script path
$ScriptFolder = "C:\Resolution\Scripts"
$ScriptCreationPath = "$ScriptFolder\SetDateFormat.ps1"

# Ensure the folder exists
if (!(Test-Path -Path $ScriptFolder)) {
    New-Item -ItemType Directory -Path $ScriptFolder -Force
    Write-Host "Folder created: $ScriptFolder"
}

# Define script content
$ScriptContent = @'
# Define registry paths
$RegPathCurrentUser = "HKCU\Control Panel\International"

# Set values using REG ADD instead of Set-ItemProperty
cmd.exe /c "REG ADD `"$RegPathCurrentUser`" /v sShortDate /t REG_SZ /d `"dd/MM/yyyy`" /f"
cmd.exe /c "REG ADD `"$RegPathCurrentUser`" /v sLongDate /t REG_SZ /d `"dddd, dd MMMM yyyy`" /f"
cmd.exe /c "REG ADD `"$RegPathCurrentUser`" /v sTimeFormat /t REG_SZ /d `"HH:mm:ss`" /f"
cmd.exe /c "REG ADD `"$RegPathCurrentUser`" /v LocaleName /t REG_SZ /d `"en-GB`" /f"

Write-Host "Date format updated successfully."
'@

# Write the content to the file
$ScriptContent | Set-Content -Path $ScriptCreationPath -Force
Write-Host "Script file created: $ScriptCreationPath"

$AppName = "SetDateFormat"
$ScriptPath = "C:\Resolution\Scripts\SetDateFormat.ps1"
$RegPathActiveSetup = "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\$AppName"

# Ensure the registry key exists for Active Setup
if (-not (Test-Path $RegPathActiveSetup)) {
    New-Item -Path $RegPathActiveSetup -Force | Out-Null
}

# Set registry path for current user
$RegPathCurrentUser = "HKCU\Control Panel\International"

# Use REG ADD to set values for UK date/time formats for the current user
cmd.exe /c "REG ADD `"$RegPathCurrentUser`" /v sShortDate /t REG_SZ /d `"dd/MM/yyyy`" /f"
cmd.exe /c "REG ADD `"$RegPathCurrentUser`" /v sLongDate /t REG_SZ /d `"dddd, dd MMMM yyyy`" /f"
cmd.exe /c "REG ADD `"$RegPathCurrentUser`" /v sTimeFormat /t REG_SZ /d `"HH:mm:ss`" /f"
cmd.exe /c "REG ADD `"$RegPathCurrentUser`" /v LocaleName /t REG_SZ /d `"en-GB`" /f"

# Set registry path for default user (for new users)
$DefaultUserRegPath = "HKU\.DEFAULT\Control Panel\International"

# Use REG ADD to set values for UK date/time formats for new users
cmd.exe /c "REG ADD `"$DefaultUserRegPath`" /v sShortDate /t REG_SZ /d `"dd/MM/yyyy`" /f"
cmd.exe /c "REG ADD `"$DefaultUserRegPath`" /v sLongDate /t REG_SZ /d `"dddd, dd MMMM yyyy`" /f"
cmd.exe /c "REG ADD `"$DefaultUserRegPath`" /v sTimeFormat /t REG_SZ /d `"HH:mm:ss`" /f"
cmd.exe /c "REG ADD `"$DefaultUserRegPath`" /v LocaleName /t REG_SZ /d `"en-GB`" /f"

Write-Host "Active Setup for $AppName configured successfully."
