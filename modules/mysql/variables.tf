variable "compartment_id" { type = string }
variable "availability_domain" { type = string }
variable "subnet_id" {
  description = "Subnet privada del spoke para el DB System."
  type        = string
}
variable "shape" {
  type    = string
  default = "MySQL.2"
}
variable "admin_username" {
  type    = string
  default = "admin"
}
variable "admin_password" {
  type      = string
  sensitive = true
}
variable "data_storage_gb" {
  type    = number
  default = 50
}
variable "display_name" {
  type    = string
  default = "mysql-demo"
}
variable "freeform_tags" {
  type    = map(string)
  default = {}
}

# Réplica (canal). Se habilita en la región alterna apuntando a la principal.
variable "enable_replication" {
  type    = bool
  default = false
}
variable "source_hostname" {
  type    = string
  default = ""
}
variable "source_username" {
  type    = string
  default = ""
}
variable "source_password" {
  type      = string
  default   = ""
  sensitive = true
}
