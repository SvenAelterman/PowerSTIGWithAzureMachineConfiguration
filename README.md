# PowerSTIG with Azure Machine Configuration

Deploying DISA STIGs using PowerSTIG and Azure Machine Configuration.

> Full end-to-end deployment, including Azure DevOps guidance for automation, is still a work-in-progress. See the [Issues](./issues)

## Requirements

These PowerShell modules must be available on the authoring workstation or automated build agent.

```PowerShell
# Install required modules for authoring and publishing
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module PSDesiredStateConfiguration
Install-Module GuestConfiguration
Install-Module PowerSTIG
Install-Module Az
Set-PSRepository -Name PSGallery -InstallationPolicy Untrusted
```

```PowerShell
# From an elevated PowerShell session
# Install required DSC modules
(Get-Module PowerStig -ListAvailable).RequiredModules | % {
   $PSItem | Install-Module -Force
}
```

```PowerShell
# Create an empty Policy source folder using utility script
.\scripts\New-PolicySourceDir.ps1 -PolicyName "<Policy_Name>"

# Edit New-Configuration
# List location of downloaded STIG xml files
# Example filters for all WindowServer-2022 stigs
Import-Module -Name PowerStig
Get-ChildItem "$($(Get-Module -Name PowerStig).ModuleBase)\StigData\Processed"  -Filter "*.org.default.xml"

$OrgSettingsDir = "$($pwd.Path)\OrgSettings" | % {if (!(Test-Path -Path "$_")) {New-Item -Type Directory -Path "$_"} else {Get-Item -Path "$_"}}

cp "$($(Get-Module -Name PowerStig).ModuleBase)\StigData\Processed\WindowsServer-2022-DC-2.4.org.default.xml" "$($OrgSettingsDir.FullName)\WindowsServer-2022-DC-2.4.org.xml"

# Edit the file in OrgSettings folder
# add the path in the New-Configuration.ps1 file for Policy source dir
```

## TODO:

1. Create a new feature branch for new policy definition source
2. Copy any new *.org.default.xml files from module base to `OrgSettings` folder. Important not to overwrite existing!
3. PolicyName should align with the basename of the xml files in `OrgSettings`
5. Should create `New-Configuration.ps1.txt` templates that align with each of the composite xml files in `OrgSettings`
