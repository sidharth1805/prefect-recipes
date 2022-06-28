
# module "keyvault_deploy" {
#   source = "./modules/keyvault_deploy"

# }

module "vm_deploy" {
  source = "./modules/vm_deploy"
  rg = azurerm_resource_group.rg
  publicnic = azurerm_network_interface.publicnic

  prefect_url = var.prefect_url
  api_key = var.api_key
}