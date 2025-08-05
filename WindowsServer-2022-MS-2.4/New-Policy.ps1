[CmdletBinding(DefaultParametersetName="default")]
param (
    [Parameter()]
    [string] $ContainerName = 'stig-policy-store',

    [Parameter()]
    [string] $StorageAcctResourceGroupName = 'StigMC-demo-rg-cnc-01',

    [Parameter()]
    [string] $StorageAcctName = 'stigmcdemostcnc01',

    [Parameter(ParameterSetName="mgt")]
    [string] $ManagementGroupName = "",

    [Parameter(ParameterSetName="sub")]
    [string] $SubscriptionId = "",

    [Parameter()]
    [string] $ManagedIdentityResourceId = ""
)

$PolicyDisplayName = "WindowsServer-2022-MS-2.4 STIG Configuration"
$PolicyName        = $PolicyDisplayName.Replace(' ', '').Replace('-', '')
$PolicyDescription ="Audits and applies the WindowsServer-2022-MS-2.4 STIG configuration."

$MetaData = Get-Content -Path './metadata.jsonc' | ConvertFrom-Json
$Guid     = [string] $MetaData.guid
$Version  = [string] $MetaData.version

# Get a SAS URL for the package
# TODO: Get storage account name from some config or from Terraform bootstrap output
$Context = Get-AzStorageContainer -Name $ContainerName -Context (Get-AzStorageAccount -ResourceGroupName $StorageAcctResourceGroupName -Name $StorageAcctName).Context
$StartTime = Get-Date
$EndTime = $StartTime.AddDays(3)

$TokenParams = @{
    StartTime  = $StartTime
    ExpiryTime = $EndTime
    Container  = $ContainerName
    Blob       = "WindowsServer-2022-MS-2.4-${Version}.zip" # Must match the name of the package created in New-Package.ps1
    Permission = 'r' # Read permission
    Context    = $Context.Context
    FullUri    = $true
}
[string]$ContentUri = New-AzStorageBlobSASToken @TokenParams


$basePolicyConfig = @{
    PolicyId      = $Guid # Use the same GUID for each new version of the policy definition.
    DisplayName   = $PolicyDisplayName
    Description   = $PolicyDescription
    PolicyVersion = $Version

    Platform      = 'Windows'
    Mode          = 'ApplyAndAutoCorrect'

    # Azure resources
    # ContentUri    = "https://${StorageAcctName}.blob.core.windows.net/stig-policy-store/WindowsServer-2022-MS-2.4-${Version}.zip"
    ContentUri    = $ContentUri
}

$AzPolicyDefinitionRootPath = if ($ManagedIdentityResourceId -eq "") {
    "./policies/arc-enabled-and-azure/deployIfNotExists"
} else {
    "./policies/azure-only/deployIfNotExists"
}

$umiPolicyConfig = if ($ManagedIdentityResourceId -eq "") {
    @{
        Path               = $AzPolicyDefinitionRootPath
        ExcludeArcMachines = $false # $true for UMI parameter set
    }
} else {
    @{
        Path               = $AzPolicyDefinitionRootPath
        ExcludeArcMachines = $true # $true for UMI parameter set
        LocalContentPath = "./Package/WindowsServer-2022-MS-2.4-${Version}.zip"
        ManagedIdentityResourceId = $ManagedIdentityResourceId
    }
}

$PolicyConfig = $basePolicyConfig + $umiPolicyConfig

New-GuestConfigurationPolicy @PolicyConfig

if (($ManagementGroupName -ne "") -or ($SubscriptionId -ne "")) {
    # Deploy the policy to an Azure Management Group
    $baseAzPolicyDefinitionParams = @{
        Name                = $PolicyName
        DisplayName         = $PolicyDisplayName
        Policy              = "$AzPolicyDefinitionRootPath/WindowsServer-2022-MS-2.4-${Version}_DeployIfNotExists.json"
        Description         = $PolicyDescription
    }
    $scopeAzPolicyDefinitionParam = if ($ManagementGroupName -ne "") {
        @{ManagementGroupName = $ManagementGroupName}
    } elseif ($SubscriptionId -ne "") {
        @{SubscriptionId = $SubscriptionId}
    } else {
        @{}
    }
    $newAzPolicyDefinitionParams = $baseAzPolicyDefinitionParams +  $scopeAzPolicyDefinitionParam
    New-AzPolicyDefinition @newAzPolicyDefinitionParams
}