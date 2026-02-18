#!/bin/bash
set -e

CONFIG_DIR="/root/.nanobot"
CONFIG_FILE="$CONFIG_DIR/config.json"

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Always regenerate config from env vars (so changes in Railway take effect)
echo "Generating nanobot config from environment variables..."

cat > "$CONFIG_FILE" << EOF
{
  "providers": {
    "openrouter": {
      "apiKey": "${OPENROUTER_KEY}"
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
      "token": "${TELEGRAM_TOKEN}",
      "allowFrom": ["${TELEGRAM_USER_ID}"]
    }
  },
  "tools": {
    "restrictToWorkspace": true
  }
}
EOF

echo "✓ Config created at $CONFIG_FILE"

# Show config structure for debugging (hide secrets)
echo "Config structure (secrets hidden):"
cat "$CONFIG_FILE" | sed 's/"apiKey": ".*"/"apiKey": "***"/' | sed 's/"token": ".*"/"token": "***"/' || true

# Execute the command passed as arguments
echo "Starting: $@"
exec "$@"
