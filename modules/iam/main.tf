# Grupo dinámico de instancias (principals de instancia: agentes/Ansible/automatización).
resource "oci_identity_dynamic_group" "instances" {
  count          = var.create_policies ? 1 : 0
  compartment_id = var.tenancy_ocid
  name           = "${var.project_tag}-instances-dg"
  description    = "Instancias del demo DR Movii"
  matching_rule  = "ALL {instance.compartment.id = '${var.compartment_ocid}'}"
}

# Grupo dinámico para Functions (p. ej. la función de apagado horario).
resource "oci_identity_dynamic_group" "functions" {
  count          = var.create_policies ? 1 : 0
  compartment_id = var.tenancy_ocid
  name           = "${var.project_tag}-fn-dg"
  description    = "Functions del demo DR Movii"
  matching_rule  = "ALL {resource.type = 'fnfunc', resource.compartment.id = '${var.compartment_ocid}'}"
}

# Permisos para el grupo operador (quien corre Terraform), si se provee su OCID.
resource "oci_identity_policy" "operator" {
  count          = var.create_policies && var.operator_group_ocid != "" ? 1 : 0
  compartment_id = var.compartment_ocid
  name           = "${var.project_tag}-operator-policy"
  description    = "Permisos para desplegar la demo DR (MySQL, OKE, red, DNS, FSDR)."
  statements = [
    "Allow group id ${var.operator_group_ocid} to manage mysql-family in compartment id ${var.compartment_ocid}",
    "Allow group id ${var.operator_group_ocid} to manage cluster-family in compartment id ${var.compartment_ocid}",
    "Allow group id ${var.operator_group_ocid} to manage instance-family in compartment id ${var.compartment_ocid}",
    "Allow group id ${var.operator_group_ocid} to manage volume-family in compartment id ${var.compartment_ocid}",
    "Allow group id ${var.operator_group_ocid} to manage virtual-network-family in compartment id ${var.compartment_ocid}",
    "Allow group id ${var.operator_group_ocid} to manage dns in compartment id ${var.compartment_ocid}",
    "Allow group id ${var.operator_group_ocid} to manage health-checks in compartment id ${var.compartment_ocid}",
    "Allow group id ${var.operator_group_ocid} to manage load-balancers in compartment id ${var.compartment_ocid}",
    "Allow group id ${var.operator_group_ocid} to manage disaster-recovery-family in compartment id ${var.compartment_ocid}",
    "Allow group id ${var.operator_group_ocid} to manage resource-schedule-family in compartment id ${var.compartment_ocid}",
    "Allow group id ${var.operator_group_ocid} to manage functions-family in compartment id ${var.compartment_ocid}",
    "Allow group id ${var.operator_group_ocid} to read all-resources in compartment id ${var.compartment_ocid}",
  ]
}

# Permisos de SERVICIO + grupos dinámicos (OKE, FSDR, Resource Scheduler, MySQL/Functions).
resource "oci_identity_policy" "services" {
  count          = var.create_policies ? 1 : 0
  compartment_id = var.compartment_ocid
  name           = "${var.project_tag}-service-policy"
  description    = "Permisos de servicio para OKE, FSDR, Resource Scheduler y MySQL."
  statements = [
    # OKE gestiona los recursos del cluster
    "Allow service OKE to manage all-resources in compartment id ${var.compartment_ocid}",
    # Full Stack Disaster Recovery
    "Allow service disaster-recovery to manage all-resources in compartment id ${var.compartment_ocid}",
    # Resource Scheduler: apagar/encender compute y MySQL (principal de servicio)
    "Allow any-user to manage instances in compartment id ${var.compartment_ocid} where all {request.principal.type = 'resourceschedule'}",
    "Allow any-user to manage mysql-family in compartment id ${var.compartment_ocid} where all {request.principal.type = 'resourceschedule'}",
    # Función de apagado (grupo dinámico de Functions)
    "Allow dynamic-group ${var.project_tag}-fn-dg to manage instances in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${var.project_tag}-fn-dg to manage mysql-family in compartment id ${var.compartment_ocid}",
    # Instancias pueden usar MySQL / leer red (para integraciones)
    "Allow dynamic-group ${var.project_tag}-instances-dg to use mysql-family in compartment id ${var.compartment_ocid}",
  ]
  depends_on = [oci_identity_dynamic_group.instances, oci_identity_dynamic_group.functions]
}

# TODO(tenancy): si MySQL usa llaves gestionadas en Vault, agregar:
#   Allow service mysql to use keys in compartment id <c>
# y el grupo dinámico/política correspondiente para el Vault.
