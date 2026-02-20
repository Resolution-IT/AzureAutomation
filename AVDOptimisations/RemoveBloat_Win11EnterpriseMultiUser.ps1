# ---------------------------------------------------------------------------
# 1. NETWORK & DELIVERY
# ---------------------------------------------------------------------------
Write-Host "Optimizing Network Stack..." -ForegroundColor Yellow
try {
    # Check if BBR2 is available (Windows 11 22H2+)
    $null = netsh int tcp set supplemental template=internet congestionprovider=bbr2 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "      > BBR v2 enabled" -ForegroundColor Gray
    } else {
        Write-Host "      > BBR v2 not available on this build, skipping" -ForegroundColor DarkYellow
    }
    
    netsh int tcp set global ECNcapability=enabled 2>&1 | Out-Null
    
    $DOPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
    if (!(Test-Path $DOPath)) { New-Item -Path $DOPath -Force | Out-Null }
    New-ItemProperty -Path $DOPath -Name "DODownloadMode" -Value 99 -PropertyType DWord -Force | Out-Null
    
    Write-Host " [OK] Network Stack Optimized." -ForegroundColor Green
} catch {
    Write-Warning "      Network tuning failed: $($_.Exception.Message)"
}

# ---------------------------------------------------------------------------
# 2. SYSTEM STABILITY
# ---------------------------------------------------------------------------
Write-Host "Hardening System Stability..." -ForegroundColor Yellow
try {
    $ControlPath = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control"
    New-ItemProperty -Path $ControlPath -Name "ServicesPipeTimeout" -Value 60000 -PropertyType DWord -Force | Out-Null

    $TsPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
    if (!(Test-Path $TsPath)) { New-Item -Path $TsPath -Force | Out-Null }
    New-ItemProperty -Path $TsPath -Name "fEnableTimeZoneRedirection" -Value 1 -PropertyType DWord -Force | Out-Null

    # WSearch (Windows Search Indexer) - reduces disk I/O on multi-session hosts
    # SysMain (Superfetch) - not beneficial for VDI with fast storage
    $Services = @("Fax", "RetailDemo", "DiagTrack", "MapsBroker", "WSearch", "SysMain")
    foreach ($Svc in $Services) {
        $SvcObj = Get-Service -Name $Svc -ErrorAction SilentlyContinue
        if ($SvcObj) { 
            Set-Service -Name $Svc -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "      > Disabled: $Svc" -ForegroundColor Gray
        }
    }
    Write-Host " [OK] Stability Policies Enforced." -ForegroundColor Green
} catch {
    Write-Warning "      Stability hardening partial failure: $($_.Exception.Message)"
}

# ---------------------------------------------------------------------------
# 3. STORAGE & DISK I/O
# ---------------------------------------------------------------------------
Write-Host "Tuning Storage & Disk I/O..." -ForegroundColor Yellow
try {
    # Reserved Storage (reclaim ~7GB)
    $null = DISM.exe /Online /Set-ReservedStorageState /State:Disabled 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "      > Reserved Storage disabled" -ForegroundColor Gray
    } elseif ($LASTEXITCODE -eq 1168) {
        Write-Host "      > Reserved Storage already disabled" -ForegroundColor Gray
    } else {
        Write-Host "      > Reserved Storage change skipped (Code: $LASTEXITCODE)" -ForegroundColor DarkYellow
    }
    
    # Disable Last Access Timestamp (reduces disk writes)
    $null = fsutil behavior set disablelastaccess 1 2>&1
    Write-Host "      > Last Access Timestamp disabled" -ForegroundColor Gray
    
    # Disable 8.3 Filename Creation (NTFS performance)
    $null = fsutil behavior set disable8dot3 1 2>&1
    Write-Host "      > 8.3 Filename creation disabled" -ForegroundColor Gray
    
    Write-Host " [OK] Storage & Disk I/O Optimized." -ForegroundColor Green
} catch {
    Write-Warning "      Storage tuning partial failure: $($_.Exception.Message)"
}

