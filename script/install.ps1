<#
Install FFmpeg Essentials (GyanD/codexffmpeg) in the project's bin/ directory.
Download, fully extract using Expand-Archive, then copy.
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

Write-Host "==> Downloading FFmpeg $Version..."
Invoke-WebRequest -Uri $zipUrl -OutFile $tempZip -UseBasicParsing

# Prepare for extraction
Remove-Item -Recurse -Force $tempExtract -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $tempExtract | Out-Null

Write-Host "==> Full extraction via Expand-Archive..."
Expand-Archive -LiteralPath $tempZip -DestinationPath $tempExtract -Force

# Create bin/ if necessary
if (-not (Test-Path $binDir)) {
    New-Item -ItemType Directory -Path $binDir | Out-Null
}

Write-Host "==> Copying the executables into bin/ ..."
Get-ChildItem -Path (Join-Path $tempExtract "*\bin\*.exe") -Recurse | ForEach-Object {
    Write-Host "  • Copie $($_.FullName) → $binDir"
    Copy-Item -Path $_.FullName -Destination $binDir -Force
}

Write-Host "==> Cleaning..."
Remove-Item -Recurse -Force $tempZip, $tempExtract

Write-Host "==> Finished !"
Write-Host "ffmpeg, ffplay, ffprobe sont dans: $binDir"
