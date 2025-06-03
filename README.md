# PowerSTIG with Azure Machine Configuration

Deploying DISA STIGs using PowerSTIG and Azure Machine Configuration.

> Full end-to-end deployment, including Azure DevOps guidance for automation, is still a work-in-progress. See the [Issues](./issues)

## Requirements

These PowerShell modules must be available on the authoring workstation or automated build agent.

```PowerShell
# Install required modules for authoring and publishing
Install-Module PSDesiredStateConfiguration
Install-Module GuestConfiguration
Install-Module PowerSTIG
Install-Module Az

# Any DSC modules required
# E.g.,
Install-Module ComputerManagementDsc -Force
# ...
```
