[hashtable]$params = @{
    Name          = 'WindowsClientAVD'
    Configuration = './localhost.mof'
    Version       = "0.0.1"
    Type          = 'AuditAndSet'
    Force         = $true
    Path          = './Package'
}
New-GuestConfigurationPackage @params