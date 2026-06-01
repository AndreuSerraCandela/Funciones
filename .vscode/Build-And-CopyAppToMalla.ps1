param(
    [Parameter(Mandatory = $true)]
    [string]$WorkspaceFolder
)

$destFolder = 'C:\apps\Malla'
$appJsonPath = Join-Path $WorkspaceFolder 'app.json'
$appJson = Get-Content $appJsonPath -Raw | ConvertFrom-Json
$appFileName = "$($appJson.publisher)_$($appJson.name)_$($appJson.version).app"
$sourcePath = Join-Path $WorkspaceFolder $appFileName
$destPath = Join-Path $destFolder $appFileName

Write-Host "Esperando paquete $appFileName (AL: Package)..."

# Esperar a que AL: Package genere el .app en la raíz del proyecto (máx. 5 minutos)
$timeoutSeconds = 100
$elapsed = 0
while ($elapsed -lt $timeoutSeconds) {
    if (Test-Path $sourcePath) {
        Start-Sleep -Seconds 2
        break
    }
    Start-Sleep -Seconds 1
    $elapsed++
}

if (-not (Test-Path $sourcePath)) {
    Write-Error "No se encontró $appFileName en $WorkspaceFolder tras $timeoutSeconds s. Comprueba que AL: Package terminó sin errores."
    exit 1
}

if (-not (Test-Path $destFolder)) {
    New-Item -ItemType Directory -Path $destFolder -Force | Out-Null
}

Copy-Item -Path $sourcePath -Destination $destPath -Force
Write-Host "Paquete generado y copiado: $appFileName -> $destFolder"