# ---------------------------------------------------------------------------
# 4. TELEMETRY & SCHEDULED TASKS
# ---------------------------------------------------------------------------
Write-Host "Reducing Telemetry & Disabling Consumer Tasks..." -ForegroundColor Yellow
try {
    # --- TELEMETRY SETTINGS ---
    $TelemetryPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    if (!(Test-Path $TelemetryPath)) { New-Item -Path $TelemetryPath -Force | Out-Null }
    
    # Set Telemetry to Security/Required (0 = Security [Enterprise only], 1 = Required)
    New-ItemProperty -Path $TelemetryPath -Name "AllowTelemetry" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $TelemetryPath -Name "LimitDiagnosticLogCollection" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-Host "      > Telemetry set to Required (minimal)" -ForegroundColor Gray
    
    # Disable Feedback Frequency
    $FeedbackPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    New-ItemProperty -Path $FeedbackPath -Name "DoNotShowFeedbackNotifications" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-Host "      > Feedback notifications disabled" -ForegroundColor Gray
    
    # Disable Advertising ID
    $AdvIdPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo"
    if (!(Test-Path $AdvIdPath)) { New-Item -Path $AdvIdPath -Force | Out-Null }
    New-ItemProperty -Path $AdvIdPath -Name "DisabledByGroupPolicy" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-Host "      > Advertising ID disabled" -ForegroundColor Gray
    
    # Disable Activity History (Timeline/Cross-device sync)
    $ActivityPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System"
    if (!(Test-Path $ActivityPath)) { New-Item -Path $ActivityPath -Force | Out-Null }
    New-ItemProperty -Path $ActivityPath -Name "PublishUserActivities" -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $ActivityPath -Name "UploadUserActivities" -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $ActivityPath -Name "EnableActivityFeed" -Value 0 -PropertyType DWord -Force | Out-Null
    Write-Host "      > Activity History disabled" -ForegroundColor Gray
    
    # Disable Location Services (Policy level)
    $LocationPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors"
    if (!(Test-Path $LocationPath)) { New-Item -Path $LocationPath -Force | Out-Null }
    New-ItemProperty -Path $LocationPath -Name "DisableLocation" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $LocationPath -Name "DisableLocationScripting" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-Host "      > Location Services disabled" -ForegroundColor Gray
    
    # --- SCHEDULED TASKS CLEANUP ---
    $TasksToDisable = @(
        # CEIP & Telemetry
        "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
        "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
        "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
        "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
        "\Microsoft\Windows\Autochk\Proxy",
        "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
        "\Microsoft\Windows\Feedback\Siuf\DmClient",
        "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload",
        # Maps
        "\Microsoft\Windows\Maps\MapsUpdateTask",
        "\Microsoft\Windows\Maps\MapsToastTask",
        # Cloud Experience & Consumer Features (2026 additions)
        "\Microsoft\Windows\CloudExperienceHost\CreateObjectTask",
        "\Microsoft\Windows\Device Information\Device",
        "\Microsoft\Windows\Device Information\Device User",
        "\Microsoft\Windows\Shell\FamilySafetyMonitor",
        "\Microsoft\Windows\Shell\FamilySafetyRefreshTask",
        "\Microsoft\Windows\Windows Error Reporting\QueueReporting"
    )
    
    $DisabledCount = 0
    foreach ($Task in $TasksToDisable) {
        try {
            $null = Disable-ScheduledTask -TaskName $Task -ErrorAction Stop
            $DisabledCount++
        } catch {
            # Task may not exist on all editions
        }
    }
    Write-Host "      > Disabled $DisabledCount consumer scheduled tasks" -ForegroundColor Gray
    
    # --- WINDOWS SEARCH OPTIMIZATION ---
    $SearchPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    if (!(Test-Path $SearchPath)) { New-Item -Path $SearchPath -Force | Out-Null }
    
    # Disable Cortana
    New-ItemProperty -Path $SearchPath -Name "AllowCortana" -Value 0 -PropertyType DWord -Force | Out-Null
    # Disable Web Search
    New-ItemProperty -Path $SearchPath -Name "DisableWebSearch" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $SearchPath -Name "ConnectedSearchUseWeb" -Value 0 -PropertyType DWord -Force | Out-Null
    Write-Host "      > Windows Search: Cortana & Web Search disabled" -ForegroundColor Gray
    
    # --- BACKGROUND APPS POLICY (Global Disable) ---
    # Prevents UWP apps from running in background (Skype, Photos, YourPhone, etc.)
    $BackgroundAppsPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy"
    if (!(Test-Path $BackgroundAppsPath)) { New-Item -Path $BackgroundAppsPath -Force | Out-Null }
    
    # 2 = Force Deny background apps for all users
    New-ItemProperty -Path $BackgroundAppsPath -Name "LetAppsRunInBackground" -Value 2 -PropertyType DWord -Force | Out-Null
    Write-Host "      > Background Apps: Globally disabled (Policy)" -ForegroundColor Gray
    
    # Also set in Default User Profile for new user profiles
    Enable-Privilege -Privilege SeBackupPrivilege | Out-Null
    Enable-Privilege -Privilege SeRestorePrivilege | Out-Null
    
    $HivePath = "C:\Users\Default\NTUSER.DAT"
    $null = reg load "HKU\DefaultUserHive" $HivePath 2>&1
    
    if (Test-Path "Registry::HKEY_USERS\DefaultUserHive") {
        $DefBackgroundPath = "Registry::HKEY_USERS\DefaultUserHive\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
        if (!(Test-Path $DefBackgroundPath)) { New-Item -Path $DefBackgroundPath -Force | Out-Null }
        New-ItemProperty -Path $DefBackgroundPath -Name "GlobalUserDisabled" -Value 1 -PropertyType DWord -Force | Out-Null
        Write-Host "      > Background Apps: Set in Default User Profile" -ForegroundColor Gray
        
        # --- START MENU EXPERIENCE HOST CLEANUP (VDOT Known Issue Fix) ---
        # Prevents "broken links" in Start Menu after optimizations or Feature Updates
        $StartMenuFixPath = "Registry::HKEY_USERS\DefaultUserHive\Software\Microsoft\Windows\CurrentVersion\StartMenuExperienceHost"
        if (!(Test-Path $StartMenuFixPath)) { New-Item -Path $StartMenuFixPath -Force | Out-Null }
        New-ItemProperty -Path $StartMenuFixPath -Name "ConfiguredStartMenu" -Value 1 -PropertyType DWord -Force | Out-Null
        Write-Host "      > Start Menu Experience Host: Cleanup flag set" -ForegroundColor Gray
        
        # Unload with retry
        [gc]::Collect()
        Start-Sleep -Milliseconds 500
        $UnloadAttempts = 0
        do {
            $UnloadAttempts++
            $null = reg unload "HKU\DefaultUserHive" 2>&1
            if ($LASTEXITCODE -ne 0) { Start-Sleep -Milliseconds 300 }
        } while ($LASTEXITCODE -ne 0 -and $UnloadAttempts -lt 5)
    }
    
    Write-Host " [OK] Telemetry Reduced & Consumer Tasks Disabled." -ForegroundColor Green
} catch {
    Write-Warning "      Telemetry/Tasks optimization partial failure: $($_.Exception.Message)"
}


