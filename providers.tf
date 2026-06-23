# Autenticación: en Resource Manager se usa la sesión del Stack (no requiere claves).
# En CLI, el provider usa ~/.oci/config o variables de entorno (TF_VAR_* / OCI_*).

provider "oci" {
  region = var.primary_region
}

provider "oci" {
  alias  = "standby"
  region = var.standby_region
}
