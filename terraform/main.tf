module "resource-group" {
    source = "./resource-group"
    rg-name = var.name
    location = var.location
}

module "acr" {
  source = "./acr"
  rg-name = module.resource-group.rgname
  location = var.location
  acr-name = var.name
}

module "vnet" {
  source = "./vnet"
  rg-name = module.resource-group.rgname
  location = var.location
  subnet-name = var.name
  vnet-name = var.name
}

module "aks" {
  source = "./aks"
  name = var.name
  location = var.location
  rg-name = module.resource-group.rgname
  subnet-id = module.vnet.subnet-id
}
