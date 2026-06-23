output "instances_dynamic_group" {
  value = try(oci_identity_dynamic_group.instances[0].name, null)
}

output "functions_dynamic_group" {
  value = try(oci_identity_dynamic_group.functions[0].name, null)
}
