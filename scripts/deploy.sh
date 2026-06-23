#!/usr/bin/env bash
# Wrapper simple de despliegue. Requiere terraform y OCI CLI configurado.
set -euo pipefail

ACTION="${1:-plan}"   # plan | apply | primary | destroy

case "$ACTION" in
  plan)    terraform init && terraform validate && terraform plan ;;
  apply)   terraform init && terraform apply ;;
  primary) terraform init && terraform apply -var="deploy_standby=false" ;;
  destroy) terraform destroy ;;
  *) echo "Uso: $0 [plan|apply|primary|destroy]"; exit 1 ;;
esac
