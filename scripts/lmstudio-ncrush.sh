#!/bin/bash
# lmstudio-ncrush.sh
# Holt Modellliste von LM Studio API v1 und schreibt ncrush-Config

LMSTUDIO_URL="http://localhost:1234"
CONFIG_DIR="$HOME/.config/ncrush"
CONFIG_FILE="$CONFIG_DIR/ncrush.json"

mkdir -p "$CONFIG_DIR"

echo "Hole Modellliste von LM Studio..."

MODELS_JSON=$(curl -sf \
  -H "Authorization: Bearer ${LM_API_TOKEN:-lmstudio}" \
  "$LMSTUDIO_URL/api/v1/models")

if [ $? -ne 0 ]; then
  echo "Fehler: LM Studio nicht erreichbar auf $LMSTUDIO_URL"
  exit 1
fi

# Nur LLMs, alle Capabilities korrekt mappen
MODELS=$(echo "$MODELS_JSON" | jq -r '
  [.models[]
   | select(.type == "llm")
   | {
       name: .display_name,
       id: .key,
       context_window: .max_context_length,
       default_max_tokens: (.max_context_length / 4 | floor),
       cost_per_1m_in: 0,
       cost_per_1m_out: 0,
       supports_tools: (.capabilities.trained_for_tool_use // false),
       supports_attachments: (.capabilities.vision // false)
     }
  ]
')

cat > "$CONFIG_FILE" << NCRUSHEOF
{
  "\$schema": "https://charm.land/crush.json",
  "default_provider": "lmstudio",
  "providers": {
    "lmstudio": {
      "name": "LM Studio",
      "base_url": "$LMSTUDIO_URL/v1/",
      "type": "openai-compat",
      "api_key": "${LM_API_TOKEN:-lmstudio}",
      "models": $(echo "$MODELS")
    },
    "anthropic": {
      "api_key": "${ANTHROPIC_API_KEY:-}"
    },
    "gemini": {
      "api_key": "${GEMINI_API_KEY:-}"
    }
  }
}
NCRUSHEOF

COUNT=$(echo "$MODELS" | jq length)
VISION_COUNT=$(echo "$MODELS" | jq '[.[] | select(.supports_attachments == true)] | length')
echo "✓ Config geschrieben: $CONFIG_FILE"
echo "✓ $COUNT LLM Modelle eingetragen ($VISION_COUNT mit Vision/Bild-Support)"
echo ""
ncrush models 2>/dev/null && echo "" || true
echo "Tipp: Skript nochmal ausführen wenn du Modelle in LM Studio wechselst"
