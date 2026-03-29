resource "azurerm_resource_group" "password-app-rg" {
  name = "${var.rg-name}-rg"
  location = var.location
}