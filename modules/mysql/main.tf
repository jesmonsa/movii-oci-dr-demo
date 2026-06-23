# DB System MySQL HeatWave (sin nodo analítico para ahorrar en el trial).
resource "oci_mysql_mysql_db_system" "this" {
  compartment_id          = var.compartment_id
  availability_domain     = var.availability_domain
  shape_name              = var.shape
  subnet_id               = var.subnet_id
  admin_username          = var.admin_username
  admin_password          = var.admin_password
  data_storage_size_in_gb = var.data_storage_gb
  display_name            = var.display_name
  is_highly_available     = false
  freeform_tags           = var.freeform_tags
}

# Canal de réplica entrante (inbound) hacia este DB System (la réplica RO).
# TODO(tenancy): crear primero un usuario de replicación en la principal y pasar
# source_hostname/username/password. Ver scripts/mysql_replication.md
resource "oci_mysql_channel" "replica" {
  count          = var.enable_replication ? 1 : 0
  compartment_id = var.compartment_id
  is_enabled     = true
  display_name   = "${var.display_name}-repl"

  source {
    source_type = "MYSQL"
    hostname    = var.source_hostname
    port        = 3306
    username    = var.source_username
    password    = var.source_password
    ssl_mode    = "REQUIRED"
  }

  target {
    target_type  = "DBSYSTEM"
    db_system_id = oci_mysql_mysql_db_system.this.id
    channel_name = "repl"
  }

  freeform_tags = var.freeform_tags
}
