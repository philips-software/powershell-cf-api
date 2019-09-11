"current location: $(Get-Location)"
"script root: $PSScriptRoot"
"retrieve available modules"
$modules = Get-Module -list

if ($modules.Name -notcontains 'pester') {
    Install-Module -Name Pester -Force -SkipPublisherCheck
}

Invoke-Pester -Script @{ Path = 'Public/*' } -OutputFile "./Test-Pester.XML" -OutputFormat 'NUnitXML'