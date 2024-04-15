<#
.DESCRIPTION
PowerShell to install FSLogix on Multi-user Azure virtual desktop session hosts.

.NOTES
Version: 1.1
Author: Oliver Le Prevost
Creation Date: 15/04/2024
#>


# Stage 1: Create directory
$directoryPath = "C:\Resolution\FSLogix"

# Check if the directory already exists
if (-not (Test-Path $directoryPath)) {
    Write-Output "Directory does not exist. Creating directory..."
    New-Item -Path $directoryPath -ItemType Directory
    Write-Output "Directory created successfully at $directoryPath."
} else {
    Write-Output "Directory already exists at $directoryPath."
}

# Stage 2: Download FSLogix
$downloadUrl = "https://aka.ms/fslogix_download"
$downloadPath = "C:\Resolution\FSLogix"

# Use Invoke-WebRequest to download the file
try {
    Write-Output "Starting download of FSLogix..."
    $response = Invoke-WebRequest -Uri $downloadUrl -Method Get -OutFile "$downloadPath\FSLogixApps.zip"
    Write-Output "Download completed and saved to $downloadPath"
} catch {
    Write-Output "An error occurred during download: $_"
}

#Stage 3: Unzip FSLogix
Expand-Archive `
    -LiteralPath "$downloadPath\FSLogixApps.zip" `
    -DestinationPath "$downloadPath" `
    -Force `
    -Verbose
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-Location $downloadPath 
Write-Host "UnZip of FSLogix Complete"


#Stage 4: Install FSLogix
Write-Host "Starting FSLogix Install"
$fsLogixInstallStatus = Start-Process `
    -FilePath "$downloadPath\x64\Release\FSLogixAppsSetup.exe" `
    -ArgumentList "/install /quiet /norestart" `
    -Wait `
    -Passthru

#Stage 5: Add Defender Exclusions

Write-Host "Adding exclusions for Microsoft Defender"

try {
     $filelist = `
  "%ProgramFiles%\FSLogix\Apps\frxdrv.sys", `
  "%ProgramFiles%\FSLogix\Apps\frxdrvvt.sys", `
  "%ProgramFiles%\FSLogix\Apps\frxccd.sys", `
  "%TEMP%\*.VHD", `
  "%TEMP%\*.VHDX", `
  "%Windir%\TEMP\*.VHD", `
  "%Windir%\TEMP\*.VHDX" `

    $processlist = `
    "%ProgramFiles%\FSLogix\Apps\frxccd.exe", `
    "%ProgramFiles%\FSLogix\Apps\frxccds.exe", `
    "%ProgramFiles%\FSLogix\Apps\frxsvc.exe"

    Foreach($item in $filelist){
        Add-MpPreference -ExclusionPath $item}
    Foreach($item in $processlist){
        Add-MpPreference -ExclusionProcess $item}

    Add-MpPreference -ExclusionPath "%ProgramData%\FSLogix\Cache\*.VHD"
    Add-MpPreference -ExclusionPath "%ProgramData%\FSLogix\Cache\*.VHDX"
    Add-MpPreference -ExclusionPath "%ProgramData%\FSLogix\Proxy\*.VHD"
    Add-MpPreference -ExclusionPath "%ProgramData%\FSLogix\Proxy\*.VHDX"
}
catch {
     Write-Host "Exception occurred while adding exclusions for Microsoft Defender"
     Write-Host $PSItem.Exception
}

Write-Host "Finished adding exclusions for Microsoft Defender"