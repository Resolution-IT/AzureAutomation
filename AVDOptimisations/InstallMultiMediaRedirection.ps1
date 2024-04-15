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

# Stage 3: Download the latest version of the Remote Desktop WebRTC Redirector Service
$downloadUrl = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$downloadPath = "C:\Resolution\MultiMediaRedirection"

# Use Invoke-WebRequest to download the file
try {
    Write-Output "Starting download of Remote Desktop WebRTC Redirector Service..."
    $response = Invoke-WebRequest -Uri $downloadUrl -Method Get -OutFile "$downloadPath\VC_redist.x64.exe"
    Write-Output "Download completed and saved to $downloadPath\VC_redist.x64.exe"
} catch {
    Write-Output "An error occurred during download: $_"
}

# Stage 4: Silently install the downloaded MSI file
$installerPath = "$downloadPath\VC_redist.x64.exe"

# Check if the installer file exists
if (Test-Path $installerPath) {
# Start the installation process silently
Start-Process -FilePath $installerPath -ArgumentList "/quiet", "/norestart" -Wait

# Check the exit code to determine success/failure
$exitCode = $LASTEXITCODE
if ($exitCode -eq 0) {
Write-Host "Installation completed successfully."
} else {
Write-Host "Installation failed with exit code: $exitCode"
}
} else {
Write-Host "Installer file not found at: $installerPath"
}


# Stage 5: Download MultiMedia Redirection MSI
$mmrUrl = "https://aka.ms/avdmmr/msi"
$mmrPath = "$downloadPath\MsMMRHostInstaller.msi"

try {
    Write-Output "Starting download of MultiMedia Redirection MSI..."
    Invoke-WebRequest -Uri $mmrUrl -OutFile $mmrPath
    Write-Output "TeamsBootstrapper.exe downloaded successfully to $mmrPath."
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