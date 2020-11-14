# terraform-azurerm-computesingle

## Deploys 1 vm, linux or windows

This Terraform module deploys 1 Virtual Machines in Azure, ideas from official module.

Deploys:
 - 1 linux vm or windows vm based on var.is_windows value
 - for the vm add n nic with n ip_configuration blocks
 - it's possible to add n data disk based on data_disks list
 - it's possible to attach to one nic n application security groups.
 - vm may be backed up with the resource azurerm_backup_protected_vm
 - linux vm support a custom script extension to run a bash script after the deploy
 - windows vm support 2 custom script:
   - to run a powershell script after the deploy
   - to join the vm to an Active Directory domain

## Examples

```hcl

module "my_module" {
  source = "oraziobattaglia/computesingle/azurerm"

  location                        = var.my_location
  resource_group                  = azurerm_resource_group.my_rg.name
  virtual_machine_name            = "my_vm"

  is_windows           = false

  vm_size              = "Standard_B1ms"
  storage_account_type = "Premium_LRS"
  vm_os_publisher      = "canonical"
  vm_os_offer          = "0001-com-ubuntu-server-focal"
  vm_os_sku            = "20_04-lts-gen2"
  vm_os_version        = "latest"

  admin_username       = "adminvm"
  admin_password       = data.azurerm_key_vault_secret.my_password.value

  availability_set_enabled = true
  availability_set_id      = azurerm_availability_set.my_avset.id

  # Network interfaces
  nics = [
      { 
          enable_ip_forwarding = false
          enable_accelerated_networking = false

          ip_configurations = [
              {
                  name = "ip-conf-1"
                  subnet_id = azurerm_subnet.my_subnet.id
                  private_ip_address_allocation = "Dynamic"
                  public_ip_address_id          = ""
                  private_ip_address            = ""
                  primary                       = true
              },
              {
                  name = "ip-conf-2"
                  subnet_id = azurerm_subnet.my_subnet.id
                  private_ip_address_allocation = "Static"
                  public_ip_address_id          = ""
                  private_ip_address            = "10.10.10.1"
                  primary                       = false
              }
          ]
      },
      { 
          enable_ip_forwarding = false
          enable_accelerated_networking = false

          ip_configurations = [
              {
                  name = "ip-conf-1"
                  subnet_id = azurerm_subnet.my_subnet2.id
                  private_ip_address_allocation = "Static"
                  public_ip_address_id          = ""
                  private_ip_address            = "10.10.11.1"
                  primary                       = true
              }
          ]
      }
  ]

  application_security_group_ids = [azurerm_application_security_group.my1-asg.id, azurerm_application_security_group.my2-asg.id]

  data_disks = [
    {
        data_disk_sa_type = "StandardSSD_LRS"
        data_disk_caching = "None"
        data_disk_size_gb = 5
        data_disk_lun     = 0
    },
    {
        data_disk_sa_type = "Standard_LRS"
        data_disk_caching = "None"
        data_disk_size_gb = 10
        data_disk_lun     = 1
    }
  ]

  # Boot diagnostics
  boot_diagnostics                 = true
  storage_account_boot_diagnostics = azurerm_storage_account.mystorage1.primary_blob_endpoint

  # Backup variables
  backup_enabled = true
  recovery_vault_name           = azurerm_recovery_services_vault.my_vlt.name
  recovery_vault_resource_group = azurerm_resource_group.my_backup-rg.name
  backup_policy_id              = azurerm_backup_policy_vm.my_policy.id

  customize = true
  linux_cs_file_uri = local.linux_cs_file_uri  
}

```
