# Script mejorado para buscar y copiar archivos a USB
# Versión corregida con mejor manejo de errores y eficiencia

param(
    [string]$Directorio = "C:\Users",
    [string[]]$Extensiones = @("*.txt", "*.log", "*.jpg"),
    [string]$CadenaBusqueda = "MiString",
    [string]$NombreUSB = "MiUsb"
)

# Función para escribir log con timestamp
function Write-Log {
    param([string]$Mensaje, [string]$Nivel = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Nivel) {
        "ERROR" { "Red" }
        "WARNING" { "Yellow" }
        "SUCCESS" { "Green" }
        "INFO" { "Cyan" }
        default { "White" }
    }
    Write-Host "[$timestamp] $Mensaje" -ForegroundColor $color
}

# Función para crear nombre único si existe duplicado
function Get-UniqueFileName {
    param([string]$RutaDestino, [string]$NombreArchivo)
    
    $destino = Join-Path -Path $RutaDestino -ChildPath $NombreArchivo
    
    if (-not (Test-Path $destino)) {
        return $destino
    }
    
    $contador = 1
    $nombreSinExt = [System.IO.Path]::GetFileNameWithoutExtension($NombreArchivo)
    $extension = [System.IO.Path]::GetExtension($NombreArchivo)
    
    do {
        $nuevoNombre = "${nombreSinExt}_${contador}${extension}"
        $destino = Join-Path -Path $RutaDestino -ChildPath $nuevoNombre
        $contador++
    } while (Test-Path $destino)
    
    return $destino
}

# Función para copiar archivo con manejo de errores
function Copy-FileWithRetry {
    param([string]$Origen, [string]$Destino, [int]$Reintentos = 3)
    
    for ($i = 1; $i -le $Reintentos; $i++) {
        try {
            Copy-Item -Path $Origen -Destination $Destino -ErrorAction Stop -Force
            return $true
        }
        catch {
            if ($i -eq $Reintentos) {
                Write-Log "Error definitivo copiando $(Split-Path $Origen -Leaf): $($_.Exception.Message)" "ERROR"
                return $false
            }
            Write-Log "Reintento $i/$Reintentos para $(Split-Path $Origen -Leaf)" "WARNING"
            Start-Sleep -Seconds 1
        }
    }
    return $false
}

# Inicio del script
Write-Log "=== INICIANDO BÚSQUEDA Y COPIA DE ARCHIVOS ===" "INFO"
Write-Log "Directorio: $Directorio" "INFO"
Write-Log "Extensiones: $($Extensiones -join ', ')" "INFO"
Write-Log "Cadena de búsqueda: $CadenaBusqueda" "INFO"
Write-Log "USB objetivo: $NombreUSB" "INFO"

# Verificar permisos de administrador
$esAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
Write-Log "Ejecutando como administrador: $esAdmin" "INFO"

if (-not $esAdmin) {
    Write-Log "ADVERTENCIA: Sin permisos de administrador, algunos archivos podrían no ser accesibles" "WARNING"
}

# Buscar y validar USB
$unidadUSB = Get-Volume | Where-Object { $_.FileSystemLabel -eq $NombreUSB -and $_.DriveLetter }

if (-not $unidadUSB) {
    Write-Log "USB '$NombreUSB' no encontrada" "ERROR"
    Write-Log "USBs disponibles:" "INFO"
    Get-Volume | Where-Object { $_.DriveLetter -and $_.FileSystemLabel } | 
        ForEach-Object { Write-Host "  $($_.DriveLetter): - $($_.FileSystemLabel)" }
    exit 1
}

$rutaUSB = $unidadUSB.DriveLetter + ":\"
Write-Log "USB encontrada en: $rutaUSB" "SUCCESS"

# Verificar espacio disponible en USB
$espacioUSB = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq ($unidadUSB.DriveLetter + ":") }
$espacioLibreGB = [math]::Round($espacioUSB.FreeSpace / 1GB, 2)
Write-Log "Espacio libre en USB: $espacioLibreGB GB" "INFO"

# Contadores
$archivosCopiados = 0
$erroresAcceso = 0
$archivosEncontrados = 0

# Crear filtro de extensiones para Where-Object
$filtroExtensiones = $Extensiones | ForEach-Object { $_.Replace("*", "") }

Write-Log "Iniciando búsqueda de archivos..." "INFO"

