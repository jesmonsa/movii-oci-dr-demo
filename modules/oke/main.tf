data "oci_containerengine_node_pool_option" "this" {
  node_pool_option_id = "all"
  compartment_id      = var.compartment_id
}

locals {
  # Selecciona una imagen Oracle Linux 8 si no se pasa node_image_id.
  autodetected_images = [
    for s in data.oci_containerengine_node_pool_option.this.sources : s.image_id
    if can(regex("Oracle-Linux-8", s.source_name)) && !can(regex("GPU", s.source_name))
  ]
  node_image_id = var.node_image_id != "" ? var.node_image_id : (length(local.autodetected_images) > 0 ? local.autodetected_images[0] : "")
}

resource "oci_containerengine_cluster" "this" {
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = var.cluster_name
  vcn_id             = var.vcn_id
  type               = "BASIC_CLUSTER"

  endpoint_config {
    subnet_id            = var.endpoint_subnet_id
    is_public_ip_enabled = true
  }

  options {
    service_lb_subnet_ids = var.lb_subnet_ids
  }

  freeform_tags = var.freeform_tags
}

resource "oci_containerengine_node_pool" "this" {
  cluster_id         = oci_containerengine_cluster.this.id
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = "${var.cluster_name}-np"
  node_shape         = var.node_shape
  ssh_public_key     = var.ssh_public_key

  node_shape_config {
    ocpus         = var.node_ocpus
    memory_in_gbs = var.node_memory_gb
  }

  node_config_details {
    size = var.node_count
    placement_configs {
      availability_domain = var.availability_domain
      subnet_id           = var.node_subnet_id
    }
  }

  node_source_details {
    source_type             = "IMAGE"
    image_id                = local.node_image_id
    boot_volume_size_in_gbs = 50
  }

  freeform_tags = var.freeform_tags
}
