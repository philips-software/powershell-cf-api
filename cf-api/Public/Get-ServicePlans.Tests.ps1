Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-ServicePlans.ps1"
    . "$PSScriptRoot\..\Private\Invoke-GetRequest.ps1"
}

Describe "Get-ServicePlans" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Service = [PSCustomObject]@{metadata=@{guid="123"}}
        $ServicePlan = New-Object PsObject
        $ServicePlans = @($ServicePlan)
        $invokeResponse = @([PSCustomObject]@{resources=@($ServicePlans)})
        Mock Invoke-GetRequest { $invokeResponse }
    }
    Context "API call" {
        It "is called with the correct URL" {
            Get-ServicePlans -Service $Service
            Should -Invoke Invoke-GetRequest -ParameterFilter {$path -eq "/v2/service_plans?q=service_guid%3A$($Service.metadata.guid)"}
        }
        It "returns the resource objects" {
            (Get-ServicePlans -Service $Service) | Should -Be $ServicePlans
        }
    }
    Context "parameters" {
        It "ensures 'Service' cannot be null" {
            { Get-ServicePlans -Service $null } | Should -Throw "*The argument is null or empty*"
        }
        It "supports positional" {
            Get-ServicePlans $Service | Should -Be $ServicePlans
        }
        It "supports 'Service' from pipeline" {
            $Service | Get-ServicePlans | Should -Be $ServicePlans
        }
    }
}