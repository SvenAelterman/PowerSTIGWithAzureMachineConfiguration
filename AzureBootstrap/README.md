# Bootstrap

This Terraform performs a quick bootstrap deployment of the necessary resources to test the build and application of the Machine Configuration policy definitions.

## Requirements

Install Az CLI:

```PowerShell
$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://aka.ms/installazurecliwindowsx64 -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; Remove-Item .\AzureCLI.msi
```

Install Terraform:

```PowerShell
$TfVersion = "1.13.2"
mkdir "${Env:ProgramFiles}\terraform"
Invoke-WebRequest -Uri "https://releases.hashicorp.com/terraform/${TfVersion}/terraform_${TfVersion}_windows_amd64.zip" -OutFile "terraform_${TfVersion}_windows_amd64.zip"
Expand-Archive -Path "terraform_${TfVersion}_windows_amd64.zip" -DestinationPath "${Env:ProgramFiles}\terraform\."

[Environment]::SetEnvironmentVariable("PATH", "${Env:PATH};${Env:ProgramFiles}\terraform", [EnvironmentVariableTarget]::Machine)
```

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
