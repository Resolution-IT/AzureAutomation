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
$ScriptContent | Set-Content -Path $ScriptCreationPath -Force
Write-Host "Script file created: $ScriptCreationPath"

# Active Setup Configuration
$AppName = "SetDateFormat"
$RegPathActiveSetup = "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\$AppName"

# Ensure the Active Setup key exists
if (!(Test-Path $RegPathActiveSetup)) {
    New-Item -Path $RegPathActiveSetup -Force | Out-Null
}

# Set Active Setup registry values using REG ADD
cmd.exe /c "REG ADD `"$RegPathActiveSetup`" /v `(Default`) /t REG_SZ /d `"Sets the UK date format`" /f"
cmd.exe /c "REG ADD `"$RegPathActiveSetup`" /v StubPath /t REG_SZ /d `"powershell.exe -ExecutionPolicy Bypass -File $ScriptCreationPath`" /f"
cmd.exe /c "REG ADD `"$RegPathActiveSetup`" /v Version /t REG_SZ /d `"1`" /f"
cmd.exe /c "REG ADD `"$RegPathActiveSetup`" /v IsInstalled /t REG_DWORD /d 1 /f"

Write-Host "Active Setup for $AppName configured successfully."