# Buscar archivos de manera eficiente
try {
    # Verificar si el directorio existe
    if (-not (Test-Path $Directorio)) {
        Write-Log "El directorio $Directorio no existe" "ERROR"
        exit 1
    }

    # Búsqueda optimizada con manejo de errores por carpeta
    $archivos = @()
    
    # Obtener todos los subdirectorios primero
    $directorios = @($Directorio)
    try {
        $subdirectorios = Get-ChildItem -Path $Directorio -Directory -Recurse -Force -ErrorAction SilentlyContinue
        $directorios += $subdirectorios.FullName
    }
    catch {
        Write-Log "Advertencia obteniendo subdirectorios: $($_.Exception.Message)" "WARNING"
    }

    # Buscar en cada directorio individualmente
    foreach ($dir in $directorios) {
        try {
            Write-Progress -Activity "Buscando archivos" -Status "Directorio: $dir" -PercentComplete (($directorios.IndexOf($dir) / $directorios.Count) * 100)
            
            $archivosDir = Get-ChildItem -Path $dir -File -Force -ErrorAction SilentlyContinue | 
                Where-Object { 
                    ($filtroExtensiones -contains $_.Extension) -and 
                    ($_.Name -like "*$CadenaBusqueda*") 
                }
            
            if ($archivosDir) {
                $archivos += $archivosDir
                Write-Log "Encontrados $($archivosDir.Count) archivos en: $dir" "INFO"
            }
        }
        catch {
            Write-Log "Error accediendo a $dir : $($_.Exception.Message)" "WARNING"
            $erroresAcceso++
        }
    }

    Write-Progress -Completed -Activity "Buscando archivos"
    
    $archivosEncontrados = $archivos.Count
    Write-Log "Total de archivos encontrados: $archivosEncontrados" "SUCCESS"

    if ($archivosEncontrados -eq 0) {
        Write-Log "No se encontraron archivos que coincidan con los criterios" "WARNING"
        exit 0
    }

    # Copiar archivos
    Write-Log "Iniciando copia de archivos..." "INFO"
    
    $contador = 0
    foreach ($archivo in $archivos) {
        $contador++
        Write-Progress -Activity "Copiando archivos" -Status "Archivo: $($archivo.Name)" -PercentComplete (($contador / $archivosEncontrados) * 100)
        
        try {
            # Verificar que el archivo aún existe (por si fue movido/eliminado)
            if (-not (Test-Path $archivo.FullName)) {
                Write-Log "Archivo ya no existe: $($archivo.FullName)" "WARNING"
                continue
            }

            $destino = Get-UniqueFileName -RutaDestino $rutaUSB -NombreArchivo $archivo.Name
            
            Write-Log "Copiando: $($archivo.Name) -> $(Split-Path $destino -Leaf)" "INFO"
            
            if (Copy-FileWithRetry -Origen $archivo.FullName -Destino $destino) {
                Write-Log "✓ Copiado exitosamente: $($archivo.Name)" "SUCCESS"
                $archivosCopiados++
            } else {
                $erroresAcceso++
            }
        }
        catch {
            Write-Log "✗ Error inesperado con $($archivo.Name): $($_.Exception.Message)" "ERROR"
            $erroresAcceso++
        }
    }

    Write-Progress -Completed -Activity "Copiando archivos"

} catch {
    Write-Log "Error crítico durante la búsqueda: $($_.Exception.Message)" "ERROR"
    exit 1
}

# Resumen final
Write-Log "=== RESUMEN FINAL ===" "INFO"
Write-Log "Archivos encontrados: $archivosEncontrados" "INFO"
Write-Log "Archivos copiados exitosamente: $archivosCopiados" "SUCCESS"
Write-Log "Errores encontrados: $erroresAcceso" $(if ($erroresAcceso -gt 0) { "WARNING" } else { "INFO" })

if ($archivosCopiados -gt 0) {
    Write-Log "Operación completada. Revisa la USB en: $rutaUSB" "SUCCESS"
} else {
    Write-Log "No se copiaron archivos. Revisa los errores anteriores." "WARNING"
}

# Mostrar archivos copiados en la USB
try {
    $archivosUSB = Get-ChildItem -Path $rutaUSB -File | Where-Object { $_.Name -like "*$CadenaBusqueda*" }
    if ($archivosUSB) {
        Write-Log "Archivos en USB que contienen '$CadenaBusqueda':" "INFO"
        $archivosUSB | ForEach-Object { Write-Host "  - $($_.Name)" }
    }
} catch {
    Write-Log "No se pudo listar el contenido de la USB" "WARNING"
}

Write-Log "Script finalizado." "INFO"
