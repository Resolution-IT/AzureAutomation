$OneDrivePath = "$env:USERPROFILE\OneDrive - Icecap Limited\PlainSail Files"

# Ensure the OneDrive folder exists
if (!(Test-Path $OneDrivePath)) {
    New-Item -ItemType Directory -Path $OneDrivePath -Force
}

# Set Downloads folder to OneDrive
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
Set-ItemProperty -Path $RegPath -Name "{374DE290-123F-4565-9164-39C4925E467B}" -Value $OneDrivePath

Write-Host "Downloads folder set to: $OneDrivePath"

# Active Setup Configuration
$AppName = "SetDownloadsToOneDrive"
$ScriptPath = "C:\Resolution\Scripts\OneDriveDownloads.ps1"
$RegPath = "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\$AppName"

# Ensure the registry key exists
if (!(Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}

# Use REG ADD to set values, ensuring compatibility
cmd.exe /c "REG ADD `"$RegPath`" /ve /t REG_SZ /d `"Setting Downloads Folder to OneDrive`" /f"
cmd.exe /c "REG ADD `"$RegPath`" /v StubPath /t REG_SZ /d `"`"powershell.exe`" -ExecutionPolicy Bypass -File `"$ScriptPath`"`" /f"
cmd.exe /c "REG ADD `"$RegPath`" /v Version /t REG_SZ /d `"$Version`" /f"

Write-Host "Active Setup for $AppName configured successfully."
