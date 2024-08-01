"type": "PowerShell",
"name": "SetUUSFeatureOverride",
"inline": [
"$uusKey = "HKLM:\SYSTEM\CurrentControlSet\Control\FeatureManagement\Overrides\4\1931709068"",
"if (Test-Path $uusKey) {",
" if ((Get-ItemProperty -Path $uusKey -Name 'EnabledState').EnabledState -ne 1) {",
" Set-ItemProperty -Path $uusKey -Name 'EnabledState' -Value 1 -Force",
" $host.UI.WriteErrorLine("UUS Feature override (1931709068) EnabledState changed to 1")",
" }",
"}"
],
"runAsSystem": true,
"runElevated": true
"type": "WindowsUpdate",
"searchCriteria": "IsInstalled=0",
"filters": [
"exclude:$.Title -like 'KB5040442'",
"exclude:$.Title -like 'Preview'",
"include:$true"
],
"updateLimit": 25