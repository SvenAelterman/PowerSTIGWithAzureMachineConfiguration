$ExceptionBlockTemplate = @'
            Exception   = @{
            ${{ExceptionsList}}
            }
'@

function Get-StigUserRightRuleExceptions {
    [CmdletBinding()]

    param (
        [parameter()]
        [string] $Technology = "WindowsServer",
    
        [parameter()]
        [string] $TechnologyVersion = "2022",
    
        [parameter()]
        [string] $TechnologyRole = "MS",

        [parameter()]
        [string] $StigVersion = "2.4"
    )


    $powerStigModuleDir = $(Get-Module -Name PowerSTIG -ListAvailable).ModuleBase

    [xml] $stig = Get-Content -Path "$powerStigModuleDir\StigData\Processed\$Technology-$TechnologyVersion-$TechnologyRole-$StigVersion.xml"

    # $stig.DISASTIG.UserRightRule.Rule | Where-Object { ( $_.OrganizationValueRequired -eq 'False' ) } | Select-Object -Property Id, DisplayName, DscResource, Identity

    $NotRequiredFindings = $stig.DISASTIG.UserRightRule.Rule | Where-Object { ( $_.OrganizationValueRequired -eq 'False' ) }

    $OrgExceptions = [hashtable]@{}
    
    $exceptionList = New-Object System.Collections.Generic.List[System.Object]
    
    $NotRequiredFindings | ForEach-Object {
        $FindingId = [String] $_.Id
        $IdentityValue = $_.Identity -join ','
        # $OrgExceptions.Add($FindingId,  [hashtable]@{ Identity = "$IdentityValue"})
        # $exceptionList.Add("                '$FindingId' = @`{ Identity = '`$`{`{replaceWithOrgValue`}`}' `}")
        $exceptionList.Add("                '$FindingId' = @`{ Identity = '$IdentityValue' `}")
    }

    # $OrgExceptions['V-254494']['Identity']
    # $OrgExceptions # Return
    #$exceptionList
    $ExceptionBlock = $ExceptionBlockTemplate.Replace('            ${{ExceptionsList}}', $($exceptionList -join "`n"))
    $ExceptionBlock
}
