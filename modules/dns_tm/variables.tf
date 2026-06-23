variable "compartment_id" { type = string }
variable "zone_name" {
  description = "Dominio piloto (delegar NS a OCI)."
  type        = string
}
variable "app_record_name" {
  type    = string
  default = "app"
}
variable "primary_ip" {
  description = "IP pública de entrada en la región principal."
  type        = string
}
variable "standby_ip" {
  description = "IP pública de entrada en la región alterna."
  type        = string
}
variable "health_path" {
  type    = string
  default = "/"
}
variable "freeform_tags" {
  type    = map(string)
  default = {}
}
