output "public_ip" {
    description = "The public IP address"
    value = azurerm_public_ip.pubip.ip_address  
}