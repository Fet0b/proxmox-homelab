output "vmid" {
  value = proxmox_virtual_environment_container.ubuntu.vm_id
}

output "root_password" {
  value     = random_password.root.result
  sensitive = true
}
