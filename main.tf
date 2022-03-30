resource "azurerm_public_ip" "pubip" {
  name                = local.pubip_name
  resource_group_name = var.rg
  location = var.region
  allocation_method   = "Static"
}

# Create a NIC
resource "azurerm_network_interface" "nic01" {
    name = local.nic_name
    resource_group_name = var.rg
    location = var.region
    ip_configuration {
        name = local.ipconf_name
        subnet_id = var.subnet_id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.pubip.id        
    }
}

resource "azurerm_network_security_group" "nsg" {
  name                = local.nsg_name
  location                    = var.region
  resource_group_name         = var.rg

  dynamic "security_rule" {
      for_each = var.sec_rules
      content {
        name                       = security_rule.value["name"]
        priority                   = security_rule.value["priority"]
        direction                  = security_rule.value["direction"]
        access                     = security_rule.value["access"]
        protocol                   = security_rule.value["protocol"]
        source_port_range          = security_rule.value["source_port_range"]
        destination_port_range     = security_rule.value["destination_port_range"]
        source_address_prefix      = security_rule.value["source_address_prefix"]
        destination_address_prefix = security_rule.value["destination_address_prefix"]
      }
  }
}

#Nic based NSG
resource "azurerm_network_interface_security_group_association" "ngs_nic" {
  network_interface_id      = azurerm_network_interface.nic01.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

#Create the VM
resource "azurerm_virtual_machine" "vm01" {
  name = local.vm_name  
  location = var.region
  resource_group_name = var.rg
  network_interface_ids = [azurerm_network_interface.nic01.id]
  vm_size = "Standard_d2s_v5" # hardcoded - deal with it!
  
  storage_os_disk  {
    name = local.os_disk_name
    caching = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "SUSE"
    offer     = "openSUSE-Leap"
    sku       = "15-2"
    version   = "latest"
  }

  os_profile {
    admin_username = var.admin_user
    computer_name = var.hostname
    custom_data = data.template_file.cloud_init.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.admin_user}/.ssh/authorized_keys"
      key_data = var.public_key
      }    
   }
}
