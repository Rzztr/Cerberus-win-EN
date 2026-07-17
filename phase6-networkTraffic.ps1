echo "phase 6 started... collecting network traffic indicators..."

echo "checking common ports..."

$suspiciousPorts = @(80, 443, 8080, 8443, 4444, 1337, 6666, 7777, 8888, 9001, 9040, 9050 9999)
$connections = Get-NetTCPConnection | Where-Object { 
    $_.State -eq "Established" -and $_.RemotePort -in $suspiciousPorts
}
$connections | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, @{n="ProcessName";e={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}} |
    Out-File "$out\suspicious_connections.txt"


echo "Check for connections to known Telegram IPs (common C2 for infostealers) "

$telegramRanges = @("149.154.160.0/20", "91.108.56.0/22", "91.108.4.0/22", "95.161.64.0/20")
Get-NetTCPConnection | Where-Object State -eq "Established" | ForEach-Object {
    $ip = $_.RemoteAddress
    foreach ($range in $telegramRanges) {
        # Quick check — convert to subnet comparison
        $ipBytes = [ipaddress]::Parse($ip).GetAddressBytes()
        $rangeParts = $range.Split('/')
        $rangeBytes = [ipaddress]::Parse($rangeParts[0]).GetAddressBytes()
        $mask = [convert]::ToInt32($rangeParts[1], 10)
        $match = $true
        for ($i = 0; $i -lt 4; $i++) {
            if (($ipBytes[$i] -band (0xFF -shl (8 - $mask) -band 0xFF)) -ne ($rangeBytes[$i] -band (0xFF -shl (8 - $mask) -band 0xFF))) {
                $match = $false
                break
            }
        }
        if ($match) {
            [PSCustomObject]@{
                RemoteAddress = $ip
                RemotePort = $_.RemotePort
                LocalProcess = (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName
                TelegramRange = $range
            } | Out-File -Append "$out\telegram_connections.txt"
        }
    }
}

echo "phase 6 ended... phase 7 starting..."