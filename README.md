# PowerSTIG with Azure Machine Configuration

Deploying DISA STIGs using PowerSTIG and Azure Machine Configuration.

> Full end-to-end deployment, including Azure DevOps guidance for automation, is still a work-in-progress. See the [Issues](./issues)

## Requirements

### Local

These PowerShell modules must be available on the authoring workstation or automated build agent.

```PowerShell
# Install required modules for authoring and publishing
$requiredModules = @(
   "PowerSTIG",
   "PSDesiredStateConfiguration",
   "GuestConfiguration",
   "Az"
)

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
$requiredModules | ForEach-Object {Install-Module $_ -Force}
Set-PSRepository -Name PSGallery -InstallationPolicy Untrusted
```

```PowerShell
# Stage the required DSC modules in authoring environment
# Note, that we will pin the versions of these modules.
# As of 2025-08-02, PowerSTIG required version 5 of the CertficateDSC module.
(Get-Module -Name PowerStig -ListAvailable).RequiredModules | % {
    Install-Module -Name $_.Name -RequiredVersion $_.Version -Force
}
```

### Azure

The policy authoring process requires the following Azure resources:

1. Azure subscription to hold the resulting guest policies.
(A management group is preferable)
2. Azure subscription for the storage account that will contain the guest policy configuration packages.
Within the Azure Landing Zone framework, this would be the platform Management subscription.
3. Azure storage account.

The Azure storage account should be created using the included Terraform module [AzureBootstrap](./AzureBootstrap/).
Refer to its [README](./AzureBootstrap/README.md) for setup.

## Example: Creating a STIG-based Azure Guest Configuration Policy for a Windows 2022 Member Server

List available composite resources for the current version of PowerSTIG:

```PowerShell
Get-Stig -ListAvailable | Format-Table | Out-Host -Paging
```

Sample output:

```Powershell
Technology       TechnologyVersion TechnologyRole Version RuleList
----------       ----------------- -------------- ------- --------
Adobe            AcrobatPro                       2.1     {}
Adobe            AcrobatReader                    1.6     {}
Adobe            AcrobatReader                    2.1     {}
DotNetFramework  4                                2.5     {}
DotNetFramework  4                                2.6     {}
FireFox          All                              6.5     {}
FireFox          All                              6.6     {}
Google           Chrome                           2.10    {}
Google           Chrome                           2.9     {}
IISServer        10.0                             3.1     {}
IISServer        10.0                             3.3     {}
IISServer        8.5                              2.4     {}
IISServer        8.5                              2.5     {}
IISSite          10.0                             2.11    {}
IISSite          10.0                             2.9     {}
<SPACE> next page; <CR> next line; Q quit
```

In order to display the currently available Windows Server composite resources:

```PowerShell
Get-Stig -Technology WindowsServer | FT
```

Output:

```PowerShell
Technology    TechnologyVersion TechnologyRole Version RuleList
----------    ----------------- -------------- ------- --------
WindowsServer 2012R2            DC             3.3     {}
WindowsServer 2012R2            DC             3.4     {}
WindowsServer 2012R2            MS             3.3     {}
WindowsServer 2012R2            MS             3.4     {}
WindowsServer 2016              DC             2.8     {}
WindowsServer 2016              DC             2.9     {}
WindowsServer 2016              MS             2.8     {}
WindowsServer 2016              MS             2.9     {}
WindowsServer 2019              DC             3.3     {}      
WindowsServer 2019              DC             3.4     {}
WindowsServer 2019              MS             3.3     {}      
WindowsServer 2019              MS             3.4     {}
WindowsServer 2022              DC             2.3     {}
WindowsServer 2022              DC             2.4     {}
WindowsServer 2022              MS             2.3     {}
WindowsServer 2022              MS             2.4     {}
```

Note, you may list the location of the composite resources XML files by executing the following command:

```PowerShell
$(Get-ChildItem "$($(Get-Module -Name PowerStig -ListAvailable).ModuleBase)\StigData\Processed"  -Filter "*.org.default.xml").FullName
```

In this example we will create an Azure Guest Configuration Policy to apply the STIG settings for a Windows 2022 member server

```PowerShell
# Set variables
$Technology = "WindowsServer"
$TechnologyVersion = "2022"
$TechnologyRole = "MS"
$StigVersion = "2.4"

$StigXmlBaseName = "$Technology-$TechnologyVersion-$TechnologyRole-$StigVersion"

# **IMPORTANT**
# Create a new feature branch for the authored policy
# All changes will be added to his branch
git switch -c "feature/$StigXmlBaseName"


# Create a folder to hold organization settings
# This folder should be tracked in a repository

$OrgSettingsDir = "$($pwd.Path)\OrgSettings" | % {if (!(Test-Path -Path "$_")) {New-Item -Type Directory -Path "$_"} else {Get-Item -Path "$_"}}

# In this example we select version 2.4 of the settings for a 2022 member server
cp "$($(Get-Module -Name PowerStig -ListAvailable).ModuleBase)\StigData\Processed\$StigXmlBaseName.org.default.xml" "$($OrgSettingsDir.FullName)\$StigXmlBaseName.org.xml"

```

Edit the resulting `.\OrgSettings\WindowsServer-2022-MS-2.4.org.xml`.
A sample of an edited organization settings file is located in `scripts/samples/WindowsServer-2022-MS-2.4.sample.org.xml`

Next, create a new policy source folder by using the utility script `./scripts/New-PolicySourceDir.ps1`

```PowerShell
.\scripts\New-PolicySourceDir.ps1 -Technology $Technology -TechnologyVersion $TechnologyVersion -TechnologyRole $TechnologyRole -StigVersion $StigVersion
```

In order to simplify our development of policy, we will create a set of skipped rules comprising the Cat II and Cat III rules.

```PowerShell
# Dot source function
. .\scripts\helpers\Get-SkipMediumLowRules.ps1
Get-SkipMediumLowRules | Set-Clipboard
```

Replacing the line `## SkipRule   = @()`, paste the code into `$StigXmlBaseName\New-Configuration.ps1`.

We are now ready to create the configuration and policy.

```PowerShell
pushd "$StigXmlBaseName"

.\New-Configuration.ps1
.\New-Package.ps1
.\New-Policy.ps1

# alternatively to create an Azure VM only policy, supply the resource id of the user assigned managed identity created by the bootstrap
$mgIdResourceId = "<resourceid>"
.\New-Policy.ps1 -ManagedIdentityResourceId "$mgIdResourceId"

```

## TODO:

1. Create a new feature branch for new policy definition source
2. Copy any new *.org.default.xml files from module base to `OrgSettings` folder. Important not to overwrite existing!
3. PolicyName should align with the basename of the xml files in `OrgSettings`
5. Should create `New-Configuration.ps1.txt` templates that align with each of the composite xml files in `OrgSettings`
