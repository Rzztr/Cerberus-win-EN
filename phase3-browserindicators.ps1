echo "Phase 3 started... collecting browser indicators..."

sleep 5

$chromeExt = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Extensions"
if (Test-Path $chromeExt) {
    Get-ChildItem $chromeExt -Depth 1 -Recurse -Include "manifest.json" | ForEach-Object {
        $manifest = Get-Content $_.FullName -Raw | ConvertFrom-Json
        [PSCustomObject]@{
            ExtensionID = $_.Directory.Parent.Name
            Name = $manifest.name
            Version = $manifest.version
            Permissions = ($manifest.permissions -join ", ")
        }
    } | Out-File "$out\chrome_extensions.txt"
}

echo "checking for recent access to credentials and cookies files..."

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

echo "checking for browser extensions in registry non-authorized ..."
$extRegPaths = @(
    "HKLM:\Software\Google\Chrome\Extensions",
    "HKCU:\Software\Google\Chrome\Extensions",
    "HKLM:\Software\Wow6432Node\Google\Chrome\Extensions"
)
foreach ($path in $extRegPaths) {
    if (Test-Path $path) {
        Get-ChildItem $path | ForEach-Object {
            Get-ItemProperty $_.PSPath
        } | Out-File -Append "$out\chrome_ext_registry.txt"
    }
}

echo "Phase 3 ended... phase 4 incoming..."