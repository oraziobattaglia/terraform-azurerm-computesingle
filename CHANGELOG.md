## v0.1.3

Fixes:

 - Changed param names to be compatible with azure provider 4.x.x

## v0.1.2

Features:

  - Added nic ids as output

## v0.1.1

Features:

  - Added optional names for nic, ip_configuration and data disk objects

Fixes:

  - Fixed some objects names

## v0.1.0

Features:

  - Deploy 1 linux vm or windows vm based on var.is_windows value
  - For the vm add n nic with n ip_configuration blocks
  - It's possible to add n data disk based on data_disks list
  - It's possible to attach to one nic n application security groups.
  - Vm may be backed up with the resource azurerm_backup_protected_vm
  - Linux vm support a custom script extension to run a bash script after the deploy
  - Windows vm support 2 custom script:
    - To run a powershell script after the deploy
    - To join the vm to an Active Directory domain

Limits:

  - Deploy only 1 vm