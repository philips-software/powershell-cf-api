
$VerbosePreference = "silentlycontinue"
function Install-ModuleVersion($Name, $Version) {
    if ((Get-Module -list -Name $Name | where { $_.version -eq $Version }) -notcontains $Name) {
        Install-Module -Name $Name -SkipPublisherCheck -RequiredVersion $Version -Force
    }
}

Install-ModuleVersion -Name "Pester" -Version "5.0.1"
Install-ModuleVersion -Name "Functional" -Version "0.0.4"
Install-ModuleVersion -Name "PesterMatchHashTable" -Version "0.3.0"
Install-ModuleVersion -Name "PesterMatchArray" -Version "0.3.1"

Invoke-Pester -ExcludeTag 'Disabled' -Path "cf-api" -OutputFile "./test-pester.xml" -OutputFormat NUnitXml
