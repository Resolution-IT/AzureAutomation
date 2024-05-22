# Script to define regional settings on Azure Virtual Machines deployed from the market place

#variables
$regionalsettingsURL = "https://raw.githubusercontent.com/Resolution-IT/AzureAutomation/main/USRegion/USRegion.xml"
$RegionalSettings = "C:\USRegion.xml"


#downdload regional settings file
$webclient = New-Object System.Net.WebClient
$webclient.DownloadFile($regionalsettingsURL,$RegionalSettings)


# Set Locale, language etc. 
& $env:SystemRoot\System32\control.exe "intl.cpl,,/f:`"$RegionalSettings`""

# Set languages/culture. Not needed perse.
Set-WinSystemLocale en-US
Set-WinUserLanguageList -LanguageList en-US -Force
Set-Culture -CultureInfo en-US
Set-WinHomeLocation -GeoId 244
Set-TimeZone -Name "US Eastern Standard Time"

# restart virtual machine to apply regional settings to current user. You could also do a logoff and login.
Start-sleep -Seconds 40
Restart-Computer
