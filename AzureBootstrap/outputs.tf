output "container_resourceid" {
  value = module.storage.containers["stig-policy-store"].id
}

output "managed_identity_resourceid" {
  value = module.id.resource_id
}