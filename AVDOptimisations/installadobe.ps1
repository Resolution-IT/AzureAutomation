# Define the URL of the Adobe installer and the download path
$adobeInstallerUrl = "https://raw.githubusercontent.com/Resolution-IT/AzureAutomation/main/AVDOptimisations/Reader_en_install.exe"
$installerPath = "C:\Resolution\Adobe\Reader_en_install.exe"

# Download the Adobe installer
Invoke-WebRequest -Uri $adobeInstallerUrl -OutFile $installerPath

# Verify if the file was downloaded successfully
if (Test-Path $installerPath) {
    Write-Host "Installer downloaded successfully to: $installerPath"
} else {
    Write-Host "Download failed. Please check the URL and try again."
}

# Run the Adobe installer silently with language and silent installation flags
Start-Process -FilePath $installerPath -ArgumentList "/sl", "1033", "/sAll" -NoNewWindow -Wait

# Verify if the installation completed successfully
if ($?) {
    Write-Host "Adobe Reader installed successfully."
} else {
    Write-Host "Installation failed. Please check the logs."
}

# Ensure Adobe is set as the default app for PDF files
$xmlContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<DefaultAssociations>
    <Association Identifier=".pdf" ProgId="AcroExch.Document.DC" ApplicationName="Adobe Acrobat Reader DC" />
</DefaultAssociations>
"@

# Save XML file
$xmlFilePath = "$InstallPath\DefaultAppAssociations.xml"
$xmlContent | Set-Content -Path $xmlFilePath -Encoding UTF8

# Apply the default file associations
dism /online /import-defaultappassociations:$xmlFilePath

# Cleanup downloaded installer
Remove-Item -Path $installerPath -Force

Write-Host "Adobe Acrobat installation and default PDF association completed."

# Define the path to the McAfee uninstall executable
$mcafeeUninstallerPath = "C:\Program Files (x86)\McAfee Security Scan\uninstall.exe"

# Check if the uninstaller exists
if (Test-Path -Path $mcafeeUninstallerPath) {
    # Run the uninstaller silently
    Start-Process -FilePath $mcafeeUninstallerPath -ArgumentList "/quiet /norestart" -NoNewWindow -Wait
    Write-Host "McAfee Security Scan Plus uninstalled successfully."
} else {
    Write-Host "McAfee Security Scan Plus uninstaller not found."
}