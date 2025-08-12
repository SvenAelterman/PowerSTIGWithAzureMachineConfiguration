<#
    Use the embedded STIG data with default range values to apply the most recent STIG settings.
    In this example, the composite resource gets the highest 2012 R2 member server STIG version
    file it can find locally and applies it to the server. The composite resource merges in the
    default values for any settings that have a valid range.
#>
configuration this
{
    param
    (
        [parameter()]
        [string]
        $NodeName = 'localhost'
    )

    Import-DscResource -ModuleName PowerStig

    Node $NodeName
    {
        WindowsServer BaseLine
        {
            # These options correspond to WindowsServer-2022-MS-2.4.org.xml
            OsVersion   = '2022'
            OsRole      = 'MS'
            OrgSettings  = "../OrgSettings/WindowsServer-2022-MS-2.4.org.xml"
            StigVersion = '2.4'
            #DomainName  = ''
            #ForestName  = ''

            # Rules are skipped because we do not have root certs.
            # Require DoD login.
            SkipRule = @(
                'V-254442.a'
                ,'V-254442.b'
                ,'V-254442.c'
                ,'V-254442.d'
                ,'V-254443'
                ,'V-254444'
            )

            # These exceptions must be made because server is not domain joined.
            # DomainName and ForestName are not specified.
            Exception   = @{
                'V-254436' = @{ Identity = 'Guests' }
                'V-254437' = @{ Identity = 'Administrators' }
                'V-254438' = @{ Identity = 'Guests' }
                'V-254439' = @{ Identity = 'Guests' }
            }
        }
    }
}

this