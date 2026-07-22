. "$PSScriptRoot\globals.ps1"

echo "phase 5 started... collecting suspicious files..."

sleep 5

echo "checking for executables in AppData and Temp directories..."
Get-ChildItem "$env:APPDATA\*" -Include "*.exe","*.dll","*.scr","*.pif" -Recurse -Force -ErrorAction SilentlyContinue |
    Select-Object FullName, Length, CreationTime, LastWriteTime |
    Export-Csv "$out\appdata_executables.csv" -NoTypeInformation

Get-ChildItem "$env:TEMP\*" -Include "*.exe","*.dll","*.ps1","*.vbs","*.js","*.bat" -Recurse -Force -ErrorAction SilentlyContinue |
    Select-Object FullName, Length, CreationTime, LastWriteTime |
    Export-Csv "$out\temp_scripts.csv" -NoTypeInformation

echo "checking for hidden files in user directories..."
Get-ChildItem "$env:USERPROFILE" -Force -Filter *.exe -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Attributes -match "Hidden" } |
    Select-Object FullName, Length, CreationTime, LastWriteTime |
    Out-File "$out\hidden_executables.txt"

echo "checking for suspicious DLLs loaded into browser processes..."
if ($IsWindows) {
    $browserProcs = @("chrome","msedge","firefox","opera")
    foreach ($proc in $browserProcs) {
        $p = Get-Process -Name $proc -ErrorAction SilentlyContinue
        if ($p) {
            cmd /c "tasklist /m /fi `"IMAGENAME eq $proc.exe`"" | Out-File "$out\loaded_dlls_$proc.txt"
        }
    }
} else {
    Write-Verbose "Skipping DLL enumeration on non-Windows OS"
}

echo "Phase 5 ended... phase 6 starting..."