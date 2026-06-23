variable "compartment_id" { type = string }
variable "vcn_id" { type = string }
variable "endpoint_subnet_id" {
  description = "Subnet del API endpoint del cluster (regional)."
  type        = string
}
variable "node_subnet_id" {
  description = "Subnet de los worker nodes."
  type        = string
}
variable "lb_subnet_ids" {
  description = "Subnets para los Load Balancers de servicios."
  type        = list(string)
}
variable "availability_domain" { type = string }
variable "kubernetes_version" { type = string }
variable "node_shape" {
  type    = string
  default = "VM.Standard.E4.Flex"
}
variable "node_ocpus" {
  type    = number
  default = 1
}
variable "node_memory_gb" {
  type    = number
  default = 8
}
variable "node_count" {
  type    = number
  default = 1
}
variable "node_image_id" {
  description = "OCID de imagen para nodos OKE. Vacío = autodetecta Oracle Linux 8. TODO(tenancy)."
  type        = string
  default     = ""
}
variable "ssh_public_key" { type = string }
variable "cluster_name" {
  type    = string
  default = "oke-demo"
}
variable "freeform_tags" {
  type    = map(string)
  default = {}
}
