# Variables adicionales (IAM). Se separan para no tocar variables.tf base.
variable "create_iam" {
  description = "Crea grupos dinámicos y políticas (MySQL, OKE, FSDR, Scheduler)."
  type        = bool
  default     = true
}

variable "operator_group_ocid" {
  description = "OCID del grupo que ejecuta Terraform. Vacío = no crea política de operador (útil si ya eres administrador)."
  type        = string
  default     = ""
}
