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
# Stage the required DSC modules in authoring environment
# Note, that we will pin the versions of these modules.
(Get-Module PowerStig -ListAvailable).RequiredModules | % {
    Install-Module -Name $_.Name -RequiredVersion $_.Version -Force
}
```

```PowerShell
# List location of downloaded STIG xml files
# Example filters for all WindowServer-2022 stigs
Import-Module -Name PowerStig
Get-ChildItem "$($(Get-Module -Name PowerStig).ModuleBase)\StigData\Processed"  -Filter "*.org.default.xml"

$OrgSettingsDir = "$($pwd.Path)\OrgSettings" | % {if (!(Test-Path -Path "$_")) {New-Item -Type Directory -Path "$_"} else {Get-Item -Path "$_"}}

# In this example we select version 2.4 of the settings for a 2022 member server
cp "$($(Get-Module -Name PowerStig).ModuleBase)\StigData\Processed\WindowsServer-2022-MS-2.4.org.default.xml" "$($OrgSettingsDir.FullName)\WindowsServer-2022-MS-2.4.org.xml"

# Edit New-Configuration .\OrgSettings\WindowsServer-2022-MS-2.4.org.xml
# add the path in the New-Configuration.ps1 file for Policy source dir

# Create an empty Policy source folder using utility script
# Use the basename of the xml file copied to the OrgSettings folder

.\scripts\New-PolicySourceDir.ps1 -PolicyName "WindowsServer-2022-MS-2.4"

# Make sure you edit New-Configuration.ps1 to reflect location of WindowsServer-2022-MS-2.4.org.xml

pushd WindowsServer-2022-MS-2.4

.\New-Configuration.ps1
.\New-Package.ps1
 .\New-Policy.ps1 -StorageAcctResourceGroupName "StigMC-demo-rg-cnc-01" -StorageAcctName '<storage_account_name>'

 # alternatively to create an Azure VM only policy, supply the resource id of the user assigned managed identity in from bootstrap
 .\New-Policy.ps1 -StorageAcctResourceGroupName "StigMC-demo-rg-cnc-01" -StorageAcctName '<storage_account_name>' -ManagedIdentityResourceId "<resourceid>"

```

## TODO:

1. Create a new feature branch for new policy definition source
2. Copy any new *.org.default.xml files from module base to `OrgSettings` folder. Important not to overwrite existing!
3. PolicyName should align with the basename of the xml files in `OrgSettings`
5. Should create `New-Configuration.ps1.txt` templates that align with each of the composite xml files in `OrgSettings`
