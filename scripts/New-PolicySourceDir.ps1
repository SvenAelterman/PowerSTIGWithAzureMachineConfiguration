[CmdletBinding()]

param (
    [Parameter(Mandatory)]
    [string] $PolicyName,

    [Parameter()]
    [string] $PolicyId = $([guid]::NewGuid().Guid)
)


$scriptDirPath =  Split-Path -Parent $PSCommandPath
Write-Verbose $scriptDirPath

$replacementTable = @{
  PolicyName = $PolicyName
  Id = $PolicyId
}

$policySrcDir = New-Item -ItemType Directory -Path $PolicyName
$policySrcDirPath = $policySrcDir.FullName

# $policyMetadata = @"
# {
#   "version": "0.0.1",
#   "guid": "$id"    
# }
# "@

# New-Item -Path "$policySrcDirPath\metadata.jsonc" -ItemType File -Value $policyMetadata

# $newPackage = Get-Content -Path "$scriptDirPath\templates\New-Package.ps1.txt" -Raw
# $newPolicytemplates = Get-Content -Path "$scriptDirPath\templates\New-Policy.ps1.txt" -Raw

# New-Item -Path "$policySrcDirPath\New-Package.ps1" -ItemType File -Value $newPackage.Replace('${{PolicyName}}', $PolicyName)
# New-Item -Path "$policySrcDirPath\New-Policy.ps1" -ItemType File -Value $newPolicytemplates.Replace('${{PolicyName}}', $PolicyName)

$templateFile = Get-ChildItem -Path "$scriptDirPath\templates" -Filter "*.txt"

$templateFile | ForEach-Object {
  $f = $_
  [string] $contents = Get-Content -Path "$f" -Raw
  $replacementTable.Keys | ForEach-Object {
    # Write-Verbose "Replacing `$`{`{$($_)`}`} with value $($replacementTable[$_])"
    $contents = $contents.Replace("`$`{`{$($_)`}`}", $replacementTable[$_])
  }
  New-Item -Path "$policySrcDirPath\$($f.BaseName)" -ItemType File -Value $contents
  
}