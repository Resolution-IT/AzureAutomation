<#
.DESCRIPTION
PowerShell to install Classic Teams on Multi-user Azure virtual desktop session hosts to be run after new teams, NO pre-reqs.

.NOTES
Version: 1.0
Author: Oliver Le Prevost
Creation Date: 18/05/2024
#>

# Stage 1: Set registry value
# Define the path and value name
$registryPath = "HKLM:\SOFTWARE\Microsoft\Teams"
$valueName = "IsWVDEnvironment"
$desiredValue = 1

# Check if the path exists
if (-not (Test-Path $registryPath)) {
    Write-Output "Registry path does not exist. Creating path..."
    New-Item -Path $registryPath -Force
}

# Check if the value exists and has the correct data
$currentValue = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue

if ($currentValue -and $currentValue.$valueName -eq $desiredValue) {
    Write-Output "The registry value $valueName is already set to $desiredValue."
} else {
    Write-Output "Setting the registry value $valueName to $desiredValue..."
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $desiredValue -Type DWord
    Write-Output "Registry value updated successfully."
}

# Stage 2: Create directory
$directoryPath = "C:\Resolution\TeamsClassicInstall"

# Check if the directory already exists
if (-not (Test-Path $directoryPath)) {
    Write-Output "Directory does not exist. Creating directory..."
    New-Item -Path $directoryPath -ItemType Directory
    Write-Output "Directory created successfully at $directoryPath."
} else {
    Write-Output "Directory already exists at $directoryPath."
}

# Stage 5: Download Teams Classic
$teamsClassicUrl = "https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true"
$teamsClassicPath = "$directoryPath\Teams_windows_x64.msi"

try {
    Write-Output "Starting download of Classic Teams.exe..."
    Invoke-WebRequest -Uri $teamsClassicUrl -OutFile $teamsClassicPath
    Write-Output "Teams Classic downloaded successfully to $teamsClassicPath."
} catch {
    Write-Output "An error occurred during the download of Teams Classic: $_"
}


# Stage 7: Install Teams Classic 

try {
    Write-Output "Starting installation of Microsoft Teams Classic..."
    Start-Process 'msiexec.exe' -ArgumentList "/i `"$teamsClassicPath`" OPTIONS='noAutoStart=true' ALLUSERS=1 ALLUSER=1" -Wait -NoNewWindow
    Write-Output "Microsoft Teams Classic installation completed successfully."
} catch {
    Write-Output "An error occurred during the installation of Microsoft Teams Classic: $_"
}
