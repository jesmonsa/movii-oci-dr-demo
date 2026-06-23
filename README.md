# Movii — Demo de Disaster Recovery multi-región en OCI

Despliegue **automatizado con Terraform** de una arquitectura de Disaster Recovery (DR) multi-región en Oracle Cloud Infrastructure (OCI), pensada como **demo acotada** para Movii sobre un ambiente **SE Trial (~USD 500 / 2 meses)**.

- **Región principal:** `us-ashburn-1` (Ashburn) — *activa*
- **Región alterna:** `us-chicago-1` (Chicago) — *warm standby (instancias apagadas hasta la demo)*

> ⚠️ **Aviso de costo y trial.** Este proyecto está diseñado para ser barato, pero igual consume crédito. Los shapes son mínimos, la región alterna nace **apagada** y hay un **apagado programado** (noches y fines de semana). Verifica los **límites de servicio** de tu cuenta trial antes de aplicar (multi-región, OKE, MySQL, shapes disponibles). No subas credenciales ni OCIDs reales a este repositorio público.

---

## Arquitectura

Red **hub-and-spoke** por región (simula la topología de Movii):

```
                 OCI DNS + Traffic Management (GLOBAL, FAILOVER + Health Checks)
                         |                                   |
        ┌──────────── PRINCIPAL (Ashburn) ────────┐  ┌─────── ALTERNA (Chicago, warm) ───────┐
        |  HUB VCN: OPNsense (firewall/routing)    |  |  HUB VCN: OPNsense                      |
        |  SPOKE VCN: OKE + App Java + MySQL       |  |  SPOKE VCN: OKE(0) + MySQL réplica RO   |
        |  DRG ─────────────  RPC ───────────────── DRG (remote peering entre regiones)        |
        └─────────────────────────────────────────┘  └────────────────────────────────────────┘
                         Full Stack DR orquesta el failover/switchover (DR Plan)
```

**Componentes (Terraform):** VCN hub + spoke, DRG + Remote Peering Connection (RPC), OPNsense como firewall/enrutador del hub, OKE (node pool mínimo), MySQL HeatWave (DB System + canal de réplica entre regiones), DNS Zones + Traffic Management Steering (FAILOVER) con Health Checks, y **OCI Resource Scheduler** para apagar recursos en horario no hábil.

**Complementario (semi-manual / Ansible / consola):** configuración fina de OPNsense, despliegue de la app Java en OKE, canal de réplica MySQL, Identity Domains DR y los DR Protection Groups de Full Stack DR (cobertura parcial en Terraform).

---

## Estructura del repositorio

```
.
├── versions.tf providers.tf variables.tf outputs.tf main.tf locals.tf
├── terraform.tfvars.example      # copia a terraform.tfvars y completa
├── schema.yaml                   # formulario one-click (Resource Manager)
├── modules/
│   ├── network/                  # hub-and-spoke, DRG, RPC, rutas, NSG
│   ├── opnsense/                 # firewall/enrutador del hub
│   ├── oke/                      # cluster + node pool
│   ├── mysql/                    # DB System + canal de réplica
│   ├── dns_tm/                   # DNS + Traffic Management (failover)
│   ├── scheduler/                # apagado/encendido programado
│   └── fsdr/                     # esqueleto Full Stack DR
├── app/                          # app Java mínima + Dockerfile + manifiestos K8s
├── ansible/                      # configuración OPNsense + deploy app
└── scripts/                      # réplica MySQL, failover/switchback, helpers
```

---

## Requisitos

- Cuenta OCI (SE Trial) con **multi-región habilitada** y límites para OKE/MySQL/Compute.
- Terraform `>= 1.5` (o OpenTofu) **o** usar el botón one-click de Resource Manager.
- Para CLI: OCI CLI configurado (`~/.oci/config`) o variables de entorno del provider.
- Una **clave SSH pública** para las instancias.
- (Opcional) **kubectl**, **Ansible** y **Docker** para la app.
- Imagen de **OPNsense** de Marketplace aceptada en ambas regiones (ver `variables.tf`).

---

## Opción A — One-click (Resource Manager)

1. Usa el botón **Deploy to Oracle Cloud**:

   [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/movii-oci-dr-demo/archive/refs/heads/main.zip)

2. Resource Manager lee `schema.yaml` y muestra un formulario. Completa compartment, regiones, SSH, password de MySQL e imágenes OPNsense.
3. **Plan** → **Apply**.

## Opción B — CLI

```bash
cp terraform.tfvars.example terraform.tfvars   # completa los valores
terraform init
terraform plan
terraform apply
```

> 💡 Empieza solo con la **región principal**: `terraform apply -var="deploy_standby=false"`. Levanta la alterna cuando vayas a ensayar el failover.

---

## Runbook de la demo (failover)

1. App Java corriendo en OKE (Ashburn) escribiendo en MySQL. DNS/TM apuntando a la principal.
2. Habilita el **canal de réplica** MySQL Ashburn → Chicago (`scripts/mysql_replication.md`).
3. Enciende la alterna y despliega la app (warm): `scripts/standby_up.sh`.
4. **Simula la caída**: apaga la entrada principal o marca el health check como no saludable.
5. **Traffic Management** conmuta el DNS a Chicago automáticamente.
6. **Promueve** la réplica MySQL en Chicago (`scripts/failover.md`).
7. Verifica la app operando en la alterna. Luego **switchback** ordenado.

---

## Optimización de costo

- Región alterna creada con **node pool en 0** e **instancias en STOPPED**.
- **OCI Resource Scheduler** apaga compute y MySQL **22:00–07:00** y **fines de semana** (configurable en `variables.tf`).
- Shapes mínimos (Flex 1 OCPU) y **sin nodo HeatWave analítico** (solo MySQL OLTP + réplica).
- **Teardown** al terminar: `terraform destroy`.

---

## Estado

**v0.1 — esqueleto funcional para `init/plan`.** La validación de sintaxis está pendiente de ejecutar contra el tenancy (el entorno de generación no tenía egress para `terraform init`). Los puntos marcados `TODO(tenancy)` requieren ajuste con el ambiente real (versiones de OKE, OCID de imágenes, endpoints de réplica). No es "apply perfecto al primer intento": es una base sólida para iterar.

## Licencia

UPL-1.0. Material de demostración; sin garantías. Validar costos, límites y SLAs antes de cualquier compromiso con el cliente.
