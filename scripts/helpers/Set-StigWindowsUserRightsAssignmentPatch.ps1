function Set-StigWindowsUserRightsAssignmentPatch {
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
    Write-Verbose -Message $("Using upstream processed XML: {0}" -f $ReleasedStigXML)
    
    @("${ReleasedStigXML}.backup") |  % {
        if (!(Test-Path -Path "$_")) {
            Copy-Item -Path "$ReleasedStigXML" -Destination "$_"
            Write-Verbose -Message $("Created backup of released XML: {0}" -f "$_")
        } else {
            Write-Verbose -Message "Backup of released XML already done"
        }
    }

    [xml] $stig = Get-Content -Path "$ReleasedStigXML"

    $ToBeFixedRules = $stig.DISASTIG.UserRightRule.Rule | Where-Object { (( $_.Identity -eq 'NULL' ) -or ( $_.Identity -eq '' ))}
    
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
        $ToBeFixedRules | Format-Table -Property id, DisplayName, Identity, IsNullOrEmpty
    }

    $ToBeFixedRules | ForEach-Object {
        $_.Identity = ''
        Write-Verbose -Message $("Set <Identity/> element for {0} to empty string" -f $_.id)
        $_.IsNullOrEmpty = 'True'
        Write-Verbose -Message $("Set <IsNullOrEmpty/> element for {0} to True" -f $_.id)
    }

    $stig.Save("$ReleasedStigXML")

}
