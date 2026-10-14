#!/usr/bin/env pwsh
# Starts a Rojo sync server for Pastel Rift Survival.
# Run from this game's folder:  ./scripts/bootstrap.ps1

$ErrorActionPreference = "Stop"

if (-not (Get-Command rojo -ErrorAction SilentlyContinue)) {
    Write-Host "Rojo was not found on your PATH." -ForegroundColor Red
    Write-Host "Install it with:  cargo install rojo" -ForegroundColor Yellow
    Write-Host "or download a release from https://github.com/rojo-rbx/rojo/releases" -ForegroundColor Yellow
    Write-Host "Alternatively, install the Rojo VS Code extension." -ForegroundColor Yellow
    exit 1
}

# Rojo reads default.project.json from the current directory, so run from the game root.
$gameRoot = Split-Path -Parent $PSScriptRoot
Push-Location $gameRoot
try {
    Write-Host "Starting Rojo serve for Pastel Rift Survival from $gameRoot ..." -ForegroundColor Cyan
    rojo serve
}
finally {
    Pop-Location
}
