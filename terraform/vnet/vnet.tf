resource "azurerm_virtual_network" "aks-vnet" {
  name                = "${var.vnet-name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.rg-name
}

resource "azurerm_subnet" "aks-subnet" {
  name                 = "${var.subnet-name}-subnet"
  resource_group_name  = var.rg-name
  virtual_network_name = azurerm_virtual_network.aks-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}