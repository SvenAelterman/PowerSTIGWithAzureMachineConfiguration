module "id" {
  source           = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version          = "~> 0.3.3"
  enable_telemetry = var.enable_telemetry

  name                = replace(local.naming_structure, "{resourceType}", "id")
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

// HACK: Wait 30 seconds after the user-assigned managed identity is created
// before assigning it the Key Vault Secrets User role on the shared Key Vault.
resource "time_sleep" "wait_30_seconds" {
  create_duration = "30s"
  depends_on      = [module.id]
}

module "id_storage_role_assignment" {
  source           = "Azure/avm-res-authorization-roleassignment/azurerm"
  version          = "~> 0.2.0"
  enable_telemetry = var.enable_telemetry

  role_assignments_for_scopes = {
    storage = {
      scope = module.storage.resource.id
      role_assignments = {
        reader = {
          role_definition                  = "reader"
          user_assigned_managed_identities = ["id"]
          principal_type                   = "ServicePrincipal"
        }
        storageBlobDataContributor = {
          role_definition                  = "storageBlobDataContributor"
          user_assigned_managed_identities = ["id"]
          principal_type                   = "ServicePrincipal"
        }
      }
    }
  }

  user_assigned_managed_identities_by_principal_id = { id = module.id.resource.principal_id }

  role_definitions = {
    reader = {
      name = "Reader"
    }
    storageBlobDataContributor = {
      name = "STORAGE Blob Data Contributor"
    }
  }

  depends_on = [module.id, time_sleep.wait_30_seconds]
}
