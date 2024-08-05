<#
.DESCRIPTION
PowerShell to install new Teams on Multi-user Azure virtual desktop session hosts, including pre-reqs.

.NOTES
Version: 1.1
Author: Oliver Le Prevost
Creation Date: 15/04/2024
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
$directoryPath = "C:\Resolution\TeamsInstall"

# Check if the directory already exists
if (-not (Test-Path $directoryPath)) {
    Write-Output "Directory does not exist. Creating directory..."
    New-Item -Path $directoryPath -ItemType Directory
    Write-Output "Directory created successfully at $directoryPath."
} else {
    Write-Output "Directory already exists at $directoryPath."
}

# Stage 3: Download the latest version of the Remote Desktop WebRTC Redirector Service
$downloadUrl = "https://aka.ms/msrdcwebrtcsvc/msi"
$downloadPath = "C:\Resolution\TeamsInstall"

# Use Invoke-WebRequest to download the file
try {
    Write-Output "Starting download of Remote Desktop WebRTC Redirector Service..."
    $response = Invoke-WebRequest -Uri $downloadUrl -Method Get -OutFile "$downloadPath\MsRdcWebRTCSvc_HostSetup_Latest_x64.msi"
    Write-Output "Download completed and saved to $downloadPath\MsRdcWebRTCSvc_HostSetup_Latest_x64.msi"
} catch {
    Write-Output "An error occurred during download: $_"
}

# Stage 4: Silently install the downloaded MSI file
$installerPath = "$downloadPath\MsRdcWebRTCSvc_HostSetup_Latest_x64.msi"

# Check if the installer file exists
if (Test-Path $installerPath) {
    try {
        Write-Output "Starting silent installation of the Remote Desktop WebRTC Redirector Service..."
        Start-Process 'msiexec.exe' -ArgumentList "/i `"$installerPath`" /quiet /norestart" -Wait -NoNewWindow
        Write-Output "Installation completed successfully."
    } catch {
        Write-Output "An error occurred during installation: $_"
    }
} else {
    Write-Output "Installer file not found at $installerPath"
}


# Stage 5: Download TeamsBootstrapper.exe
$teamsBootstrapperUrl = "https://go.microsoft.com/fwlink/?linkid=2243204&clcid=0x409"
$teamsBootstrapperPath = "$downloadPath\TeamsBootstrapper.exe"

try {
    Write-Output "Starting download of TeamsBootstrapper.exe..."
    Invoke-WebRequest -Uri $teamsBootstrapperUrl -OutFile $teamsBootstrapperPath
    Write-Output "TeamsBootstrapper.exe downloaded successfully to $teamsBootstrapperPath."
} catch {
    Write-Output "An error occurred during the download of TeamsBootstrapper.exe: $_"
}


# Stage 6: Download msteams-x64.msix
$msTeamsMsixUrl = "https://go.microsoft.com/fwlink/?linkid=2196106"
$msTeamsMsixPath = "$downloadPath\msteams-x64.msix"

try {
    Write-Output "Starting download of msteams-x64.msix..."
    Invoke-WebRequest -Uri $msTeamsMsixUrl -OutFile $msTeamsMsixPath
    Write-Output "msteams-x64.msix downloaded successfully to $msTeamsMsixPath."
} catch {
    Write-Output "An error occurred during the download of msteams-x64.msix: $_"
}


# Stage 7: Install Teams using TeamsBootstrapper.exe
$teamsBootstrapperExePath = "c:\resolution\teamsinstall\TeamsBootstrapper.exe"
$msTeamsMsixPackagePath = "c:\resolution\teamsinstall\msteams-x64.msix"

try {
    Write-Output "Starting installation of Microsoft Teams..."
    Start-Process -FilePath $teamsBootstrapperExePath -ArgumentList "-p -o `"$msTeamsMsixPackagePath`"" -Wait -NoNewWindow
    Write-Output "Microsoft Teams installation completed successfully."
} catch {
    Write-Output "An error occurred during the installation of Microsoft Teams: $_"
}
