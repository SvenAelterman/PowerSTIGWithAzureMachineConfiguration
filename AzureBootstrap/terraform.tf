terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.30.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id     = local.subscription_id
  storage_use_azuread = true
}

data "azurerm_client_config" "current" {}
