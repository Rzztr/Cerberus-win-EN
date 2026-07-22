. "$PSScriptRoot\globals.ps1"

if ($IsWindows) {
    # Using Sysinternals ProcDump on suspicious processes
    # procdump -ma -n 3 -s 10 -c 50 <PID> C:\Cerberus_collectiondumps\
    # Or full memory:
    # winpmem_mini_x64_rc2.exe C:\IR_collection\memory.raw

    # Then with Volatility 3:
    # vol -f memory.raw windows.pslist > pslist.txt
    # vol -f memory.raw windows.netscan > netscan.txt
    # vol -f memory.raw windows.malfind > malfind.txt
    # vol -f memory.raw windows.cmdline --pid <suspicious_pid>
}
else {
    Write-Verbose "Skipping memory acquisition on non-Windows OS"
}