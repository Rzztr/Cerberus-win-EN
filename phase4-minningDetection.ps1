echo "phase 4 started... collecting crypto wallet indicators..."

sleep 5

$walletPaths = @(
    "$env:APPDATA\Exodus\exodus.wallet",
    "$env:APPDATA\Electrum\wallets",
    "$env:APPDATA\Atomic\Local Storage\file__0.localstorage",
    "$env:APPDATA\com.liberty.jaxx\IndexedDB",
    "$env:LOCALAPPDATA\Coinbase\Coinbase",
    "$env:LOCALAPPDATA\MetaMask\chrome-extension",
    "$env:APPDATA\Binance",
    "$env:USERPROFILE\.multibit",
    "$env:APPDATA\Armory",
    "$env:APPDATA\Bitcoin\wallets",
    "$env:APPDATA\Ethereum\keystore"
)

$foundWallets = @()
foreach ($path in $walletPaths) {
    if (Test-Path $path) {
        $foundWallets += $path
    }
}

if ($foundWallets.Count -gt 0) {
    $foundWallets | Out-File "$out\crypto_wallets_found.txt"
    Write-Host "[!] Crypto wallets detected — high-value target for infostealers" -ForegroundColor Yellow
}

echo "Phase 4 ended... phase 5 starting..."