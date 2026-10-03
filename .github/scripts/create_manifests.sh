#!/usr/bin/env bash
set -euo pipefail

# change to the digests directory
cd /tmp/digests

# Vérifie qu'il y a bien des fichiers digest (produits par docker buildx build --push --output=type=digest)
if ! ls | grep -qE '^[a-f0-9]{64}$'; then
  echo "❌ Aucun digest trouvé dans le répertoire courant !" >> $GITHUB_STEP_SUMMARY
  echo "   (Tu dois exécuter 'docker buildx build --push --output=type=digest .' avant cette étape)" >> $GITHUB_STEP_SUMMARY
  exit 1
fi

# Affiche les fichiers digest pour info
echo "📦 [DEBUG] Digests trouvés :"
ls -alsh
echo "📦 [DEBUG] liste de tags :"
echo $(jq -cr '.tags | map("-t " + .) | join(" ")' <<< "$DOCKER_METADATA_OUTPUT_JSON")

# exécute la commande docker buildx imagetools create complète
docker buildx imagetools create \
  $(jq -cr '.tags | map("-t " + .) | join(" ")' <<< "$DOCKER_METADATA_OUTPUT_JSON") \
  $(printf "ghcr.io/${REGISTRY_IMAGE}@sha256:%s " *)

echo "✅ [SUCCESS] Manifest multi-arch créé avec succès."
