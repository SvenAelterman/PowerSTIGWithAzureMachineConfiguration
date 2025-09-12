variable "subscription_id" {
  type        = string
  description = "The Azure subscription ID where the resources will be deployed."
}

variable "location" {
  type        = string
  description = "The Azure region where the resources will be deployed."
}

variable "naming_convention" {
  type        = string
  description = "The naming convention to be used for all resources in this deployment."
  default     = "{resourceType}-{workloadName}-{environment}-{region}-{instance}"
}

locals {
  // Calculate the maximum length of the workload name based on other inputs
  // The restriction is the maximum length of the Key Vault name (24 characters)
  workload_name_max_length = 24 - length(var.environment) - length("-") - length("-${local.short_locations[var.location]}") - length("-00") - length("-kv")
}

variable "workload_name" {
  type        = string
  description = "The name of the workload to be deployed."
  default     = "StigMC"
  validation {
    condition     = length(var.workload_name) <= local.workload_name_max_length
    error_message = "The maximum length is ${local.workload_name_max_length}, which is based on some other inputs. '${var.workload_name}' is ${length(var.workload_name)} characters long."
  }
}

variable "environment" {
  type        = string
  description = "The environment name for the resources."
  default     = "test"
}

variable "instance" {
  type        = number
  description = "The instance number for the deployment."
  default     = 1
}

variable "enable_telemetry" {
  type        = bool
  description = "Enable telemetry for the Azure Verified Modules."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources."
  default     = {}
}
