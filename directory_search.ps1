# Definir el directorio raíz (en este caso C:) y las extensiones de archivo
$directorio = "C:\"
$extensiones = @("*.txt", "*.log", "*.jpg")  # Agrega aquí las extensiones que deseas buscar
$cadenaBusqueda = "miString"  # El string que debe contener el nombre del archivo

# Definir el nombre de la unidad USB (etiqueta del volumen)
$nombreUSB = "MiUSB"  # Cambia esto por el nombre de tu unidad USB

# Obtener la unidad USB por su nombre
$unidadUSB = Get-Volume | Where-Object { $_.FileSystemLabel -eq $nombreUSB }

# Verificar que se encontró la unidad USB
if ($unidadUSB) {
    # Obtener la ruta de la unidad USB
    $rutaUSB = $unidadUSB.DriveLetter + ":\"

    # Realizar la búsqueda recursiva en el directorio C: con las extensiones y string especificados
    Get-ChildItem -Path $directorio -Recurse -File | Where-Object {
        # Filtrar por las extensiones y la cadena en el nombre del archivo
        ($extensiones -contains $_.Extension) -and ($_.Name -like "*$cadenaBusqueda*")
    } | ForEach-Object {
        # Generar la ruta de destino en la unidad USB
        $destino = Join-Path -Path $rutaUSB -ChildPath $_.Name
        
        # Copiar el archivo a la unidad USB
        Copy-Item -Path $_.FullName -Destination $destino
        
        # Mostrar un mensaje indicando que el archivo se copió
        Write-Host "Archivo copiado: $($_.FullName) -> $destino"
    }
} else {
    Write-Host "No se encontró la unidad USB con el nombre '$nombreUSB'."
}
