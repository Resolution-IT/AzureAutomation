<#
.DESCRIPTION
PowerShell to install new Teams on Multi-user Azure virtual desktop session hosts, including pre-reqs.

.NOTES
Version: 1.0
Author: Oliver Le Prevost
Creation Date: 24/09/2024
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

# Stage 8: Check for MSTeams folder and navigate to the latest version

# Define the base path
$basePath = "C:\Program Files\WindowsApps"

try {
    # Get all directories that start with "MSTeams" and end with "8wekyb3d8bbwe"
    $directories = Get-ChildItem -Path $basePath -Directory | Where-Object {
        $_.Name -like "MSTeams*_8wekyb3d8bbwe"
    }

    # Check if any directories were found
    if ($directories.Count -eq 0) {
        Write-Output "No directories matching the criteria were found."
        throw "Directory not found."
    } else {
        Write-Output "Found matching MSTeams directories."
    }

    # Sort directories by version number (extract version part from name)
    $sortedDirectories = $directories | Sort-Object {
        $version = $_.Name -replace '^MSTeams_|_x64__8wekyb3d8bbwe$',''
        [Version]$version
    } -Descending

    # Get the latest version directory
    $latestDirectory = $sortedDirectories[0]

    # Output the latest directory and navigate to it
    Write-Output "Navigating to the latest version: $($latestDirectory.FullName)"
    Set-Location $latestDirectory.FullName
    Write-Output "Successfully navigated to $($latestDirectory.FullName)"
} catch {
    Write-Output "An error occurred: $_"
}

# Stage 9: Install Teams Outlook Add-in

# Define the path to the installer and the log file
$addinInstallerPath = "C:\Path\To\MicrosoftTeamsMeetingAddinInstaller.msi"  # Adjust the path accordingly
$logFilePath = "C:\temp\NewTeams-OutlookPlugin-Install.log"

# Check if the installer file exists before attempting installation
if (-not (Test-Path $addinInstallerPath)) {
    Write-Output "The installer file was not found at $addinInstallerPath. Please check the path."
} else {
    try {
        Write-Output "Starting installation of the Teams Outlook Add-in..."
        
        # Run the msiexec command to install the add-in silently with logging
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$addinInstallerPath`" ALLUSERS=1 /qn /l*v `"$logFilePath`"" -Wait -NoNewWindow
        
        Write-Output "Teams Outlook Add-in installation completed successfully."
    } catch {
        Write-Output "An error occurred during the installation of the Teams Outlook Add-in: $_"
    }
}
