output "instance_id" {
  value = oci_core_instance.opnsense.id
}

output "public_ip" {
  value = oci_core_instance.opnsense.public_ip
}

output "private_ip" {
  value = oci_core_instance.opnsense.private_ip
}
