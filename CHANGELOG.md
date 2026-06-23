# Changelog

## v0.1 (2026-06) — Scaffolding inicial

- Terraform modular: `network` (hub-and-spoke, DRG, RPC), `opnsense`, `oke`, `mysql`,
  `dns_tm` (Traffic Management failover + Health Checks), `iam` (grupos dinámicos + políticas).
- Módulos documentados `scheduler` (apagado horario) y `fsdr` (Full Stack DR).
- App Java de demo + Dockerfile + manifiestos K8s.
- Función Python de apagado por tag y runbooks (réplica MySQL, failover/switchback).
- One-click (Resource Manager) con `schema.yaml`.
- Validación offline: sintaxis HCL OK en todos los `.tf`; cruce de variables y outputs OK.
- **Pendiente** (`TODO(tenancy)`): `terraform validate/plan` contra el trial, OCID de
  imágenes OPNsense, versión de OKE, endpoints de réplica MySQL, ajuste de FSDR/Scheduler.
