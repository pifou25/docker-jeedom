#!/usr/bin/env bash
set -euo pipefail

# install skopeo to copy images digests and tags
sudo apt-get -y update
sudo apt-get -y install skopeo

attempt=0
max_attempts=5
# copy all architectures of image with retry times and delay options
until skopeo copy --all --retry-times 3 --retry-delay 5s docker://ghcr.io/${REG_IMAGE_TAG} \
    docker://${DEST_REGISTRY}${REG_IMAGE_TAG}
do
  attempt=$((attempt+1))
  if [ "$attempt" -ge "$max_attempts" ]; then
    echo "❌ Trop de tentatives de copie vers ${DEST_REGISTRY}, abandon. (${attempt})" >> $GITHUB_STEP_SUMMARY
    exit 1
  fi
  echo "⚠️ Erreur 429, attente avant retry (${attempt}) copie vers ${DEST_REGISTRY}..." >> $GITHUB_STEP_SUMMARY
  sleep $((attempt * 10))  # pause progressive : 10s, 20s, 30s…
done