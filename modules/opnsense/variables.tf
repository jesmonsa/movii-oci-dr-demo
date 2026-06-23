variable "compartment_id" { type = string }
variable "availability_domain" { type = string }
variable "subnet_id" {
  description = "Subnet pública del hub donde vive OPNsense."
  type        = string
}
variable "image_id" {
  description = "OCID de la imagen OPNsense (Marketplace). Requerido."
  type        = string
}
variable "shape" {
  type    = string
  default = "VM.Standard.E4.Flex"
}
variable "ocpus" {
  type    = number
  default = 1
}
variable "memory_gb" {
  type    = number
  default = 8
}
variable "ssh_public_key" { type = string }
variable "display_name" {
  type    = string
  default = "opnsense-fw"
}
variable "instance_state" {
  description = "RUNNING o STOPPED (warm standby)."
  type        = string
  default     = "RUNNING"
}
variable "freeform_tags" {
  type    = map(string)
  default = {}
}
