# The module creates a number of resources.  The names of the resourse use the following naming convention <project_namespace>-<resource_suffix> for example ss-tf-test-vm in the casr that multiple resources are created numbering will be appended to the suffix

variable "project_namespace" {
    description = "Primary naming convention rule"
    type = string
    default = "tf-module-testing"  
}

#Required
variable "rg" { 
    description = "The resource group name that will hold the resources"
    type = string  
}

#Required
variable "region" {
    description = "The region the created resources should be created in"
    type = string  
}

#Required
variable  "subnet_id" {
    description = "The ID of the subnet that the VM's Nic will attached to"
    type = string
}

variable "hostname" {
    description = "The hostname of the VM"
    type = string
    default = "vm01"
}

#Required
variable "admin_user" {
    description = "The name of the admin user"
    type = string     
}

#Required
variable "public_key" {
    description = "The public ssh key for the admin user"
    type = string
  
}

#Required
variable "cloud_init_path" {
    description = "cloud-init file path"
    type = string  
}

locals {
    pubip_name = "${var.project_namespace}-pub_ip"
    nic_name = "${var.project_namespace}-nic"
    ipconf_name = "${var.project_namespace}-ipconf"
    vm_name = "${var.project_namespace}-vm"
    os_disk_name = "${var.project_namespace}-os_disk"
    nsg_name = "${var.project_namespace}-nsg"

}

variable "sec_rules" {
  description = "NSG security rules"
  type = list(object({
    name = string
    priority = number
    direction = string
    access = string
    protocol = string
    source_port_range = string
    destination_port_range = string
    source_address_prefix = string
    destination_address_prefix= string
  }))
  default = [{
    name                       = "AllowSsh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "BadWebServer"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }]
  
}