$VerbosePreference = "Continue"
echo "Phase 2 started... collecting info"

sleep 5

echo "collecting autorun services..."

reg export "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" "$out\HKLM_Run.reg"
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "$out\HKCU_Run.reg"
reg export "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" "$out\HKLM_RunOnce.reg"
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce" "$out\HKCU_RunOnce.reg"

$runKeys = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunServices",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunServices",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run"
)

foreach ($key in $runKeys) {
    if (Test-Path $key) {
        Get-ItemProperty $key | Select-Object * -ExcludeProperty PSPath, PSParentPath, PSChildName, PSDrive, PSProvider |
            Out-File -Append "$out\autoruns_registry.txt"
    }
}

echo "collecting scheduled services..."
cmd /c "schtasks /query /fo CSV /v" | Out-File "$out\scheduled_tasks.csv"

echo "collecting startup folder info..."
Get-ChildItem "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup" -Force -Recurse | 
    Select-Object Name, FullName, CreationTime, LastWriteTime | Out-File "$out\startup_folder.txt"
Get-ChildItem "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup" -Force -Recurse |
    Select-Object Name, FullName, CreationTime, LastWriteTime | Out-File -Append "$out\startup_folder.txt"

echo "phase 2 ended... starting phase 3..."
