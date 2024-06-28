# Script to define regional settings on Azure Virtual Machines deployed from the market place

#variables
$regionalsettingsURL = "https://raw.githubusercontent.com/Resolution-IT/AzureAutomation/main/UKRegion/GBRegion.xml"
$RegionalSettings = "C:\GBRegion.xml"


#downdload regional settings file
$webclient = New-Object System.Net.WebClient
$webclient.DownloadFile($regionalsettingsURL,$RegionalSettings)


# Set Locale, language etc. 
& $env:SystemRoot\System32\control.exe "intl.cpl,,/f:`"$RegionalSettings`""

# Set languages/culture. Not needed perse.
Set-WinSystemLocale en-GB
Set-WinUserLanguageList -LanguageList en-GB -Force
Set-Culture -CultureInfo en-GB
Set-WinHomeLocation -GeoId 242
Set-TimeZone -Name "GMT Standard Time"
