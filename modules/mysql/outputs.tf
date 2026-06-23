output "db_system_id" {
  value = oci_mysql_mysql_db_system.this.id
}

output "endpoints" {
  description = "Endpoints del DB System (hostname/IP del MySQL)."
  value       = oci_mysql_mysql_db_system.this.endpoints
}
