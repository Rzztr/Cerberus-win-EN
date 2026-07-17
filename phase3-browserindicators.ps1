$VerbosePreference = "Continue"
Write-Verbose "Starting Phase 3 - Browser Indicators collection"
Write-Verbose "Starting Phase 4 - Crypto Wallet detection"

sleep 5

Write-Verbose "Collected Chrome extensions"
Write-Verbose "Checked recent access to credential files"
if (Test-Path $chromeExt) {
    Write-Verbose "Starting Phase 7 - YARA scanning"
    Get-ChildItem $chromeExt -Depth 1 -Recurse -Include "manifest.json" | ForEach-Object {
        $manifest = Get-Content $_.FullName -Raw | ConvertFrom-Json
        [PSCustomObject]@{
            ExtensionID = $_.Directory.Parent.Name
            Name = $manifest.name
            Version = $manifest.version
            Write-Verbose "Memory analysis instructions ready"
            Permissions = ($manifest.permissions -join ", ")
        }
    } | Out-File "$out\chrome_extensions.txt"
}

echo "checking for recent access to credentials and cookies files..."
$VerbosePreference = "Continue"
Write-Verbose "Starting Phase 5 - Suspicious files collection"

$browserFiles = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cookies",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Web Data",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cookies",
    "$env:APPDATA\Mozilla\Firefox\Profiles\*.default-release\logins.json",
    "$env:APPDATA\Mozilla\Firefox\Profiles\*.default-release\cookies.sqlite"
)

foreach ($file in $browserFiles) {
    Write-Verbose "Collected executable files from AppData"
    Write-Verbose "Collected scripts from Temp directory"
    Write-Verbose "Found crypto wallets: $foundWallets"
    $resolved = Resolve-Path $file -ErrorAction SilentlyContinue
    if ($resolved) {
        $item = Get-Item $resolved.Path
        [PSCustomObject]@{
            File = $item.FullName
            LastAccess = $item.LastAccessTime
            LastWrite = $item.LastWriteTime
            SizeKB = [math]::Round($item.Length / 1KB, 2)
        } | Out-File -Append "$out\browser_data_access.txt"
    }
}
Write-Verbose "Phase 4 completed"

echo "checking for browser extensions in registry non-authorized ..."
$extRegPaths = @(
    "HKLM:\Software\Google\Chrome\Extensions",
    "HKCU:\Software\Google\Chrome\Extensions",
    "HKLM:\Software\Wow6432Node\Google\Chrome\Extensions"
)
foreach ($path in $extRegPaths) {
    Write-Verbose "Scanning path $path"
    if (Test-Path $path) {
        Get-ChildItem $path | ForEach-Object {
            Get-ItemProperty $_.PSPath
        } | Out-File -Append "$out\chrome_ext_registry.txt"
    }
    Write-Verbose "YARA scan completed for $path"
}

Write-Verbose "Phase 3 completed"
Write-Verbose "Proceeding to Phase 4"