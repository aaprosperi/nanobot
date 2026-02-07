#!/bin/bash
set -e

# Create config directory
mkdir -p /root/.nanobot

# Always recreate config from environment variables
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
echo "✅ Config created with model: ${DEFAULT_MODEL:-anthropic/claude-sonnet-4-5}"

# Start nanobot gateway
exec nanobot gateway
