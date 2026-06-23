# Módulo fsdr (Full Stack Disaster Recovery)

FSDR orquesta el failover/switchover de la pila entre regiones. Su cobertura en Terraform
es **parcial** y sensible a la versión del provider, por lo que en **v0.1** se documenta
aquí y se completa por consola tras validar contra el tenancy (`TODO(tenancy)`).

## Recursos involucrados

- `oci_disaster_recovery_dr_protection_group` (uno por región: principal y standby)
- Asociación peer entre ambos grupos (role PRIMARY / STANDBY)
- Miembros del grupo (compute, OKE, MySQL, volume groups, etc.)
- DR Plans (se generan tras poblar los grupos) + prechecks

## Ejemplo (esqueleto, validar atributos)

```hcl
resource "oci_disaster_recovery_dr_protection_group" "primary" {
  compartment_id = var.compartment_ocid
  display_name   = "movii-dr-primary"
  # los miembros se agregan tras crear compute/OKE/MySQL
  # members { member_id = <ocid>, member_type = "COMPUTE_INSTANCE" ... }
}

resource "oci_disaster_recovery_dr_protection_group" "standby" {
  provider       = oci.standby
  compartment_id = var.compartment_ocid
  display_name   = "movii-dr-standby"
  association {
    role          = "STANDBY"
    peer_id       = oci_disaster_recovery_dr_protection_group.primary.id
    peer_region   = var.primary_region
  }
}
```

Después, en consola: generar el **DR Plan** (Switchover/Failover), correr **prechecks** y
ensayar un **switchover** controlado. Ver `scripts/failover.md`.