# ---------------------------------------------------------------------------
# 5. FINAL PERFORMANCE COMPILATION
# ---------------------------------------------------------------------------
Write-Host "Running NGEN & Cleanup..." -ForegroundColor Yellow

# Ultimate Performance Power Plan (Robust approach)
try {
    # Check if Ultimate Performance already exists
    $ExistingPlans = powercfg /list 2>&1
    $UltimateGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
    
    if ($ExistingPlans -match $UltimateGuid) {
        # Plan exists, just activate it
        powercfg -setactive $UltimateGuid 2>$null
        Write-Host "      > Ultimate Performance plan activated" -ForegroundColor Gray
    } else {
        # Duplicate the scheme
        $Dup = powercfg -duplicatescheme $UltimateGuid 2>&1
        if ($Dup -match "([a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12})") { 
            powercfg -setactive $matches[0] 2>$null
            Write-Host "      > Ultimate Performance plan created & activated" -ForegroundColor Gray
        } else {
            # Fallback to High Performance
            powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
            Write-Host "      > Fallback: High Performance plan activated" -ForegroundColor DarkYellow
        }
    }
} catch { 
    powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
    Write-Host "      > Fallback: High Performance plan activated" -ForegroundColor DarkYellow
}

# NGEN: Legacy .NET Framework 4.x only (x64) - .NET 6/7/8 uses ReadyToRun (R2R)
# Note: NGEN is optional for Windows 11 24H2+ as most apps use modern .NET
$NgenPath = "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\ngen.exe"
if (Test-Path $NgenPath) {
    Write-Host "      > NGEN: Compiling .NET Framework 4.x assemblies (x64)..." -ForegroundColor Gray
    try {
        # Use executeQueuedItems instead of update /force - faster and non-interactive
        $NgenProc = Start-Process $NgenPath -ArgumentList "executeQueuedItems" -WindowStyle Hidden -PassThru -ErrorAction Stop
        # 60 second timeout - NGEN should not block Golden Image creation
        $WaitResult = $NgenProc.WaitForExit(60000)
        if (-not $WaitResult) {
            $NgenProc.Kill()
            Write-Host "      > NGEN: Timeout after 60s (killed) - this is OK" -ForegroundColor DarkYellow
        } else {
            Write-Host "      > NGEN: Completed" -ForegroundColor Gray
        }
    } catch {
        Write-Host "      > NGEN: Skipped (not critical for .NET 6/7/8 apps)" -ForegroundColor DarkYellow
    }
} else {
    Write-Host "      > NGEN: Not found (OK - modern .NET uses R2R)" -ForegroundColor Gray
}

Write-Host "      > Compacting Component Store..." -ForegroundColor Gray
# Note: /ResetBase removed - it can take 15-30 min and is only needed for final image seal
# Run manually with: dism /online /Cleanup-Image /StartComponentCleanup /ResetBase /Quiet
$null = dism.exe /online /Cleanup-Image /StartComponentCleanup /Quiet /NoRestart 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "      > Component Store compacted successfully" -ForegroundColor Gray
} elseif ($LASTEXITCODE -eq 2 -or $LASTEXITCODE -eq 3010) {
    Write-Host "      > Component Store: Cleanup completed (may need reboot)" -ForegroundColor Gray
} else {
    Write-Host "      > Component cleanup completed with code: $LASTEXITCODE" -ForegroundColor DarkYellow
}

Write-Host "`n============================================================" -ForegroundColor Green
Write-Host "   SUCCESS: GOLDEN IMAGE OPTIMIZATION COMPLETE" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Stop-Transcript | Out-Null
