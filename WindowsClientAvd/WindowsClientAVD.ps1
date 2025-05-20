Configuration WindowsClientAVD
{
    Import-DscResource -ModuleName PowerSTIG -ModuleVersion 4.25.0
    Import-DscResource -ModuleName SecurityPolicyDsc -ModuleVersion 2.10.0.0

    # LCM shouldn't be necessary with DSC 2.0
    # [scriptblock]$localConfigurationManager = {
    #     LocalConfigurationManager {
    #         ActionAfterReboot  = 'ContinueConfiguration'
    #         ConfigurationMode  = 'ApplyOnly' # TODO: Change to ApplyAndAutoCorrect?
    #         RebootNodeIfNeeded = $true
    #     }
    # }

    [scriptblock]$microsoftEdgeStig = {

        Edge STIG_MicrosoftEdge {

        }
    }

    # [scriptblock]$ie11Stig = {

    InternetExplorer STIG_IE11 {
        BrowserVersion = '11'
        SkipRule       = 'V-223016'
    }
    # }

    [scriptblock]$dotnetFrameworkStig = {

        DotNetFramework STIG_DotnetFramework {
            FrameworkVersion = '4'
        }
    }

    [scriptblock]$windowsFirewallStig = {

        WindowsFirewall STIG_WindowsFirewall {
            SkipRule = @('V-242005', 'V-242004')
        }
    }

    [scriptblock]$windowsDefenderStig = {

        WindowsDefender STIG_WindowsDefender {
            OrgSettings = @{
                'V-213450' = @{ValueData = '1' }
            }
        }
    }

    [scriptblock]$windowsStig = {

        $osVersion = (Get-WmiObject Win32_OperatingSystem).Caption

        if ($osVersion -match "Windows 10") {
            WindowsClient STIG_WindowsClient {
                OsVersion   = '10'
                SkipRule    = @("V-220740", "V-220739", "V-220741", "V-220908")
                Exception   = @{
                    'V-220972' = @{
                        Identity = 'Guests'
                    }
                    'V-220968' = @{
                        Identity = 'Guests'
                    }
                    'V-220969' = @{
                        Identity = 'Guests'
                    }
                    'V-220971' = @{
                        Identity = 'Guests'
                    }
                }
                OrgSettings = @{
                    'V-220912' = @{
                        OptionValue = 'xGuest'
                    }
                }
            }
            AccountPolicy BaseLine2 {
                Name                                = "Windows10fix"
                Account_lockout_threshold           = 3
                Account_lockout_duration            = 15
                Reset_account_lockout_counter_after = 15
            }
        }
        elseif ($osVersion -match "Windows 11") {
            WindowsClient STIG_WindowsClient {
                OsVersion   = '11'
                SkipRule    = @("V-220740", "V-220739", "V-220741", "V-220908")
                Exception   = @{
                    'V-220972' = @{
                        Identity = 'Guests'
                    }
                    'V-220968' = @{
                        Identity = 'Guests'
                    }
                    'V-220969' = @{
                        Identity = 'Guests'
                    }
                    'V-220971' = @{
                        Identity = 'Guests'
                    }
                }
                OrgSettings = @{
                    'V-220912' = @{
                        OptionValue = 'xGuest'
                    }
                }
            }
            AccountPolicy BaseLine2 {
                Name                                = "Windows11Fix"
                Account_lockout_threshold           = 3
                Account_lockout_duration            = 15
                Reset_account_lockout_counter_after = 15
            }
        }
    }
    
    # Node localhost
    # {
    #     # $localConfigurationManager.Invoke()
    #     # $windowsStig.Invoke()
    #     # $ie11Stig.Invoke()
    #     # $dotnetFrameworkStig.Invoke()
    #     # $windowsDefenderStig.Invoke()
    #     # $windowsFirewallStig.Invoke()
    #     # $microsoftEdgeStig.Invoke()
    # }
}

WindowsClientAVD