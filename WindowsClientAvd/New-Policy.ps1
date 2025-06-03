# Get a SAS URL for the package
# TODO: Get storage account name from some config or from Terraform bootstrap output
$Context = Get-AzStorageContainer -Name 'stig-policy-store' -Context (Get-AzStorageAccount -ResourceGroupName 'StigMC-test-rg-cnc-01' -Name 'stigmcteststcnc01').Context

$StartTime = Get-Date
$EndTime = $StartTime.AddYears(3)

$TokenParams = @{
    StartTime  = $StartTime
    ExpiryTime = $EndTime
    Container  = 'stig-policy-store'
    Blob       = 'WindowsClientAVD-0.0.1.zip' # Must match the name of the package created in New-Package.ps1
    Permission = 'r' # Read permission
    Context    = $Context.Context
    FullUri    = $true
}
[string]$ContentUri = New-AzStorageBlobSASToken @TokenParams

$MetaData = Get-Content -Path './metadata.jsonc' | ConvertFrom-Json

[string]$Version = $MetaData.version
[string]$Guid = $MetaData.guid

$PolicyConfig = @{
    PolicyId      = $Guid # Must be a GUID. Use the same GUID for a new version of the policy definition.
    DisplayName   = "Windows Client AVD STIG Configuration"
    Description   = "Audits and applies the Windows Client AVD STIG configuration."
    PolicyVersion = $Version

    Platform      = 'Windows'
    Mode          = 'ApplyAndAutoCorrect'

    #LocalContentPath = "./Package/WindowsClientAvd.zip"
    Path          = "./policies/deployIfNotExists"
    # Azure resources
    # - Storage Account
    #ContentUri    = "https://stigmcteststcnc01.blob.core.windows.net/stig-policy-store/WindowsClientAVD.zip"
    ContentUri    = $ContentUri
    # - Managed Identity
    #ManagedIdentityResourceId = "" # Not supported for Arc machines
}
New-GuestConfigurationPolicy @PolicyConfig # -ExcludeArcMachines switch might be required (Arc machines don't support User-assigned Managed Identities)

# Deploy the policy to an Azure Management Group