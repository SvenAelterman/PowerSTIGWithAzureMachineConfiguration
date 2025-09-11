[CmdletBinding()]

param (
    [Parameter()]
    [string] $PolicyId = $([guid]::NewGuid().Guid),

    [Parameter(Mandatory)]
    [string] $Technology,

    [Parameter(Mandatory)]
    [string] $TechnologyVersion,

    [Parameter()]
    [string] $TechnologyRole = "",

    [Parameter(Mandatory)]
    [string] $StigVersion
)


$scriptDirPath =  Split-Path -Parent $PSCommandPath
Write-Verbose $scriptDirPath

$PolicyName = "{0}{1}{2}-{3}" -f (
  $Technology,
  $(if ($TechnologyVersion.Length -eq 0) {"-All"} else {"-$TechnologyVersion"}),
  $(if ($TechnologyRole.Length -eq 0) {''} else {"-$TechnologyRole"}),
  $StigVersion
)

$replacementTable = @{
  PolicyName = $PolicyName
  Id = $PolicyId
  Technology = $Technology
  TechnologyRole = $TechnologyRole
  TechnologyVersion = $TechnologyVersion
  StigVersion = $StigVersion
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