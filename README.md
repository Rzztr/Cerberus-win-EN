# Cerberus Forensic Analysis Suite

## Overview

Cerberus is a **PowerShell‑based forensic analysis framework** designed to automate the collection of system artefacts on Windows machines.  It bundles a set of focused scripts (phases) that capture a wide range of evidence – from running processes and network connections to YARA scans and memory dumps.  The main entry point (`main.ps1`) orchestrates the execution flow, allowing you to run the full investigation with a single command or target individual phases for more granular analysis.

---

## Prerequisites

- Windows 10/11 (or any Windows version with PowerShell 5.1+).  The scripts rely on native Windows utilities (`tasklist`, `netstat`, `ipconfig`, etc.) and PowerShell cmdlets.
- **Administrative privileges** are recommended to ensure full access to system information and to allow YARA scanning.

- **PowerShell execution policy** must permit script execution.  You can set it temporarily with:
  ```powershell
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
  ```
- (Optional) **YARA** installed and added to the system `PATH` if you intend to run the `YARAScan` phase.

---

## Installation

1. Clone or copy the repository to a directory of your choice, e.g. `C:\Cerberus`.
2. Open PowerShell as **Administrator** and navigate to the directory:
   ```powershell
   cd C:\Cerberus
   ```
3. Verify that all phase scripts (`phase*.ps1`) are present alongside `main.ps1`.

---

## Usage

### Run the Full Investigation

Simply execute the main script:
```powershell
.\\main.ps1
```
The script will:
1. Detect its current location.
2. Instantiate the `AnalisisFases` class.
3. Execute all eight phases sequentially, storing artefacts in `C:\Cerberus_collection`.

### Execute a Single Phase

If you want to test or run only a specific phase, uncomment the example at the bottom of `main.ps1` and modify the call:
```powershell
$analizador.EjecutarFase(7, "YARAScan")
```
Replace the number and name with the desired phase.

---

## Project Structure

| Path | Description |
|------|-------------|
| `main.ps1` | Entry‑point that sets up the environment and drives the workflow. |
| `phase1-response.ps1` | Collects process lists, network connections, DNS cache, ARP table, and listening ports. |
| `phase2-persistence.ps1` | (Placeholder – intended for persistence artefacts such as scheduled tasks, services, registry run keys). |
| `phase3-browserindicators.ps1` | (Placeholder – would gather browser history, cookies, and cache). |
| `phase4-minningDetection.ps1` | (Placeholder – logic for detecting cryptocurrency mining activity). |
| `phase5-susFiles.ps1` | (Placeholder – scan for suspicious files, hashes, and known IoCs). |
| `phase6-networkTraffic.ps1` | (Placeholder – deeper network traffic capture, e.g., using `netsh` or packet captures). |
| `phase7-YARAScan.ps1` | (Placeholder – run YARA rules against collected artefacts). |
| `phase8-memory.ps1` | (Placeholder – memory dump acquisition via `procdump` or built‑in tools). |
| `README.md` | This documentation file. |
| `.git/` | Git repository metadata. |

---

## Detailed Phase Descriptions

1. **Response (Phase 1)** – Gathers the immediate volatile data needed for incident response, such as:
   - Process list (`tasklist`, `Get‑Process`).
   - Active network connections (`netstat`).
   - DNS cache (`ipconfig /displaydns`).
   - ARP table (`arp -a`).
   - Listening ports with owning process names.
2. **Persistence (Phase 2)** – Intended to enumerate startup mechanisms (registry `Run` keys, scheduled tasks, services). *Implementation pending.*
3. **Browser Indicators (Phase 3)** – Planned extraction of browser artefacts (history, cookies, extensions). *Implementation pending.*
4. **Mining Detection (Phase 4)** – Detects evidence of cryptomining tools or scripts. *Implementation pending.*
5. **Suspicious Files (Phase 5)** – Scans filesystem for known malicious file hashes or patterns. *Implementation pending.*
6. **Network Traffic (Phase 6)** – Captures longer‑term network traces or flow records. *Implementation pending.*
7. **YARA Scan (Phase 7)** – Executes YARA rules against the collected artefacts to flag known signatures. *Implementation pending.*
8. **Memory (Phase 8)** – Acquires a memory dump for offline analysis. *Implementation pending.*

---

## License

This project is released under the **MIT License** – see the `LICENSE` file for details.

---

## Contributing

Contributions are welcome!  Feel free to:
- Add missing implementations for the placeholder phases.
- Improve error handling and logging.
- Extend the YARA rule set.
- Add support for Linux/macOS forensic collection.

Please open an issue or submit a pull request on the repository.

---

## Disclaimer

Cerberus is provided **as‑is** for educational and defensive security purposes.  The author assumes no liability for any misuse or damage caused by the tool.  Always obtain proper authorization before performing forensic analysis on any system.
