[hashtable]$params = @{
    Name          = 'SimpleTest'
    Configuration = './localhost.mof'
    Version       = "0.0.1"
    Type          = 'Audit'
    Force         = $true
    Path          = './Package'
}
New-GuestConfigurationPackage @params