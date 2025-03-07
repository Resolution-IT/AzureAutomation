# Define registry path for OneDrive RemoteApp configuration
$OneDriveRegPath = "HKLM:\Software\Microsoft\OneDrive"

# Ensure the registry key exists
if (!(Test-Path $OneDriveRegPath)) {
    New-Item -Path $OneDriveRegPath -Force | Out-Null
}

# Set OneDrive to recognize RemoteApp mode
Set-ItemProperty -Path $OneDriveRegPath -Name "IsRemoteApp" -Value 1 -Type DWord

# Enable Enhanced Shell Experience for RemoteApp
$RdpRegPath = "HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services"
if (!(Test-Path $RdpRegPath)) {
    New-Item -Path $RdpRegPath -Force | Out-Null
}
Set-ItemProperty -Path $RdpRegPath -Name "fEnableRemoteAppEnhancedShell" -Value 1 -Type DWord

# Set OneDrive to auto-launch in background
$OneDrivePath = "C:\Program Files (x86)\Microsoft OneDrive\OneDrive.exe"
$RegPathAutoStart = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
Set-ItemProperty -Path $RegPathAutoStart -Name "OneDrive" -Value "`"$OneDrivePath`" /background" -Type String

Write-Host "OneDrive configured for RemoteApp in AVD with Enhanced Shell Experience enabled."
