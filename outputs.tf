output "vm_private_ip" {
  description = "Private ip address of the vm"
  value       = !var.is_windows ? azurerm_linux_virtual_machine.vm-linux[0].private_ip_address : azurerm_windows_virtual_machine.vm-windows[0].private_ip_address
}

output "vm_private_ips" {
  description = "Private ip addresses of the vm"
  value       = !var.is_windows ? azurerm_linux_virtual_machine.vm-linux[0].private_ip_addresses : azurerm_windows_virtual_machine.vm-windows[0].private_ip_addresses
}

output "network_interface_ids" {
  description = "Ids of the vm nics"
  value       = azurerm_network_interface.nic.*.id
}
