############################
# Identidad / tenancy
############################
variable "tenancy_ocid" {
  description = "OCID del tenancy."
  type        = string
}

variable "compartment_ocid" {
  description = "OCID del compartment donde se crean los recursos."
  type        = string
}

variable "user_ocid" {
  type    = string
  default = ""
}
variable "fingerprint" {
  type    = string
  default = ""
}
variable "private_key_path" {
  type    = string
  default = ""
}

############################
# Regiones
############################
variable "primary_region" {
  description = "Región principal (activa)."
  type        = string
  default     = "us-ashburn-1"
}

variable "standby_region" {
  description = "Región alterna (warm standby)."
  type        = string
  default     = "us-chicago-1"
}

variable "deploy_standby" {
  description = "Si es false, solo despliega la región principal (ahorra costo)."
  type        = bool
  default     = true
}

############################
# Acceso
############################
variable "ssh_public_key" {
  description = "Clave SSH pública para las instancias (OPNsense, nodos)."
  type        = string
}

############################
# CIDRs
############################
variable "primary_hub_cidr" {
  type    = string
  default = "10.0.0.0/24"
}
variable "primary_spoke_cidr" {
  type    = string
  default = "10.0.1.0/24"
}
variable "standby_hub_cidr" {
  type    = string
  default = "10.10.0.0/24"
}
variable "standby_spoke_cidr" {
  type    = string
  default = "10.10.1.0/24"
}

############################
# OPNsense (firewall del hub)
############################
variable "opnsense_image_ocid_primary" {
  type    = string
  default = ""
}
variable "opnsense_image_ocid_standby" {
  type    = string
  default = ""
}
variable "opnsense_shape" {
  type    = string
  default = "VM.Standard.E4.Flex"
}
variable "opnsense_ocpus" {
  type    = number
  default = 1
}
variable "opnsense_memory_gb" {
  type    = number
  default = 8
}

############################
# OKE
############################
variable "kubernetes_version" {
  description = "Versión de Kubernetes para OKE. Ajustar a una disponible. TODO(tenancy)."
  type        = string
  default     = "v1.30.1"
}
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
variable "node_count_primary" {
  type    = number
  default = 1
}
variable "node_count_standby" {
  description = "0 = warm standby sin nodos hasta la demo."
  type        = number
  default     = 0
}

############################
# MySQL HeatWave
############################
variable "mysql_admin_username" {
  type    = string
  default = "admin"
}
variable "mysql_admin_password" {
  description = "Password del admin de MySQL (sensible). NO subir a git."
  type        = string
  sensitive   = true
}
variable "mysql_shape" {
  description = "Shape del DB System MySQL. Sin nodo HeatWave analítico para ahorrar."
  type        = string
  default     = "MySQL.2"
}
variable "mysql_data_storage_gb" {
  type    = number
  default = 50
}

############################
# DNS / Traffic Management
############################
variable "dns_zone_name" {
  description = "Dominio piloto para la demo (delegar NS a OCI)."
  type        = string
  default     = "dr-demo.example.com"
}
variable "app_record_name" {
  type    = string
  default = "app"
}

############################
# Scheduler
############################
variable "enable_scheduler" {
  type    = bool
  default = true
}
variable "shutdown_cron" {
  description = "Cron (UTC) de apagado. 22:00 Bogotá = 03:00 UTC."
  type        = string
  default     = "0 3 * * *"
}
variable "startup_cron" {
  description = "Cron (UTC) de encendido. 07:00 Bogotá = 12:00 UTC, L-V."
  type        = string
  default     = "0 12 * * 1-5"
}

############################
# Etiquetas
############################
variable "project_tag" {
  type    = string
  default = "movii-dr-demo"
}
