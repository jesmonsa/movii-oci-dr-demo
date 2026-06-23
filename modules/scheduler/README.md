# Módulo scheduler (apagado en horario no hábil)

En **v0.1** el apagado/encendido se entrega como **script + Function** (ver `scripts/scheduler/`)
y/o como **OCI Resource Scheduler** (servicio nativo) configurado por consola o Terraform.
No se activa por defecto en el `main.tf` para no romper el `plan` mientras se valida el
esquema exacto del recurso contra la versión del provider en tu tenancy.

## Opción A — OCI Resource Scheduler (nativo, recomendado)

Ejemplo de recurso (validar atributos con tu versión de provider — `TODO(tenancy)`):

```hcl
resource "oci_resource_scheduler_schedule" "stop_office_hours" {
  compartment_id     = var.compartment_ocid
  display_name       = "stop-office-hours"
  action             = "STOP_RESOURCE"
  recurrence_type    = "CRON"
  recurrence_details = var.shutdown_cron   # "0 3 * * *" (UTC)

  resource_filters {
    attribute = "DEFINED_TAGS"
    value {
      namespace = "movii"
      tag_key   = "Schedule"
      tag_value = "office-hours"
    }
  }
}
# Análogo con action = "START_RESOURCE" y recurrence_details = var.startup_cron.
```

El filtro toma todos los recursos con el tag `Schedule=office-hours` (instancias OPNsense,
nodos OKE y DB Systems MySQL llevan ese tag desde Terraform).

## Opción B — OCI Function (Python)

Ver `scripts/scheduler/func.py`: recorre instancias y DB Systems MySQL con el tag
`Schedule=office-hours` y ejecuta start/stop. Se dispara con un **trigger cron**
(Resource Scheduler, Events, o un cron externo invocando la Function).
