# Bootstrap

This Terraform performs a quick bootstrap deployment of the necessary resources to test the build and application of the Machine Configuration policy definitions.

## Quick Usage

Create an auto.tfvars file with (minimally) the following values defined:

```hcl
subscription_id     = "00000000-0000-0000-0000-000000000000"
location            = "eastus"
resource_group_name = "stigmachineconfig-test-rg-eastus-01"
```

Run `terraform apply`.
