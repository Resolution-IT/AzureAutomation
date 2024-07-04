<#
.DESCRIPTION
PowerShell to install multi-media redirection on Multi-user Azure virtual desktop session hosts

.NOTES
Version: 1.0
Author: Oliver Le Prevost
Creation Date: 15/04/2024
#>

# Stage 1: Create directory
$directoryPath = "C:\Resolution\MultiMediaRedirection"

# Check if the directory already exists
if (-not (Test-Path $directoryPath)) {
    Write-Output "Directory does not exist. Creating directory..."
    New-Item -Path $directoryPath -ItemType Directory
    Write-Output "Directory created successfully at $directoryPath."
} else {
    Write-Output "Directory already exists at $directoryPath."
}

# Stage 3: Download the latest version of the Visual C++ (VC_Redist)
$downloadUrl = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$downloadPath = "C:\Resolution\MultiMediaRedirection"

# Use Invoke-WebRequest to download the file
try {
    Write-Output "Starting download of VC redist..."
    $response = Invoke-WebRequest -Uri $downloadUrl -Method Get -OutFile "$downloadPath\VC_redist.x64.exe"
    Write-Output "Download completed and saved to $downloadPath\VC_redist.x64.exe"
} catch {
    Write-Output "An error occurred during download: $_"
}

# Stage 4: Silently install VCRedist
$installerPath = "$downloadPath\VC_redist.x64.exe"

# Check if the installer file exists
if (Test-Path $installerPath) {

try {
# Start the installation process silently
Write-Output "Starting install of vc_redist"
Start-Process -FilePath $installerPath -ArgumentList "/quiet", "/norestart" -Wait

    } catch {
        Write-Output "An error occurred during installation of vc_redist: $_"
    }
} else {
    Write-Output "Installer file not found for vc_redist at $installerPath"
}

# Stage 5: Download MultiMedia Redirection MSI
$mmrUrl = "https://aka.ms/avdmmr/msi"
$mmrPath = "$downloadPath\MsMMRHostInstaller.msi"

try {
    Write-Output "Starting download of MultiMedia Redirection MSI..."
    Invoke-WebRequest -Uri $mmrUrl -OutFile $mmrPath
    Write-Output "MultiMedia Redirection MSI downloaded successfully to $mmrPath."
} catch {
    Write-Output "An error occurred during the download of MultiMedia Redirection MSI...: $_"
}

# Stage 6: Install MultiMedia Redirection MSI

$installerPath = "$downloadPath\MsMMRHostInstaller.msi"

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
