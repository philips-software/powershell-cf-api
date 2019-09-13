$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-Org.ps1"
. "$source\..\Private\Invoke-GetRequest.ps1"

Describe "Get-Org" {
    Context "API calls" {
        $orgName = "myorgname"
        $org = New-Object PsObject -Property @{name=$orgName}
        $invokeResponse = New-Object PsObject -Property @{resources=@($org)}
        Mock Invoke-GetRequest { $invokeResponse } `
            -Verifiable -ParameterFilter {$path -eq "/v2/organizations?order-by=name&q=name%3A$($orgName)"}
        
        It "Called with the correct URL" {
            Get-Org -Name $orgName
            Assert-VerifiableMock
        }
        It "Returns the first resource object" {
            (Get-Org -Name $orgName) | Should be $org
        }
        It "Uses Name from pipeline" {
            $orgName | Get-Org | Should be $org
        }
        It "Parameter order" {
            Get-Org $orgName | Should be $org
        }

    }
    Context "Parameter validation" {
        It "That Name cannot be empty" {
            { Get-Org "" } | Should -Throw "The argument is null or empty"
        }        
        It "That Name cannot be null" {
            { Get-Org $null } | Should -Throw "The argument is null or empty"
        }
    }    
}