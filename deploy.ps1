# 🚀 Script de Deploy Automatizado para Nanobot en Fly.io
# Autor: Claude + aaprosperi
# Fecha: 2026-02-07

Write-Host "🐈 Nanobot - Deploy Automatizado en Fly.io" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si estamos en PowerShell
if (-not $PSVersionTable) {
    Write-Host "❌ Este script debe ejecutarse en PowerShell" -ForegroundColor Red
    exit 1
}

# PASO 1: Verificar/Instalar Fly CLI
Write-Host "📦 PASO 1: Verificando Fly CLI..." -ForegroundColor Yellow
$flyCommand = Get-Command fly -ErrorAction SilentlyContinue

if (-not $flyCommand) {
    Write-Host "⬇️ Instalando Fly CLI..." -ForegroundColor Green
    iwr https://fly.io/install.ps1 -useb | iex
    
    # Actualizar PATH en la sesión actual
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    Write-Host "✅ Fly CLI instalado. Por favor CIERRA y VUELVE A ABRIR PowerShell, luego ejecuta este script de nuevo." -ForegroundColor Green
    Write-Host "Presiona Enter para salir..."
    Read-Host
    exit 0
} else {
    Write-Host "✅ Fly CLI ya está instalado ($(fly version))" -ForegroundColor Green
}

Write-Host ""

# PASO 2: Login en Fly.io
Write-Host "🔐 PASO 2: Login en Fly.io..." -ForegroundColor Yellow
Write-Host "Se abrirá tu navegador para autenticarte." -ForegroundColor Gray

try {
    fly auth whoami 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Ya estás logueado en Fly.io" -ForegroundColor Green
    }
} catch {
    Write-Host "Iniciando login..." -ForegroundColor Gray
    fly auth login
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Error en el login. Intenta de nuevo." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""

# PASO 3: Solicitar credenciales (SIN MOSTRARLAS EN PANTALLA)
Write-Host "🔑 PASO 3: Configurando credenciales..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Necesito tus credenciales (no se guardarán en archivos de texto):" -ForegroundColor Cyan

# OpenRouter API Key
Write-Host ""
Write-Host "1️⃣ OpenRouter API Key:" -ForegroundColor White
$OPENROUTER_KEY = Read-Host "   Pega tu key (sk-or-v1-...)" -AsSecureString
$OPENROUTER_KEY_PLAIN = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($OPENROUTER_KEY))

# Telegram Bot Token
Write-Host ""
Write-Host "2️⃣ Telegram Bot Token:" -ForegroundColor White
$TELEGRAM_TOKEN = Read-Host "   Pega tu token (xxxxxxxxx:AAH...)" -AsSecureString
$TELEGRAM_TOKEN_PLAIN = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($TELEGRAM_TOKEN))

# Telegram User ID
Write-Host ""
Write-Host "3️⃣ Tu Telegram User ID:" -ForegroundColor White
$TELEGRAM_USER_ID = Read-Host "   Ingresa tu ID (ej: 7183589410)"

Write-Host ""
Write-Host "✅ Credenciales capturadas de forma segura" -ForegroundColor Green

# PASO 4: Clonar el repositorio
Write-Host ""
Write-Host "📂 PASO 4: Clonando repositorio..." -ForegroundColor Yellow

$repoPath = Join-Path $env:TEMP "nanobot-deploy"

if (Test-Path $repoPath) {
    Write-Host "🗑️ Limpiando instalación anterior..." -ForegroundColor Gray
    Remove-Item -Recurse -Force $repoPath
}

Write-Host "⬇️ Clonando desde GitHub..." -ForegroundColor Gray
git clone https://github.com/aaprosperi/nanobot.git $repoPath

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al clonar el repositorio. ¿Tienes Git instalado?" -ForegroundColor Red
    exit 1
}

Set-Location $repoPath
Write-Host "✅ Repositorio clonado" -ForegroundColor Green

# PASO 5: Crear config.json TEMPORAL (no se commitea)
Write-Host ""
Write-Host "⚙️ PASO 5: Creando configuración..." -ForegroundColor Yellow

$configJson = @"
{
  "providers": {
    "openrouter": {
      "apiKey": "$OPENROUTER_KEY_PLAIN"
    }
  },
  "agents": {
    "defaults": {
      "model": "google/gemini-3-flash-preview"
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "token": "$TELEGRAM_TOKEN_PLAIN",
      "allowFrom": ["$TELEGRAM_USER_ID"]
    }
  }
}
"@

# Guardar config temporal
$configPath = Join-Path $repoPath "config.json"
$configJson | Out-File -FilePath $configPath -Encoding UTF8
Write-Host "✅ Configuración creada (temporal)" -ForegroundColor Green

# PASO 6: Deploy en Fly.io
Write-Host ""
Write-Host "🚀 PASO 6: Desplegando en Fly.io..." -ForegroundColor Yellow
Write-Host ""
Write-Host "⏳ Este proceso puede tardar 3-5 minutos..." -ForegroundColor Gray
Write-Host ""

# Launch (sin deploy aún)
Write-Host "📋 Configurando app en Fly.io..." -ForegroundColor Gray
fly launch --now --name nanobot-pixan --region mia --no-public-ips --internal-port 18790 --ha=false

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al configurar la app en Fly.io" -ForegroundColor Red
    exit 1
}

# Subir config como secret
Write-Host ""
Write-Host "🔐 Subiendo configuración como secret..." -ForegroundColor Gray
Get-Content $configPath | fly secrets import

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al subir secrets" -ForegroundColor Red
    exit 1
}

# Deploy final
Write-Host ""
Write-Host "📦 Construyendo y desplegando..." -ForegroundColor Gray
fly deploy

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error en el deploy" -ForegroundColor Red
    exit 1
}

# PASO 7: Limpiar config temporal
Write-Host ""
Write-Host "🧹 PASO 7: Limpiando archivos temporales..." -ForegroundColor Yellow
Remove-Item $configPath -Force
Write-Host "✅ Config temporal eliminada" -ForegroundColor Green

# PASO 8: Verificar deployment
Write-Host ""
Write-Host "✅ PASO 8: Verificando deployment..." -ForegroundColor Yellow
Write-Host ""

fly status

Write-Host ""
Write-Host "📊 Logs en tiempo real (Ctrl+C para salir):" -ForegroundColor Cyan
Write-Host ""

Start-Sleep -Seconds 3
fly logs

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "🎉 ¡DEPLOY COMPLETADO!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🤖 Tu bot está corriendo en: https://nanobot-pixan.fly.dev" -ForegroundColor White
Write-Host "📱 Pruébalo en Telegram: @NanoPixanBot" -ForegroundColor White
Write-Host ""
Write-Host "📚 Comandos útiles:" -ForegroundColor Cyan
Write-Host "   fly logs --follow        Ver logs en tiempo real" -ForegroundColor Gray
Write-Host "   fly ssh console          Conectar al contenedor" -ForegroundColor Gray
Write-Host "   fly status               Ver estado del app" -ForegroundColor Gray
Write-Host "   fly scale count 1        Asegurar 1 instancia" -ForegroundColor Gray
Write-Host ""
