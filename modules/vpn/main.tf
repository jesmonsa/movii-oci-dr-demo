# Customer-Premises Equipment (representa el firewall on-premises, p. ej. Fortinet).
resource "oci_core_cpe" "this" {
  compartment_id = var.compartment_id
  display_name   = var.cpe_display_name
  ip_address     = var.cpe_public_ip
  freeform_tags  = var.freeform_tags
}

# Conexion IPSec Site-to-Site terminada en el DRG (ruteo estatico hacia on-premises).
resource "oci_core_ipsec" "this" {
  compartment_id = var.compartment_id
  cpe_id         = oci_core_cpe.this.id
  drg_id         = var.drg_id
  display_name   = var.display_name
  static_routes  = var.onprem_cidrs
  freeform_tags  = var.freeform_tags
}

# Tuneles autogenerados de la conexion (para leer estado / IPs de Oracle).
data "oci_core_ipsec_connection_tunnels" "this" {
  ipsec_id = oci_core_ipsec.this.id
}

# TODO(tenancy): personalizar IKE/IPSec (IKEv1/2, AES-256, SHA-256, DH groups, PFS)
# con oci_core_ipsec_connection_tunnel_management, segun la politica de Movii.
