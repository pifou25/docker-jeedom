#!/usr/bin/env bash
set -euo pipefail

# Vérifie la limite et le nombre de pulls restants sur Docker Hub

# Dépendances : curl + jq
if ! command -v jq >/dev/null 2>&1; then
  echo "❌ jq est requis (sudo apt install jq ou brew install jq)"
  exit 1
fi

# 1️⃣ Récupère un token d'authentification pour une image publique
TOKEN=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull" \
    | jq -r '.token')

if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
  echo "❌ Impossible d'obtenir un token Docker Hub"
  exit 1
fi

# 2️⃣ Interroge le registre pour obtenir les infos de quota
HEADERS=$(curl -s -I -H "Authorization: Bearer $TOKEN" \
    https://registry-1.docker.io/v2/ratelimitpreview/test/manifests/latest)

# Exemple de lignes :
# RateLimit-Limit: 100;w=21600
# RateLimit-Remaining: 73;w=21600

# Extraire limite + fenêtre
read LIMIT WINDOW < <(echo "$HEADERS" | grep -i "RateLimit-Limit" | sed -E 's/.*: ([0-9]+);w=([0-9]+)/\1 \2/')
# Extraire le nombre restant
read REMAINING _ < <(echo "$HEADERS" | grep -i "RateLimit-Remaining" | sed -E 's/.*: ([0-9]+);w=([0-9]+)/\1 \2/')

# 3️⃣ Affiche un résumé propre
if [[ -n "$LIMIT" && -n "$REMAINING" && -n "$WINDOW" ]]; then
  CURRENT_DATETIME=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
  HOURS=$(awk "BEGIN {printf \"%.1f\", $WINDOW/3600}")
  SUMMARY="✅ Pulls restants au ${CURRENT_DATETIME} : $REMAINING / $LIMIT (fenêtre de ${HOURS}h)"

  echo "summary=$SUMMARY" >> "$GITHUB_OUTPUT"
  echo "remaining=$REMAINING" >> "$GITHUB_OUTPUT"
  echo "limit=$LIMIT" >> "$GITHUB_OUTPUT"
else
  SUMMARY="⚠️ Impossible de lire les en-têtes RateLimit:\n$HEADERS"
fi

# 👇 Export pour GitHub Actions
echo "summary=$SUMMARY" >> "$GITHUB_OUTPUT"
