# This module is used to create 1 vm with n data disks and m nic.

# Network interfaces
resource "azurerm_network_interface" "nic" {
  count                          = length(var.nics)
  name                           = coalesce(var.nics[count.index].name,"${var.virtual_machine_name}-nic-${count.index}")
  location                       = var.location
  resource_group_name            = var.resource_group
  ip_forwarding_enabled          = var.nics[count.index].enable_ip_forwarding
  accelerated_networking_enabled = var.nics[count.index].enable_accelerated_networking

  dynamic ip_configuration {
    for_each = var.nics[count.index].ip_configurations

    content { 
      name                          = coalesce(ip_configuration.value["name"],"${var.virtual_machine_name}-ip-${count.index}")
      subnet_id                     = ip_configuration.value["subnet_id"]
      private_ip_address_allocation = ip_configuration.value["private_ip_address_allocation"]
      private_ip_address            = ip_configuration.value["private_ip_address"]
      public_ip_address_id          = ip_configuration.value["public_ip_address_id"]
      primary                       = ip_configuration.value["primary"]
    } # end content

  } # end dynamic

  tags = var.tags
} # end nics

# Association nic to asg ids
resource "azurerm_network_interface_application_security_group_association" "nic2asg" {
  count                         = length(var.application_security_group_ids) > 0 ? length(var.application_security_group_ids) : 0
  network_interface_id          = azurerm_network_interface.nic[var.nic_to_assign_asgs].id
  application_security_group_id = var.application_security_group_ids[count.index]
}

# Virtual machine Linux
resource "azurerm_linux_virtual_machine" "vm-linux" {
  count                 = !var.is_windows ? 1 : 0
  name                  = "${var.virtual_machine_name}-vm"
  location              = var.location
  resource_group_name   = var.resource_group
  availability_set_id   = var.availability_set_enabled ? var.availability_set_id : null
  network_interface_ids = azurerm_network_interface.nic.*.id
  size                  = var.vm_size

  source_image_reference {
    publisher = var.vm_os_publisher
    offer     = var.vm_os_offer
    sku       = var.vm_os_sku
    version   = var.vm_os_version
  }
  
  os_disk {
    name                 = "${var.virtual_machine_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = var.storage_account_type
  }
  
  computer_name  = var.virtual_machine_name

  disable_password_authentication = false
  admin_username = var.admin_username
  admin_password = var.admin_password

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics ? var.storage_account_boot_diagnostics : ""
  }
  
  tags = var.tags
}

# Virtual machine Windows
resource "azurerm_windows_virtual_machine" "vm-windows" {
  count                 = var.is_windows ? 1 : 0
  name                  = "${var.virtual_machine_name}-vm"
  location              = var.location
  resource_group_name   = var.resource_group
  availability_set_id   = var.availability_set_enabled ? var.availability_set_id : null
  network_interface_ids = azurerm_network_interface.nic.*.id
  size                  = var.vm_size
  license_type          = var.license_type

  source_image_reference {
    publisher = var.vm_os_publisher
    offer     = var.vm_os_offer
    sku       = var.vm_os_sku
    version   = var.vm_os_version
  }

  os_disk {
    name                 = "${var.virtual_machine_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = var.storage_account_type
  }

  computer_name  = var.virtual_machine_name

  admin_username = var.admin_username
  admin_password = var.admin_password

  provision_vm_agent = true

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics ? var.storage_account_boot_diagnostics : ""
  }

  tags = var.tags
}

# Create optional data disks
resource "azurerm_managed_disk" "vm-data-disk" {
  count                = length(var.data_disks) > 0 ? length(var.data_disks) : 0

  name                 = coalesce(var.data_disks[count.index]["name"],"${var.virtual_machine_name}-datadisk-${count.index}")
  location             = var.location
  resource_group_name  = var.resource_group
  storage_account_type = var.data_disks[count.index]["data_disk_sa_type"]
  create_option        = "Empty"
  disk_size_gb         = var.data_disks[count.index]["data_disk_size_gb"]

  tags = var.tags
}

# Data disk association

# Linux
resource "azurerm_virtual_machine_data_disk_attachment" "data-disk2vm-linux" {
  count = (length(var.data_disks) > 0) && !var.is_windows ? length(var.data_disks) : 0
  managed_disk_id = azurerm_managed_disk.vm-data-disk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm-linux[0].id
  lun     = var.data_disks[count.index]["data_disk_lun"]
  caching = var.data_disks[count.index]["data_disk_caching"]
}

# Windows
resource "azurerm_virtual_machine_data_disk_attachment" "data-disk2vm-windows" {
  count = (length(var.data_disks) > 0) && var.is_windows ? length(var.data_disks) : 0
  managed_disk_id = azurerm_managed_disk.vm-data-disk[count.index].id
  virtual_machine_id = azurerm_windows_virtual_machine.vm-windows[0].id
  lun     = var.data_disks[count.index]["data_disk_lun"]
  caching = var.data_disks[count.index]["data_disk_caching"]
}

# JsonADDomainExtension extension
resource "azurerm_virtual_machine_extension" "vm-windows-joinext" {
  count               = var.join && var.is_windows ? 1 : 0
  name                = "${var.virtual_machine_name}-joinext"
  virtual_machine_id  = azurerm_windows_virtual_machine.vm-windows[0].id

  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  settings = <<SETTINGS
    {
      "Name": "${var.windows_domain_name}",
      "User": "${var.windows_domain_username}",
      "Restart": "false",
      "Options": "3"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "Password": "${var.windows_domain_password}"
    }
  PROTECTED_SETTINGS

  tags = var.tags
}

# Custom script extension
resource "azurerm_virtual_machine_extension" "vm-windows-cse" {
  count               = var.customize && var.is_windows ? 1 : 0
  name                = "${var.virtual_machine_name}-cse"
  virtual_machine_id  = azurerm_windows_virtual_machine.vm-windows[0].id

  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
      {
        "fileUris": [
              "${var.windows_cs_file_uri}"
            ],
        "commandToExecute": "${var.windows_cs_command}"
      }
  SETTINGS

  tags = var.tags
}

resource "azurerm_virtual_machine_extension" "vm-linux-cse" {
  count              = var.customize && !var.is_windows ? 1 : 0
  name               = "${var.virtual_machine_name}-cse"
  virtual_machine_id = azurerm_linux_virtual_machine.vm-linux[0].id

  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
      {
        "fileUris": [
              "${var.linux_cs_file_uri}"
            ],
        "commandToExecute": "${var.linux_cs_command}"
      }
  SETTINGS

  tags = var.tags
}
# End Custom script extension

# Backup policy for the virtual machine
resource "azurerm_backup_protected_vm" "rs-protected-vm" {
  count               = var.backup_enabled ? 1 : 0
  resource_group_name = var.recovery_vault_resource_group
  recovery_vault_name = var.recovery_vault_name
  source_vm_id = var.is_windows ? azurerm_windows_virtual_machine.vm-windows[0].id : azurerm_linux_virtual_machine.vm-linux[0].id
  backup_policy_id = var.backup_policy_id
  
  # TO TRY! It's seem tags don't work on this resource
  # tags = "${var.tags}"
}
