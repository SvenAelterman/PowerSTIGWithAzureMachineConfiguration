# Bootstrap

This Terraform performs a quick bootstrap deployment of the necessary resources to test the build and application of the Machine Configuration policy definitions.

## Quick Usage

Create an auto.tfvars file with (minimally) the following values defined:

```hcl
subscription_id     = "00000000-0000-0000-0000-000000000000"
location            = "eastus"
```

Run `terraform apply`.

## Note

This will create a storage account that will only allow access to the policy author's IP address.
The author will need to create a service endpoint to allow the Azure VMs that will be managed by the authored guest machine policies to access the packages referenced by the policy.
If Azure ARC-enabled servers will be within scope, then a private endpoint, private DNS, and forwarding will need to setup to allow these resources access.
