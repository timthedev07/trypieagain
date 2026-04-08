#!/usr/bin/env bash
# Build the pie-model inference image for linux/amd64 and push to DockerHub.
#
# Usage:
#   ./build-push.sh              # builds and pushes timthedev07/trypieagain:latest
#   ./build-push.sh v1.0.0       # also tags as v1.0.0 (+ latest)
#
# Prerequisites:
#   docker login                 # authenticate with DockerHub first
#   docker buildx create --use   # create a buildx builder if one doesn't exist

set -euo pipefail

IMAGE="timthedev07/trypieagain"
TAG="${1:-latest}"

# Collect tag arguments
TAG_ARGS=("--tag" "${IMAGE}:${TAG}")
if [[ "$TAG" != "latest" ]]; then
    TAG_ARGS+=("--tag" "${IMAGE}:latest")
fi

echo "==> Building ${IMAGE}:${TAG} for linux/amd64 ..."
docker buildx build \
    --platform linux/amd64 \
    "${TAG_ARGS[@]}" \
    --push \
    .

echo ""
echo "==> Done."
echo "    Pull with : docker pull ${IMAGE}:${TAG}"
echo "    Hub page  : https://hub.docker.com/r/${IMAGE}"
