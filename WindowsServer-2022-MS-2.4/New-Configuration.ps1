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
            #DomainName  = 'wirebyte.local'
            #ForestName  = 'sample.test'

            Exception   = @{
                'V-254434' = @{ Identity = 'Administrators,Authenticated Users' }
                'V-254436' = @{ Identity = 'Administrators,Guests' }
                'V-254437' = @{ Identity = 'Administrators' }
                'V-254438' = @{ Identity = 'Administrators,Guests' }
                'V-254439' = @{ Identity = 'Administrators,Local account,Guests' }
                'V-254440' = @{ Identity = 'NUL' }
                'V-254491' = @{ Identity = 'NUL' }
                'V-254492' = @{ Identity = 'NUL' }
                # 'V-254493' = @{ Identity = 'Administrators' }
                # 'V-254494' = @{ Identity = 'Administrators' }
                # 'V-254495' = @{ Identity = 'Administrators' }
                'V-254496' = @{ Identity = 'NUL' }
                # 'V-254497' = @{ Identity = 'Administrators,Service,Local Service,Network Service' }
                'V-254498' = @{ Identity = 'NUL' }
                # 'V-254500' = @{ Identity = 'Administrators' }
                # 'V-254501' = @{ Identity = 'Administrators' }
                # 'V-254502' = @{ Identity = 'Local Service,Network Service' }
                # 'V-254503' = @{ Identity = 'Administrators,Service,Local Service,Network Service' }
                # 'V-254504' = @{ Identity = 'Administrators' }
                # 'V-254505' = @{ Identity = 'Administrators' }
                'V-254506' = @{ Identity = 'NUL' }
                # 'V-254507' = @{ Identity = 'Administrators' }
                # 'V-254508' = @{ Identity = 'Administrators' }
                # 'V-254509' = @{ Identity = 'Administrators' }
                # 'V-254510' = @{ Identity = 'Administrators' }
                # 'V-254511' = @{ Identity = 'Administrators' }
                # 'V-254512' = @{ Identity = 'Administrators' }
                'V-254444' = @{ Thumbprint = 'NUL'; Location = 'NUL'}
            }
        }
    }
}

this