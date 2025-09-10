resource "azurerm_resource_group" "bootstrap" {
  name     = replace(local.naming_structure, "{resourceType}", "rg")
  location = var.location
}