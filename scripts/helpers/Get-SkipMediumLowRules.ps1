$SkipRuleBlockTemplate = @'
            SkipRule   = @(
            ${{SkipRulesList}}
            )
'@

function Get-SkipMediumLowRules {
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

    $stig = [xml] (Get-Content -Path "$powerStigModuleDir\StigData\Processed\$Technology-$TechnologyVersion-$TechnologyRole-$StigVersion.xml")

    $nodes = [array] ($stig.DISASTIG.ChildNodes).Name   

    $ToSkipRules = $nodes | % {$stig.DISASTIG[$_].Rule} | ? {($_.severity -eq 'medium') -or ($_.severity -eq 'low')} | Select-Object -Property Id, severity, DscResource, Description | Sort-Object -Property severity
    #$nodes | % {$stig.DISASTIG[$_].Rule} | ? {$_.severity -eq 'low'} | Select-Object -Property Id, severity, DscResource, Description
  
    $skipRulesList = New-Object System.Collections.Generic.List[System.Object]
    
    $ToSkipRules | ForEach-Object {
        $FindingId = [String] $_.Id
        $Severity = [String] $_.severity
        $DscResource = [String] $_.DscResource
        $skipRulesList.Add("                , '$FindingId'$(' '*(12-$FindingId.Length))# $Severity $(' '*(6-$Severity.Length))| $DscResource")
    }
    $SkipRuleBlock = $SkipRuleBlockTemplate.Replace('            ${{SkipRulesList}}', $($skipRulesList -join "`n"))
    return $SkipRuleBlock
}
