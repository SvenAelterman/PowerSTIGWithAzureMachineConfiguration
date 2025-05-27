# Create a storage account to hold the Azure policy package files

module "storage" {
  source           = "Azure/avm-res-storage-storageaccount/azurerm"
  version          = "~> 0.5.0"
  enable_telemetry = var.enable_telemetry

  name                = lower(replace(replace(local.naming_structure, "{resourceType}", "st"), "-", ""))
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  default_to_oauth_authentication   = true
  infrastructure_encryption_enabled = true
  large_file_share_enabled          = true
  public_network_access_enabled     = true

  shared_access_key_enabled = false

  network_rules = {
    bypass         = ["AzureServices"]
    default_action = "Deny"
    ip_rules       = [data.http.runner_ip.response_body]
  }

  role_assignments = {
    // Allow the current user to access the storage account to read the contents
    "current_user" = {
      principal_id               = data.azurerm_client_config.current.object_id
      role_definition_id_or_name = "Storage Blob Data Contributor"
      principal_type             = "User"
    }
  }

  containers = {
    stig-policy-store = {
      name = "stig-policy-store"
    }
  }
}
