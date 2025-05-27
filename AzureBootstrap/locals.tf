locals {
  subscription_id = var.subscription_id

  instance_formatted = format("%02d", var.instance)

  naming_structure = replace(replace(replace(replace(var.naming_convention, "{workloadName}", var.workload_name), "{environment}", var.environment), "{region}", local.short_locations[var.location]), "{instance}", local.instance_formatted)
}

locals {
  short_locations = {
    "canadacentral" = "cnc"
    "centralus"     = "cus"
    "eastus"        = "eus"
    "eastus2"       = "eus2"
  }
}
