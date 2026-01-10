<#
Installe FFmpeg Essentials (GyanD/codexffmpeg) dans bin/ de ton projet.
Téléchargement, extraction complète via Expand-Archive, puis copie.
#>

param(
    [string]$Version = "8.0.1"
)

$zipUrl = "https://github.com/GyanD/codexffmpeg/releases/download/$Version/ffmpeg-$Version-essentials_build.zip"
$scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$projectRoot = Resolve-Path "$scriptDir/.."
$binDir = Join-Path $projectRoot "bin"
$tempZip = Join-Path $env:TEMP "ffmpeg-$Version.zip"
$tempExtract = Join-Path $env:TEMP "ffmpeg-extract-$Version"

Write-Host "==> Téléchargement de FFmpeg $Version..."
Invoke-WebRequest -Uri $zipUrl -OutFile $tempZip -UseBasicParsing

# Prépare extraction
Remove-Item -Recurse -Force $tempExtract -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $tempExtract | Out-Null

Write-Host "==> Extraction complète via Expand-Archive..."
Expand-Archive -LiteralPath $tempZip -DestinationPath $tempExtract -Force

# Crée bin/ si nécessaire
if (-not (Test-Path $binDir)) {
    New-Item -ItemType Directory -Path $binDir | Out-Null
}

Write-Host "==> Copie des exécutables dans bin/ ..."
Get-ChildItem -Path (Join-Path $tempExtract "*\bin\*.exe") -Recurse | ForEach-Object {
    Write-Host "  • Copie $($_.FullName) → $binDir"
    Copy-Item -Path $_.FullName -Destination $binDir -Force
}

Write-Host "==> Nettoyage..."
Remove-Item -Recurse -Force $tempZip, $tempExtract

Write-Host "==> Terminé !"
Write-Host "ffmpeg, ffplay, ffprobe sont dans: $binDir"
