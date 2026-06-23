#!/usr/bin/env bash
# Genera el kubeconfig para el cluster OKE indicado.
set -euo pipefail
CLUSTER_ID="${1:?Uso: $0 <OKE_CLUSTER_OCID> [region]}"
REGION="${2:-us-ashburn-1}"
oci ce cluster create-kubeconfig \
  --cluster-id "$CLUSTER_ID" \
  --file "$HOME/.kube/config" \
  --region "$REGION" \
  --token-version 2.0.0 \
  --kube-endpoint PUBLIC_ENDPOINT
echo "kubeconfig actualizado. Prueba: kubectl get nodes"
