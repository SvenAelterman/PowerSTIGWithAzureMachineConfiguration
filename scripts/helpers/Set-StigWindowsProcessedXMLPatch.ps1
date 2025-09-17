$UserRightsAssignmentRules = @(
    "V-254440"
    ,"V-254491"
    ,"V-254492"
    ,"V-254496"
    ,"V-254506"
)

function Set-StigWindowsProcessedXMLPatch {
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
    $ReleasedStigXML = "$powerStigModuleDir\StigData\Processed\$Technology-$TechnologyVersion-$TechnologyRole-$StigVersion.xml"
    @("${ReleasedStigXML}.backup") |  % {if (!(Test-Path -Path "$_")) {Copy-Item -Path "$ReleasedStigXML" -Destination "$_"}}

    [xml] $stig = Get-Content -Path "$ReleasedStigXML"

    $UserRightsAssignmentRules | ForEach-Object {
        $RuleId = $_
        $RuleElement = $stig.DISASTIG.UserRightRule.Rule | Where-Object { ( $_.id -eq $RuleId ) }
        $RuleElement.Identity = ""
        $RuleElement.IsNullOrEmpty = "True"
    }

    $stig.Save("$ReleasedStigXML")

}