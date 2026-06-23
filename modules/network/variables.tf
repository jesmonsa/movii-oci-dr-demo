variable "compartment_id" {
  type = string
}

variable "label" {
  description = "Etiqueta de la región: primary | standby."
  type        = string
}

variable "hub_cidr" {
  type = string
}

variable "spoke_cidr" {
  type = string
}

variable "peer_cidrs" {
  description = "CIDRs de la otra región para enrutar vía DRG/RPC."
  type        = list(string)
  default     = []
}

variable "peer_rpc_id" {
  description = "OCID del RPC de la otra región. Si se define, este lado inicia el peering."
  type        = string
  default     = ""
}

variable "peer_region" {
  description = "Nombre de la región par para el RPC (ej. us-chicago-1)."
  type        = string
  default     = ""
}

variable "freeform_tags" {
  type    = map(string)
  default = {}
}
