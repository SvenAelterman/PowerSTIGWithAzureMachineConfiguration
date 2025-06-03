$MetaData = Get-Content -Path './MetaData.jsonc' | ConvertFrom-Json

[string]$Version = $MetaData.version

[hashtable]$params = @{
    Name          = "WindowsClientAVD-$Version"
    Configuration = './localhost.mof'
    Version       = $Version
    Type          = 'AuditAndSet'
    Force         = $true
    Path          = './Package'
}
New-GuestConfigurationPackage @params

# TODO: Upload package to Azure Storage Account (will use Azure DevOps pipeline task)
