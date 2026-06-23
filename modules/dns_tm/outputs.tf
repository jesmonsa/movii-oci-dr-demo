output "zone_id" {
  value = oci_dns_zone.this.id
}

output "nameservers" {
  description = "NS de OCI para delegar el dominio desde GoDaddy."
  value       = oci_dns_zone.this.nameservers
}

output "steering_policy_id" {
  value = oci_dns_steering_policy.this.id
}

output "fqdn" {
  value = "${var.app_record_name}.${var.zone_name}"
}
