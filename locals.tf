locals {
  freeform_tags = {
    Project   = var.project_tag
    ManagedBy = "terraform"
    Demo      = "movii-oci-dr"
  }

  # Etiqueta usada por el scheduler para apagar/encender recursos.
  schedulable_tags = merge(local.freeform_tags, { Schedule = "office-hours" })
}
