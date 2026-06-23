############################
# Availability Domains
############################
data "oci_identity_availability_domains" "primary" {
  compartment_id = var.tenancy_ocid
}

data "oci_identity_availability_domains" "standby" {
  provider       = oci.standby
  compartment_id = var.tenancy_ocid
}

############################
# IAM (dynamic groups + policies)
############################
module "iam" {
  source              = "./modules/iam"
  tenancy_ocid        = var.tenancy_ocid
  compartment_ocid    = var.compartment_ocid
  operator_group_ocid = var.operator_group_ocid
  create_policies     = var.create_iam
  project_tag         = var.project_tag
}

############################
# Red (hub-and-spoke) por región
############################
module "network_standby" {
  source    = "./modules/network"
  count     = var.deploy_standby ? 1 : 0
  providers = { oci = oci.standby }

  compartment_id = var.compartment_ocid
  label          = "standby"
  hub_cidr       = var.standby_hub_cidr
  spoke_cidr     = var.standby_spoke_cidr
  peer_cidrs     = [var.primary_hub_cidr, var.primary_spoke_cidr]
  freeform_tags  = local.freeform_tags
}

module "network_primary" {
  source = "./modules/network"

  compartment_id = var.compartment_ocid
  label          = "primary"
  hub_cidr       = var.primary_hub_cidr
  spoke_cidr     = var.primary_spoke_cidr
  peer_cidrs     = var.deploy_standby ? [var.standby_hub_cidr, var.standby_spoke_cidr] : []
  peer_rpc_id    = try(module.network_standby[0].rpc_id, "")
  peer_region    = var.deploy_standby ? var.standby_region : ""
  freeform_tags  = local.freeform_tags
}

############################
# OPNsense (firewall del hub)
############################
module "opnsense_primary" {
  source = "./modules/opnsense"

  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.primary.availability_domains[0].name
  subnet_id           = module.network_primary.hub_public_subnet_id
  image_id            = var.opnsense_image_ocid_primary
  shape               = var.opnsense_shape
  ocpus               = var.opnsense_ocpus
  memory_gb           = var.opnsense_memory_gb
  ssh_public_key      = var.ssh_public_key
  display_name        = "primary-opnsense"
  instance_state      = "RUNNING"
  freeform_tags       = local.schedulable_tags
}

module "opnsense_standby" {
  source    = "./modules/opnsense"
  count     = var.deploy_standby ? 1 : 0
  providers = { oci = oci.standby }

  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.standby.availability_domains[0].name
  subnet_id           = module.network_standby[0].hub_public_subnet_id
  image_id            = var.opnsense_image_ocid_standby
  shape               = var.opnsense_shape
  ocpus               = var.opnsense_ocpus
  memory_gb           = var.opnsense_memory_gb
  ssh_public_key      = var.ssh_public_key
  display_name        = "standby-opnsense"
  instance_state      = "STOPPED" # warm standby
  freeform_tags       = local.schedulable_tags
}

############################
# OKE
############################
module "oke_primary" {
  source = "./modules/oke"

  compartment_id      = var.compartment_ocid
  vcn_id              = module.network_primary.spoke_vcn_id
  endpoint_subnet_id  = module.network_primary.spoke_public_subnet_id
  node_subnet_id      = module.network_primary.spoke_private_subnet_id
  lb_subnet_ids       = [module.network_primary.spoke_public_subnet_id]
  availability_domain = data.oci_identity_availability_domains.primary.availability_domains[0].name
  kubernetes_version  = var.kubernetes_version
  node_shape          = var.node_shape
  node_ocpus          = var.node_ocpus
  node_memory_gb      = var.node_memory_gb
  node_count          = var.node_count_primary
  ssh_public_key      = var.ssh_public_key
  cluster_name        = "primary-oke"
  freeform_tags       = local.schedulable_tags
}

module "oke_standby" {
  source    = "./modules/oke"
  count     = var.deploy_standby ? 1 : 0
  providers = { oci = oci.standby }

  compartment_id      = var.compartment_ocid
  vcn_id              = module.network_standby[0].spoke_vcn_id
  endpoint_subnet_id  = module.network_standby[0].spoke_public_subnet_id
  node_subnet_id      = module.network_standby[0].spoke_private_subnet_id
  lb_subnet_ids       = [module.network_standby[0].spoke_public_subnet_id]
  availability_domain = data.oci_identity_availability_domains.standby.availability_domains[0].name
  kubernetes_version  = var.kubernetes_version
  node_shape          = var.node_shape
  node_ocpus          = var.node_ocpus
  node_memory_gb      = var.node_memory_gb
  node_count          = var.node_count_standby
  ssh_public_key      = var.ssh_public_key
  cluster_name        = "standby-oke"
  freeform_tags       = local.schedulable_tags
}

############################
# MySQL HeatWave
############################
module "mysql_primary" {
  source = "./modules/mysql"

  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.primary.availability_domains[0].name
  subnet_id           = module.network_primary.spoke_private_subnet_id
  shape               = var.mysql_shape
  admin_username      = var.mysql_admin_username
  admin_password      = var.mysql_admin_password
  data_storage_gb     = var.mysql_data_storage_gb
  display_name        = "primary-mysql"
  freeform_tags       = local.schedulable_tags
}

module "mysql_standby" {
  source    = "./modules/mysql"
  count     = var.deploy_standby ? 1 : 0
  providers = { oci = oci.standby }

  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.standby.availability_domains[0].name
  subnet_id           = module.network_standby[0].spoke_private_subnet_id
  shape               = var.mysql_shape
  admin_username      = var.mysql_admin_username
  admin_password      = var.mysql_admin_password
  data_storage_gb     = var.mysql_data_storage_gb
  display_name        = "standby-mysql"
  # El canal de réplica se habilita tras crear el usuario de replicación en la principal.
  enable_replication = false
  freeform_tags      = local.schedulable_tags
}

############################
# DNS + Traffic Management (global)
############################
module "dns_tm" {
  source = "./modules/dns_tm"

  compartment_id  = var.compartment_ocid
  zone_name       = var.dns_zone_name
  app_record_name = var.app_record_name
  primary_ip      = module.opnsense_primary.public_ip
  standby_ip      = try(module.opnsense_standby[0].public_ip, module.opnsense_primary.public_ip)
  freeform_tags   = local.freeform_tags
}
