variable "compartment_id" { type = string }

variable "drg_id" {
  description = "OCID del DRG (de la region) donde termina el tunel IPSec."
  type        = string
}

variable "cpe_public_ip" {
  description = "IP publica del equipo on-premises (Fortinet de Movii / CPE)."
  type        = string
}

variable "cpe_display_name" {
  type    = string
  default = "movii-cpe"
}

variable "onprem_cidrs" {
  description = "Rutas estaticas hacia la(s) red(es) on-premises."
  type        = list(string)
  default     = ["192.168.0.0/16"]
}

variable "display_name" {
  type    = string
  default = "movii-ipsec"
}

variable "freeform_tags" {
  type    = map(string)
  default = {}
}
