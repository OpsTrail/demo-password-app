resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.name}-aks"
  location            = var.location
  resource_group_name = var.rg-name
  dns_prefix          = "passwordapp"

  default_node_pool {
    name                 = "default"
    vm_size              = "Standard_DS2_v2"
    vnet_subnet_id       = var.subnet-id
    auto_scaling_enabled = true
    min_count            = 1
    max_count            = 2
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin  = "azure"
    network_policy  = "calico"

  service_cidr   = "10.2.0.0/16"
  dns_service_ip = "10.2.0.10"
 }
}