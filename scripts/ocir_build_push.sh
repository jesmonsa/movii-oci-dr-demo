#!/usr/bin/env bash
# Build y push de la imagen de la app a OCIR.
set -euo pipefail
REGION_KEY="${REGION_KEY:?ej. iad (Ashburn) u ord (Chicago)}"
NAMESPACE="${NAMESPACE:?namespace del tenancy}"
IMAGE="${REGION_KEY}.ocir.io/${NAMESPACE}/movii-dr-demo:latest"

docker build -t "$IMAGE" app/
docker push "$IMAGE"
echo "Imagen publicada: $IMAGE"
echo "Actualiza app/k8s/deployment.yaml -> image: $IMAGE"
