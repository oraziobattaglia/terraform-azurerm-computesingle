variable "location" {
  type        = string
  description = "Object location"
}

variable "resource_group" {
  type        = string
  description = "Object resource group"
}

variable "virtual_machine_name" {
  type        = string
  description = "Azure Virtual Machine Names"
}

variable "nic_to_assign_asgs" {
  type = number
  description = "Nic to attach ASGs to, 0 for the first nic, 1 for the second nic and so on"
  default     = 0
}

variable "application_security_group_ids" {
  type        = list(string)
  description = "Application Security Group Ids to associate to nic"
  default     = []
}

variable "is_windows" {
  type        = bool
  description = "True for a Windows virtual machine"
}

variable "vm_size" {
  type        = string
  description = "Virtual machine size"
}

variable "license_type" {
  type        = string
  description = "Specifies the BYOL Type for this Virtual Machine"
  default     = "Windows_Server"
}

variable "vm_os_publisher" {
  type        = string
  description = "Vm os publisher"
}

variable "vm_os_offer" {
  type        = string
  description = "Vm os offer"
}

variable "vm_os_sku" {
  type        = string
  description = "Vm os sku"
}

variable "vm_os_version" {
  type        = string
  description = "Vm os version"
  default     = "latest"
}

variable "nics" {
  type = list(object({
    name                          = string
    enable_ip_forwarding          = bool
    enable_accelerated_networking = bool
    
    ip_configurations = list(object({
      name                          = string
      subnet_id                     = string
      private_ip_address_allocation = string
      public_ip_address_id          = string
      private_ip_address            = string
      primary                       = bool
    }))

  }))
  description = "List of nic objects"
}

variable "storage_account_type" {
  type        = string
  description = "Storage account type"
  default     = "Standard_LRS"
}

variable "use_custom_os_disk_size" {
  type        = bool
  description = "True to specify custom os data size"
  default     = false
}

variable "os_disk_size_gb" {
  type        = number
  description = "Storage os disk size"
  default     = 50
}

variable "data_disks" {
  type = list(object({
    name              = string
    data_disk_sa_type = string
    data_disk_caching = string
    data_disk_size_gb = number
    data_disk_lun     = number
  }))
  description = "List of data disk objects"
  default = []
}

variable "admin_username" {
  type        = string
  description = "Admin username"
}

variable "admin_password" {
  type        = string
  description = "Admin password"
}

variable "boot_diagnostics" {
  type        = bool
  description = "Boot diagnostics"
  default     = false
}

variable "storage_account_boot_diagnostics" {
  type        = string
  description = "Storage account boot diagnostics"
  default     = ""
}

variable "tags" {
  type        = any
  description = "Tags"
  default     = {}
}

# Backup variables
variable "backup_enabled" {
  type        = bool
  description = "True to set up backup configuration"
  default     = false
}

variable "recovery_vault_name" {
  type        = string
  description = "Recovery vault name"
  default     = ""
}

variable "recovery_vault_resource_group" {
  type        = string
  description = "Recovery vault resource group"
  default     = ""
}

variable "backup_policy_id" {
  type        = string
  description = "Backup policy id"
  default     = ""
}

# Availability_set variables
variable "availability_set_enabled" {
  type        = bool
  description = "True to enable availability set"
  default     = false
}

variable "availability_set_id" {
  type        = string
  description = "Id of the availability set"
  default     = ""
}

# JsonADDomainExtension extension variables
variable "join" {
  type        = bool
  description = "True to join vm to domain"
  default     = false
}

variable "windows_domain_name" {
  type        = string
  description = "Name of the windows domain to join to"
  default     = ""
}

variable "windows_domain_username" {
  type        = string
  description = "Name of the user with domain join permission"
  default     = ""
}

variable "windows_domain_password" {
  type        = string
  description = "Password for the user with domain join permission"
  default = ""
}

# Customization variables
variable "customize" {
  type        = bool
  description = "True to run customization script"
  default     = false
}

# Windows custom script extension variables
variable "windows_cs_file_uri" {
  type        = string
  description = "Windows custom script file URI"
  default     = ""
}

variable "windows_cs_command" {
  type        = string
  description = "Windows custom script command to execute"
  default     = "powershell -ExecutionPolicy Unrestricted -File customize_windows.ps1"
}

# Linux custom script extension variables
variable "linux_cs_file_uri" {
  type        = string
  description = "Linux custom script file URI"
  default     = ""
}

variable "linux_cs_command" {
  type        = string
  description = "Linux custom script command to execute"
  default     = "bash customize_linux.bash"
}
