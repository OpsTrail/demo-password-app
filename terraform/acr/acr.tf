resource "azurerm_container_registry" "password-app-acr" {
  name                = "${var.acr-name}"
  resource_group_name = var.rg-name
  location            = var.location
  sku                 = "Basic"
}