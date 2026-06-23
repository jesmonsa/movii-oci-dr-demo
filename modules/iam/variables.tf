variable "tenancy_ocid" { type = string }
variable "compartment_ocid" { type = string }
variable "operator_group_ocid" {
  description = "OCID del grupo que ejecuta Terraform (para otorgarle permisos). Vacío = omitir."
  type        = string
  default     = ""
}
variable "create_policies" {
  type    = bool
  default = true
}
variable "project_tag" {
  type    = string
  default = "movii-dr-demo"
}
