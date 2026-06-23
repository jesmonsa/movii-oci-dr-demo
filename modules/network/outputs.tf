output "hub_vcn_id" {
  value = oci_core_vcn.hub.id
}

output "spoke_vcn_id" {
  value = oci_core_vcn.spoke.id
}

output "hub_public_subnet_id" {
  value = oci_core_subnet.hub_public.id
}

output "spoke_public_subnet_id" {
  value = oci_core_subnet.spoke_public.id
}

output "spoke_private_subnet_id" {
  value = oci_core_subnet.spoke_private.id
}

output "drg_id" {
  value = oci_core_drg.this.id
}

output "rpc_id" {
  value = oci_core_remote_peering_connection.this.id
}

output "spoke_cidr" {
  value = var.spoke_cidr
}

output "hub_cidr" {
  value = var.hub_cidr
}
