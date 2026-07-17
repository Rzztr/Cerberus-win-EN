$VerbosePreference = "Continue"
mkdir C:\Cerberus_collection
Write-Verbose "Created collection directory C:\Cerberus_collection"

$out = "C:\Cerberus_collection"

echo "Directory for logs created..."

echo "Collecting process dump"
cmd /c "tasklist /v" | Out-File "$out\processes.txt"
Get-Process | Select-Object -Property Id, ProcessName, Path, StartTime, CPU | Out-File "$out\processes_detailed.txt"

echo "collecting conections info..."
cmd /c "netstat -anob" | Out-File "$out\netstat.txt" 
cmd /c "netstat -ano | findstr ESTABLISHED" | Out-File "$out\netstat_established.txt"

echo "collecting network info..."
cmd /c "ipconfig /displaydns" | Out-File "$out\dns_cache.txt"

cmd /c "arp -a" | Out-File "$out\arp_table.txt"

Get-NetTCPConnection | Where-Object State -eq "Listen" | Select-Object LocalPort, OwningProcess, @{n="ProcessName";e={(Get-Process -Id $_.OwningProcess).ProcessName}} | Out-File "$out\listening_ports.txt"

sleep 5
echo "Phase 1 ended... starting phase 2..."