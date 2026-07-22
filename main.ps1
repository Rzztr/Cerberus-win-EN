
$banner = @"
 ██████╗███████╗██████╗ ██████╗ ███████╗██████╗ ██╗   ██╗███████╗    
██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗██║   ██║██╔════╝    
██║     █████╗  ██████╔╝██████╔╝█████╗  ██████╔╝██║   ██║███████╗    
██║     ██╔══╝  ██╔══██╗██╔══██╗██╔══╝  ██╔══██╗██║   ██║╚════██║    
╚██████╗███████╗██║  ██║██████╔╝███████╗██║  ██║╚██████╔╝███████║    
 ╚═════╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝    
-----------------------Windows Version ---------------------------
"@

Write-Host $banner -ForegroundColor Cyan
Write-Verbose "Displayed banner"
. "$PSScriptRoot\globals.ps1"
class AnalisisFases {
    # Enable verbose output for this class
    hidden [bool]$VerboseEnabled = $true
    # Almacenamos la ruta base donde viven todos los scripts de fase
    hidden [string]$RutaBase

    # El constructor recibe la ruta física donde se encuentra main.ps1
    AnalisisFases([string]$ruta) {
        $this.RutaBase = $ruta
        Write-Verbose "Base path set to $ruta"

        $this.RutaBase = $ruta
    }

    # Método para ejecutar una fase individual
    [void] EjecutarFase([int]$numero, [string]$nombreFase) {
        # Build script name
        $nombreArchivo = "phase$numero-$nombreFase.ps1"
        $rutaCompleta = Join-Path $this.RutaBase $nombreArchivo
        
        if (Test-Path $rutaCompleta) {
            Write-Host "[*] Iniciando Fase $numero: $nombreFase..." -ForegroundColor Cyan
            Write-Verbose "Executing script: $rutaCompleta"
            
            # Execute the script
            & $rutaCompleta
            
            Write-Host "[+] Fase $numero completada.`n" -ForegroundColor Green
            Write-Verbose "Phase $numero completed"
        } else {
            Write-Error "[-] No se encontró el script de la Fase $numero en: $rutaCompleta"
            Write-Verbose "Script not found for phase $numero"
        }
        # Construimos el nombre exacto del archivo (ej. phase1-response.ps1)
        $nombreArchivo = "phase$numero-$nombreFase.ps1"
        $rutaCompleta = Join-Path $this.RutaBase $nombreArchivo

        if (Test-Path $rutaCompleta) {
            Write-Host "[*] Iniciando Fase $numero: $nombreFase..." -ForegroundColor Cyan
            
            # Ejecutamos el script usando el operador de invocación (&)
            & $rutaCompleta
            
            Write-Host "[+] Fase $numero completada.`n" -ForegroundColor Green
        } else {
            Write-Error "[-] No se encontró el script de la Fase $numero en: $rutaCompleta"
        }
    }

    # Método para automatizar y correr todas las fases secuencialmente
    [void] EjecutarFlujoCompleto() {
        Write-Host "=== Iniciando Análisis Forense Secuencial ===" -ForegroundColor Yellow
        Write-Verbose "Starting full sequential forensic analysis"
        
        # Map phase numbers to script names
        $fases = @{ 
            1 = "response"
            2 = "persistence"
            3 = "browserindicators"
            4 = "minningDetection" # Ojo: "minning" con doble 'n' como en tu captura
            5 = "susFiles"
            6 = "networkTraffic"
            7 = "YARAScan"
            8 = "memory"
        }
        
        # Iterate through phases 1 to 8
        for ($i = 1; $i -le 8; $i++) {
            $this.EjecutarFase($i, $fases[$i])
        }
        
        Write-Host "=== Análisis Finalizado ===" -ForegroundColor Yellow
        Write-Verbose "All phases completed"
    }
}

# --- Flujo de Ejecución Principal ---

# Enable verbose output globally
$VerbosePreference = "Continue"

# 1. Capturamos la ruta real del script actual (main.ps1)
$directorioActual = $PSScriptRoot

# 2. Instanciamos nuestra clase pasándole la ruta detectada
$analizador = [AnalisisFases]::new($directorioActual)

# 3. Elegimos qué hacer:
# Opción A: Ejecutar todo el flujo automáticamente de corrido
$analizador.EjecutarFlujoCompleto()

# Opción B: Si solo quisieras probar una fase específica por separado, harías esto:
# $analizador.EjecutarFase(7, "YARAScan")

#PD: No me pagan, literal lo hago por que estoy aburrido y me da hueva revisar comando por comando y carpeta por carpeta jaja