$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-Service.ps1"
. "$source\..\Private\Invoke-GetRequest.ps1"

Describe "Get-Service" {
    Context "API call" {
        $Space = New-Object PsObject -Property @{metadata=@{guid="123"}}
        $Service = New-Object PsObject -Property @{Name="service1"}
        $invokeResponse = New-Object PsObject -Property @{resources=@($Service)}
        Mock Invoke-GetRequest { $invokeResponse } `
            -Verifiable -ParameterFilter {$path -eq "/v2/spaces/$($Space.metadata.guid)/services?q=label%3A$($Service.Name)"}
        
        It "Called with the correct URL" {
            Get-Service -Space $Space -Name $Service.Name
            Assert-VerifiableMock
        }
        It "Returns the first resource object" {
            (Get-Service -Space $Space -Name $Service.Name) | Should be $Service
        }
        It "Space from pipeline" {
            ($Space | Get-Service -Name $Service.Name) | Should be $Service
        }
    }
    Context "Parameter validation" {
        It "That Name cannot be empty" {
            { Get-Service -Space @{} -Name "" } | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty"
        }        
        It "That Name cannot be null" {
            { Get-Service -Space @{} -Name $null } | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty"
        }
        It "That Space cannot be null" {
            { Get-Service -Space $null -Name "foo" } | Should -Throw "Cannot validate argument on parameter 'Space'. The argument is null or empty"
        }
    }    
}