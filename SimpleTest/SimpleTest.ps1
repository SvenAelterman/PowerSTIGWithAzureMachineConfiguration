Configuration SimpleTest {
    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 10.0.0 -Name TimeZone
    
    TimeZone 'SetTimeZone' {
        TimeZone         = 'Central Standard Time'
        IsSingleInstance = 'Yes'
    }
}

SimpleTest