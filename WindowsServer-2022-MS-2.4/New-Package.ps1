[CmdletBinding()]
param (
    [Parameter()]
    [string] $ContainerName = 'stig-policy-store',

    [Parameter()]
    [string] $StorageAcctResourceGroupName = 'StigMC-demo-rg-cnc-01',

    [Parameter()]
    [string] $StorageAcctName = 'stigmcdemostcnc01'
)

$MetaData = Get-Content -Path './metadata.jsonc' | ConvertFrom-Json

[string]$Version = $MetaData.version

[hashtable]$params = @{
    Name          = "WindowsServer-2022-MS-2.4-$Version"
    Configuration = './this/localhost.mof'
    Version       = $Version
    Type          = 'AuditAndSet'
    Force         = $true
    Path          = './Package'
}
New-GuestConfigurationPackage @params

# Upload
$Context = (Get-AzStorageAccount -ResourceGroupName $StorageAcctResourceGroupName -Name $StorageAcctName).Context

$blobPararms = @{
    File = "./Package/WindowsServer-2022-MS-2.4-${Version}.zip"
    Container = $ContainerName
    Blob = "WindowsServer-2022-MS-2.4-${Version}.zip"
    Context = $Context
    StandardBlobTier = 'Hot'
}

Set-AzStorageBlobContent @blobPararms