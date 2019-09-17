$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-ServicePlans.ps1"
. "$source\..\Private\Invoke-GetRequest.ps1"

Describe "Get-ServicePlans" {
    $Service = [PSCustomObject]@{metadata=@{guid="123"}} 
    $ServicePlan = New-Object PsObject
    $ServicePlans = @($ServicePlan)
    $invokeResponse = @([PSCustomObject]@{resources=@($ServicePlans)})
    Mock Invoke-GetRequest { $invokeResponse } -Verifiable -ParameterFilter {$path -eq "/v2/service_plans?q=service_guid%3A$($Service.metadata.guid)"}
    Context "API call" {        
        It "is called with the correct URL" {
            Get-ServicePlans -Service $Service
            Assert-VerifiableMock
        }
        It "returns the resource objects" {
            (Get-ServicePlans -Service $Service) | Should be $ServicePlans
        }
    }
    Context "parameters" {
        It "ensures 'Service' cannot be null" {
            { Get-ServicePlans -Service $null } | Should -Throw "The argument is null or empty"
        }
        It "supports positional" {
            Get-ServicePlans $Service | Should be $ServicePlans
        }
        It "supports 'Service' from pipeline" {
            $Service | Get-ServicePlans | Should be $ServicePlans
        }
    }    
}