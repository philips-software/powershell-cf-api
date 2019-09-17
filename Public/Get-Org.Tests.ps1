$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-Org.ps1"
. "$source\..\Private\Invoke-GetRequest.ps1"

Describe "Get-Org" {
    $orgName = "myorgname"
    $org = [PSCustomObject]@{name=$orgName}
    Mock Invoke-GetRequest { [PSCustomObject]@{resources=@($org)} } -Verifiable -ParameterFilter {$path -eq "/v2/organizations?order-by=name&q=name%3A$($orgName)"}
    Context "API calls" {        
        It "is called with the correct URL" {
            Get-Org -Name $orgName
            Assert-VerifiableMock
        }
        It "returns the first resource object" {
            (Get-Org -Name $orgName) | Should be $org
        }
    }
    Context "parameters" {
        It "ensures 'Name' cannot be empty" {
            { Get-Org "" } | Should -Throw "The argument is null or empty"
        }        
        It "ensures 'Name' cannot be null" {
            { Get-Org $null } | Should -Throw "The argument is null or empty"
        }
        It "support positional" {
            Get-Org $orgName | Should be $org
        }
        It "supports 'Name' from pipeline" {
            $orgName | Get-Org | Should be $org
        }
    }    
}