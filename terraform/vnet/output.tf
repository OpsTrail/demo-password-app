output "vnet-id" {
  value = azurerm_virtual_network.aks-vnet.id
}

output "subnet-id" {
  value = azurerm_subnet.aks-subnet.id
}