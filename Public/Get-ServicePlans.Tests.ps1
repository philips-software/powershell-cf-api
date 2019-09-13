$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-ServicePlans.ps1"
. "$source\..\Private\Invoke-GetRequest.ps1"

Describe "Get-ServicePlans" {
    Context "API call" {
        $Service = New-Object PsObject -Property @{metadata=@{guid="123"}} 
        $ServicePlan = New-Object PsObject
        $ServicePlans = @($ServicePlan)
        $invokeResponse = @(New-Object PsObject -Property @{resources=@($ServicePlans)})
        Mock Invoke-GetRequest { $invokeResponse } `
            -Verifiable -ParameterFilter {$path -eq "/v2/service_plans?q=service_guid%3A$($Service.metadata.guid)"}
        
        It "Called with the correct URL" {
            Get-ServicePlans -Service $Service
            Assert-VerifiableMock
        }
        It "Returns the resource objects" {
            (Get-ServicePlans -Service $Service) | Should be $ServicePlans
        }
        It "Uses Service from pipeline" {
            $Service | Get-ServicePlans | Should be $ServicePlans
        }
        It "Uses positional arguments" {
            Get-ServicePlans $Service | Should be $ServicePlans
        }
    }
    Context "Parameter validation" {
        It "That $Service cannot be null" {
            { Get-ServicePlans -Service $null } | Should -Throw "The argument is null or empty"
        }
    }    
}