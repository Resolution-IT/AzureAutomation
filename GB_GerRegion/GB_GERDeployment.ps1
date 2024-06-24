# Script to define regional settings on Azure Virtual Machines deployed from the marketplace

# Variables
$regionalsettingsURL = "https://raw.githubusercontent.com/Resolution-IT/AzureAutomation/main/GB_GerRegion/GB_GerRegion.xml"
$RegionalSettings = "C:\GB_GerRegion.xml"

# Download regional settings file
$webclient = New-Object System.Net.WebClient
$webclient.DownloadFile($regionalsettingsURL, $RegionalSettings)

# Set Locale, language, etc.
& $env:SystemRoot\System32\control.exe "intl.cpl,,/f:`"$RegionalSettings`""

# Set languages/culture
Set-WinSystemLocale en-GB
Set-WinUserLanguageList -LanguageList en-GB, de-DE -Force
Set-Culture -CultureInfo en-GB
Set-WinHomeLocation -GeoId 242
Set-TimeZone -Name "GMT Standard Time"

# Restart virtual machine to apply regional settings to the current user.
Start-Sleep -Seconds 40
Restart-Computer

