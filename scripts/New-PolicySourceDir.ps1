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

$templateFiles = Get-ChildItem -Path "$scriptDirPath\templates" -Filter "*.txt"

$templateFiles | ForEach-Object {
  $templateFile = $_
  [string] $contents = Get-Content -Path "$($templateFile.FullName)" -Raw
  $replacementTable.Keys | ForEach-Object {
    # Write-Verbose "Replacing `$`{`{$($_)`}`} with value $($replacementTable[$_])"
    $contents = $contents.Replace("`$`{`{$($_)`}`}", $replacementTable[$_])
  }
  New-Item -Path "$policySrcDirPath\$($templateFile.BaseName)" -ItemType File -Value $contents
  
}