#!/usr/bin/env bash
# Enciende la región alterna (Chicago) para la demo y escala OKE.
# Requiere OCI CLI configurado. Ajusta los OCIDs por salida de terraform output.
set -euo pipefail

REGION="${STANDBY_REGION:-us-chicago-1}"
OPNSENSE_ID="${OPNSENSE_STANDBY_ID:?define OPNSENSE_STANDBY_ID}"
OKE_NODE_POOL_ID="${OKE_STANDBY_NODE_POOL_ID:?define OKE_STANDBY_NODE_POOL_ID}"
NODE_SIZE="${NODE_SIZE:-1}"

echo ">> Encendiendo OPNsense alterna..."
oci compute instance action --action START --instance-id "$OPNSENSE_ID" --region "$REGION" || true

echo ">> Escalando node pool OKE alterna a ${NODE_SIZE}..."
oci ce node-pool update --node-pool-id "$OKE_NODE_POOL_ID" --size "$NODE_SIZE" --region "$REGION" || true

echo ">> Listo. Recuerda: el MySQL standby debe estar ACTIVE y el canal de réplica al día."
