output "opnsense_primary_public_ip" {
  value = module.opnsense_primary.public_ip
}

output "opnsense_standby_public_ip" {
  value = try(module.opnsense_standby[0].public_ip, null)
}

output "oke_primary_cluster_id" {
  value = module.oke_primary.cluster_id
}

output "oke_standby_cluster_id" {
  value = try(module.oke_standby[0].cluster_id, null)
}

output "mysql_primary_db_system_id" {
  value = module.mysql_primary.db_system_id
}

output "mysql_standby_db_system_id" {
  value = try(module.mysql_standby[0].db_system_id, null)
}

output "dns_nameservers" {
  description = "Delegar estos NS desde GoDaddy hacia OCI."
  value       = module.dns_tm.nameservers
}

output "app_fqdn" {
  value = module.dns_tm.fqdn
}
