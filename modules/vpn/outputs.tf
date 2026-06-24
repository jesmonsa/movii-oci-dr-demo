output "cpe_id" {
  value = oci_core_cpe.this.id
}

output "ipsec_id" {
  value = oci_core_ipsec.this.id
}

output "tunnels" {
  description = "Tuneles IPSec (estado e IPs de Oracle para configurar el on-premises)."
  value       = data.oci_core_ipsec_connection_tunnels.this.ip_sec_connection_tunnels
}
