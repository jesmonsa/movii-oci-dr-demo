# Firewall/enrutador del hub (simula el Fortinet de Movii).
# skip_source_dest_check = true permite que la instancia enrute tráfico de otras redes.
resource "oci_core_instance" "opnsense" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  display_name        = var.display_name
  shape               = var.shape
  state               = var.instance_state

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_gb
  }

  create_vnic_details {
    subnet_id              = var.subnet_id
    assign_public_ip       = true
    skip_source_dest_check = true
    display_name           = "${var.display_name}-vnic"
  }

  source_details {
    source_type = "image"
    source_id   = var.image_id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [source_details[0].source_id]
  }
}
