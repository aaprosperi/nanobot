# 🚀 Deploy Nanobot a Fly.io - Guía Paso a Paso

## ✅ Prerequisitos
- Cuenta en Fly.io (gratis)
- PowerShell en Windows
- Tus credenciales:
  - OpenRouter API Key
  - Telegram Bot Token
  - Tu Telegram User ID: `7183589410`

---

## 📋 PASO 1: Instalar Fly CLI

Abre PowerShell como **administrador** y ejecuta:

```powershell
iwr https://fly.io/install.ps1 -useb | iex
```

Cierra y vuelve a abrir PowerShell para que reconozca el comando `fly`.

Verifica:
```powershell
fly version
```

---

## 🔐 PASO 2: Login en Fly.io

```powershell
fly auth login
```

Se abrirá tu navegador para autenticarte.

---

## 🎯 PASO 3: Crear el archivo de configuración LOCAL

Crea un archivo `config.json` en tu máquina (NO lo subas a GitHub):

```json
{
  "providers": {
    "openrouter": {
      "apiKey": "TU_OPENROUTER_KEY_AQUI"
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
      "token": "TU_TELEGRAM_BOT_TOKEN_AQUI",
      "allowFrom": ["7183589410"]
    }
  }
}
```

Reemplaza:
- `TU_OPENROUTER_KEY_AQUI` → Tu key de OpenRouter
- `TU_TELEGRAM_BOT_TOKEN_AQUI` → Token de @BotFather

---

## 🚀 PASO 4: Deploy

```powershell
# Clona el repo
git clone https://github.com/aaprosperi/nanobot.git
cd nanobot

# Copia tu config.json a la carpeta del proyecto
# (solo localmente, NO lo commitees)

# Deploy inicial
fly launch --no-deploy

# Cuando te pregunte:
# - App name: nanobot-pixan (o el que quieras)
# - Region: mia (Miami)
# - PostgreSQL: NO
# - Redis: NO

# Ahora sube tu config como secret
cat config.json | fly secrets import

# Deploy final
fly deploy
```

---

## 📊 PASO 5: Verificar

```powershell
fly status
fly logs
```

Deberías ver:
```
INFO:nanobot.gateway:Starting gateway...
INFO:telegram:Listening for messages...
```

---

## 🧪 PASO 6: Probar

Abre Telegram y envía un mensaje a `@NanoPixanBot`:
```
/start
Hola! ¿Qué modelo estás usando?
```

---

## 🔧 Comandos útiles

```powershell
fly logs --follow          # Ver logs en tiempo real
fly ssh console            # Conectarte al contenedor
fly secrets list           # Ver secrets (sin valores)
fly scale count 1          # Asegurar 1 instancia
fly apps destroy           # Eliminar app (cuidado!)
```

---

## ❓ Troubleshooting

### El bot no responde
```powershell
fly logs --follow
```
Busca errores de API key o modelo.

### Error de configuración
```powershell
fly ssh console
cat /root/.nanobot/config.json
```

### Ver el status del gateway
```powershell
fly ssh console
nanobot status
```

---

## 🎓 Lo que aprendiste

1. ✅ Fork de repositorio con MCP de GitHub
2. ✅ Modificar Dockerfile para Fly.io
3. ✅ Configurar fly.toml para Python
4. ✅ Usar secrets para credenciales seguras
5. ✅ Deploy de un bot de Telegram en la nube
6. ✅ Debugging con logs de Fly.io

---

🎉 ¡Bot corriendo 24/7 en Fly.io!
