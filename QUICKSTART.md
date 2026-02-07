# 🚀 Deploy Rápido - Nanobot en Fly.io

## ⚡ Opción 1: Script Automatizado (RECOMENDADO)

### Paso Único:

1. Abre **PowerShell** (NO como administrador)
2. Ejecuta este comando:

```powershell
irm https://raw.githubusercontent.com/aaprosperi/nanobot/main/deploy.ps1 | iex
```

3. El script te pedirá:
   - ✅ OpenRouter Key: `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`
   - ✅ Telegram Token: `8517340337:AAHdBXG3EVKqNMywuWzFifIUa_397MuhesA`
   - ✅ Tu User ID: `7183589410`

4. ¡Listo! El bot estará corriendo en 5 minutos.

---

## 🛠️ Opción 2: Manual (Educativo)

### Prerequisitos:
- Git instalado
- PowerShell

### Pasos:

```powershell
# 1. Instalar Fly CLI
iwr https://fly.io/install.ps1 -useb | iex

# 2. Cerrar y abrir PowerShell de nuevo

# 3. Login en Fly.io
fly auth login

# 4. Clonar el repo
git clone https://github.com/aaprosperi/nanobot.git
cd nanobot

# 5. Crear config.json (NO lo commitees)
@"
{
  "providers": {
    "openrouter": {
      "apiKey": "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"
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
      "token": "8517340337:AAHdBXG3EVKqNMywuWzFifIUa_397MuhesA",
      "allowFrom": ["7183589410"]
    }
  }
}
"@ | Out-File config.json -Encoding UTF8

# 6. Launch en Fly.io
fly launch --now --name nanobot-pixan --region mia --no-public-ips --internal-port 18790 --ha=false

# 7. Subir config como secret
cat config.json | fly secrets import

# 8. Deploy
fly deploy

# 9. Limpiar config local
del config.json

# 10. Ver logs
fly logs --follow
```

---

## 🧪 Probar el bot

Abre Telegram y envía:
```
/start
Hola! ¿Qué modelo de IA estás usando?
```

---

## 📊 Comandos útiles

```powershell
fly status              # Ver estado
fly logs                # Ver logs
fly logs --follow       # Logs en tiempo real
fly ssh console         # Conectar al contenedor
fly scale count 1       # Asegurar 1 instancia
fly apps list           # Ver todas tus apps
```

---

## ❓ Troubleshooting

### El bot no responde
```powershell
fly logs --follow
```
Busca errores de API key o modelo.

### Ver configuración actual
```powershell
fly ssh console
cat /root/.nanobot/config.json
```

### Reiniciar el bot
```powershell
fly apps restart nanobot-pixan
```

---

## 🎓 ¿Qué aprendiste?

✅ Fork de repositorio con GitHub MCP  
✅ Modificar Dockerfile para Fly.io  
✅ Configurar fly.toml para Python  
✅ Usar secrets para credenciales  
✅ Deploy de bot de Telegram en la nube  
✅ Debugging con logs de Fly.io  

---

## 📚 Archivos importantes del proyecto

- `Dockerfile.fly` → Imagen optimizada para Fly.io
- `fly.toml` → Configuración del app
- `deploy.ps1` → Script de deploy automatizado
- `DEPLOY-FLYIO.md` → Guía detallada

---

🎉 **¡Bot corriendo 24/7 en Fly.io!**
