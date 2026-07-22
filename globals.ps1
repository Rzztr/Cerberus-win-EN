## globals.ps1 – shared configuration for Cerberus PowerShell toolkit
# Detect operating system
$IsWindows = $env:OS -match "Windows"

# Define output directory (collection folder)
if ($IsWindows) {
    $OutputDir = "C:\\Cerberus_collection"
} else {
    $home = $env:HOME
    if (-not $home) { $home = $env:USERPROFILE }
    $OutputDir = Join-Path $home "Cerberus_collection"
}

# Ensure the directory exists
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# Export as global variables for all phases
Set-Variable -Name out -Value $OutputDir -Scope Global
Set-Variable -Name IsWindows -Value $IsWindows -Scope Global

# Define Chrome extensions path (used by phase3)
if ($IsWindows) {
    $chromeExt = "C:\\Program Files\\Google\\Chrome\\User Data\\Default\\Extensions"
} else {
    $chromeExt = "$env:HOME/.config/google-chrome/Default/Extensions"
}
Set-Variable -Name chromeExt -Value $chromeExt -Scope Global
