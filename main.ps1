
class AnalisisFases {
    # Almacenamos la ruta base donde viven todos los scripts de fase
    hidden [string]$RutaBase

    # El constructor recibe la ruta física donde se encuentra main.ps1
    AnalisisFases([string]$ruta) {
        $this.RutaBase = $ruta
    }

    # Método para ejecutar una fase individual
    [void] EjecutarFase([int]$numero, [string]$nombreFase) {
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
        
        # Mapeamos los números de fase con el nombre exacto de tu captura
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

        # Iteramos en orden del 1 al 8
        for ($i = 1; $i -le 8; $i++) {
            $this.EjecutarFase($i, $fases[$i])
        }

        Write-Host "=== Análisis Finalizado ===" -ForegroundColor Yellow
    }
}

# --- Flujo de Ejecución Principal ---

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