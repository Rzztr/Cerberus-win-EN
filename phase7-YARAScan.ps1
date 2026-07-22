. "$PSScriptRoot\globals.ps1"

if ($IsWindows) {
    # Install YARA if needed (requires chocolatey or manual)
    choco install yara -y

    # Directory to scan — start with Temp, AppData, and Downloads
    $scanPaths = @(
        "$env:TEMP",
        "$env:LOCALAPPDATA\Temp",
        "$env:APPDATA",
        "$env:USERPROFILE\Downloads",
        "$env:USERPROFILE\Desktop"
    )

    # Create a focused infostealer YARA rule file
    @"
    rule Infostealer_RedLine_Indicators {
        meta:
            description = "RedLine Stealer indicators"
            author = "HackerAI"
        strings:
            $c2 = "http" ascii wide nocase
            $sqlite = "sqlite3_step" ascii
            $browser = "Chrome" ascii wide nocase
            $steal_func = "GetPasswords" ascii wide nocase
            $crypto = "BTC" ascii wide nocase
        condition:
            any of ($sqlite, $browser) and any of ($steal_func, $crypto)
    }

    rule Infostealer_Telegram_Exfil {
        meta:
            description = "Detects Telegram-based data exfiltration patterns"
            author = "HackerAI"
        strings:
            $telegram = "api.telegram.org" ascii wide nocase
            $bot = "bot" ascii nocase
            $send = "sendDocument" ascii nocase
            $chat = "chat_id" ascii nocase
        condition:
            all of them
    }

    rule Infostealer_Browser_Stealer {
        meta:
            description = "Common browser credential theft patterns"
            author = "HackerAI"
        strings:
            $login = "Login Data" ascii wide nocase
            $cookie = "Cookies" ascii wide nocase
            $webdata = "Web Data" ascii wide nocase
            $stealer_class = "Stealer" ascii wide nocase
        condition:
            any of ($login, $cookie, $webdata) and $stealer_class
    }

    rule Infostealer_Process_Hollowing {
        meta:
            description = "Indicators of process hollowing techniques"
            author = "HackerAI"
        strings:
            $ntUnmap = "NtUnmapViewOfSection" ascii
            $ntWrite = "NtWriteProcessMemory" ascii
            $resume = "NtResumeThread" ascii
            $ntCreate = "NtCreateProcessEx" ascii
        condition:
            any of ($ntUnmap, $ntWrite, $resume, $ntCreate)
    }
"@ | Out-File -Encoding ascii "$out\infostealer.yar"

    # Run YARA scan
    foreach ($path in $scanPaths) {
        if (Test-Path $path) {
            $logFile = "$out\yara_scan_$(($path -replace '\\', '_') -replace ':', '').txt"
            cmd /c "yara64.exe -w -r `"$out\infostealer.yar`" `"$path`" 2>nul" | Out-File $logFile
        }
    }

    echo "scanning completed, deleting YARA"
    sleep 1
    choco uninstall yara -y
    echo "Phase 7 ended... phase 8 starting..."
}
else {
    Write-Verbose "Skipping YARA scan on non-Windows OS"
}