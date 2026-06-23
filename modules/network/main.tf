# Servicios para el Service Gateway (acceso privado a servicios de Oracle).
data "oci_core_services" "all" {}

#####################
# HUB VCN (OPNsense)
#####################
resource "oci_core_vcn" "hub" {
  compartment_id = var.compartment_id
  cidr_blocks    = [var.hub_cidr]
  display_name   = "${var.label}-hub-vcn"
  dns_label      = "${var.label}hub"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_internet_gateway" "hub_igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.hub.id
  display_name   = "${var.label}-hub-igw"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_nat_gateway" "hub_nat" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.hub.id
  display_name   = "${var.label}-hub-nat"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_service_gateway" "hub_sgw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.hub.id
  display_name   = "${var.label}-hub-sgw"
  services {
    service_id = data.oci_core_services.all.services[0]["id"]
  }
  freeform_tags = var.freeform_tags
}

#####################
# SPOKE VCN (apps)
#####################
resource "oci_core_vcn" "spoke" {
  compartment_id = var.compartment_id
  cidr_blocks    = [var.spoke_cidr]
  display_name   = "${var.label}-spoke-vcn"
  dns_label      = "${var.label}spoke"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_internet_gateway" "spoke_igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.spoke.id
  display_name   = "${var.label}-spoke-igw"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_nat_gateway" "spoke_nat" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.spoke.id
  display_name   = "${var.label}-spoke-nat"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_service_gateway" "spoke_sgw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.spoke.id
  display_name   = "${var.label}-spoke-sgw"
  services {
    service_id = data.oci_core_services.all.services[0]["id"]
  }
  freeform_tags = var.freeform_tags
}

#####################
# DRG + attachments + RPC
#####################
resource "oci_core_drg" "this" {
  compartment_id = var.compartment_id
  display_name   = "${var.label}-drg"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_drg_attachment" "hub" {
  drg_id       = oci_core_drg.this.id
  vcn_id       = oci_core_vcn.hub.id
  display_name = "${var.label}-hub-att"
}

resource "oci_core_drg_attachment" "spoke" {
  drg_id       = oci_core_drg.this.id
  vcn_id       = oci_core_vcn.spoke.id
  display_name = "${var.label}-spoke-att"
}

resource "oci_core_remote_peering_connection" "this" {
  compartment_id   = var.compartment_id
  drg_id           = oci_core_drg.this.id
  display_name     = "${var.label}-rpc"
  peer_id          = var.peer_rpc_id != "" ? var.peer_rpc_id : null
  peer_region_name = var.peer_region != "" ? var.peer_region : null
  freeform_tags    = var.freeform_tags
}

#####################
# Route tables
#####################
resource "oci_core_route_table" "hub_public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.hub.id
  display_name   = "${var.label}-hub-public-rt"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.hub_igw.id
  }
  freeform_tags = var.freeform_tags
}

resource "oci_core_route_table" "spoke_public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.spoke.id
  display_name   = "${var.label}-spoke-public-rt"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.spoke_igw.id
  }
  dynamic "route_rules" {
    for_each = var.peer_cidrs
    content {
      destination       = route_rules.value
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_drg.this.id
    }
  }
  freeform_tags = var.freeform_tags
}

resource "oci_core_route_table" "spoke_private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.spoke.id
  display_name   = "${var.label}-spoke-private-rt"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.spoke_nat.id
  }
  route_rules {
    destination       = data.oci_core_services.all.services[0]["cidr_block"]
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.spoke_sgw.id
  }
  dynamic "route_rules" {
    for_each = var.peer_cidrs
    content {
      destination       = route_rules.value
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_drg.this.id
    }
  }
  freeform_tags = var.freeform_tags
}

#####################
# Security lists (demo, permisivas dentro de la VCN)
#####################
resource "oci_core_security_list" "common" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.spoke.id
  display_name   = "${var.label}-spoke-sl"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  # SSH
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }
  # HTTP/HTTPS (app)
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }
  # MySQL dentro de redes privadas (ajustar en producción)
  ingress_security_rules {
    protocol = "6"
    source   = "10.0.0.0/8"
    tcp_options {
      min = 3306
      max = 3306
    }
  }
  ingress_security_rules {
    protocol = "6"
    source   = "10.0.0.0/8"
    tcp_options {
      min = 33060
      max = 33060
    }
  }
  freeform_tags = var.freeform_tags
}

resource "oci_core_security_list" "hub" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.hub.id
  display_name   = "${var.label}-hub-sl"
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  ingress_security_rules {
    protocol = "all"
    source   = "10.0.0.0/8"
  }
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }
  freeform_tags = var.freeform_tags
}

#####################
# Subnets
#####################
resource "oci_core_subnet" "hub_public" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.hub.id
  cidr_block                 = cidrsubnet(var.hub_cidr, 1, 0)
  display_name               = "${var.label}-hub-public"
  dns_label                  = "pub"
  route_table_id             = oci_core_route_table.hub_public.id
  security_list_ids          = [oci_core_security_list.hub.id]
  prohibit_public_ip_on_vnic = false
  freeform_tags              = var.freeform_tags
}

resource "oci_core_subnet" "spoke_public" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.spoke.id
  cidr_block                 = cidrsubnet(var.spoke_cidr, 1, 1)
  display_name               = "${var.label}-spoke-public"
  dns_label                  = "pubapp"
  route_table_id             = oci_core_route_table.spoke_public.id
  security_list_ids          = [oci_core_security_list.common.id]
  prohibit_public_ip_on_vnic = false
  freeform_tags              = var.freeform_tags
}

resource "oci_core_subnet" "spoke_private" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.spoke.id
  cidr_block                 = cidrsubnet(var.spoke_cidr, 1, 0)
  display_name               = "${var.label}-spoke-private"
  dns_label                  = "priv"
  route_table_id             = oci_core_route_table.spoke_private.id
  security_list_ids          = [oci_core_security_list.common.id]
  prohibit_public_ip_on_vnic = true
  freeform_tags              = var.freeform_tags
}
