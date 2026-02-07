#!/bin/bash
set -e

# Create config directory
mkdir -p /root/.nanobot

# Check if config already exists
if [ ! -f /root/.nanobot/config.json ]; then
  echo "Creating config.json from environment variables..."
  
  cat > /root/.nanobot/config.json << EOF
{
  "providers": {
    "openrouter": {
      "apiKey": "${OPENROUTER_API_KEY}"
    }
  },
  "agents": {
    "defaults": {
      "model": "${DEFAULT_MODEL:-anthropic/claude-sonnet-4-5}"
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "token": "${TELEGRAM_BOT_TOKEN}",
      "allowFrom": ["${TELEGRAM_USER_ID}"]
    }
  },
  "tools": {
    "restrictToWorkspace": true,
    "web": {
      "search": {
        "apiKey": "${BRAVE_SEARCH_KEY:-}"
      }
    }
  }
}
EOF
  echo "✅ Config created"
else
  echo "✅ Config already exists"
fi

# Start nanobot gateway
exec nanobot gateway
