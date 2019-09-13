$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-Space.ps1"
. "$source\..\Private\Invoke-GetRequest.ps1"

Describe "Get-Space" {
    Context "API call" {
        $Space = New-Object PsObject -Property @{name="app1"}
        $invokeResponse = New-Object PsObject -Property @{resources=@($Space)}        
        Mock Invoke-GetRequest { $invokeResponse } `
            -Verifiable -ParameterFilter {$path -eq "/v2/spaces?order-by=name&q=name%3A$($Space.name)"}
        
        It "Called with the correct URL" {
            Get-Space -Name $Space.Name
            Assert-VerifiableMock
        }
        It "Returns the first resource object" {
            (Get-Space -Name $Space.Name) | Should be $Space
        }
        It "Uses value from pipeline" {
            $Space.Name | Get-Space | Should be $Space
        }
    }
    Context "Parameter validation" {
        It "That Name cannot be empty" {
            { Get-Space -Name "" } | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty"
        }        
        It "That Name cannot be null" {
            { Get-Space -Name $null } | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty"
        }
    }    
}