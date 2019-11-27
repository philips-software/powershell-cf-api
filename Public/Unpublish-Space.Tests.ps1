$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Unpublish-Space.ps1"
. "$source\Get-Space.ps1"
. "$source\Remove-AllServiceBindings.ps1"
. "$source\Remove-Service.ps1"
. "$source\Get-ServiceInstance.ps1"
. "$source\Wait-ServiceOperations.ps1"
. "$source\Wait-RemoveSpace.ps1"

Describe "UnPublish-Space" {
    $TargetOrg = [PSCustomObject]@{name="myorg"}
    $TargetSpace = [PSCustomObject]@{}
    $TargetUserServices = @()
    $TargetService = [PSCustomObject]@{name="service1"}
    $TargetServices = @($TargetService)
    $TargetDeveloperRoles = @([PSCustomObject]@{})
    $TargetManagerRoles = @([PSCustomObject]@{})
    $TargetAuditorRoles = @([PSCustomObject]@{})
    $TargetServiceInstance = [PSCustomObject]@{guid="1"}
    $TargetDefinition = [PSCustomObject]@{
        name="myspace"
        services=$TargetServices
        userservices=$TargetUserServices        
        roles=@{
            developers=$TargetDeveloperRoles
            managers=$TargetManagerRoles
            auditors=$TargetAuditorRoles
        }
    }
    Mock Remove-AllServiceBindings
    Mock Remove-Service
    Mock Wait-ServiceOperations
    Mock Wait-RemoveSpace
    Mock Get-ServiceInstance
    Context "calls dependenct cmdlets" {        
        It "skips when space does not exist" {
            Mock Get-Space -Verifiable -ParameterFilter { $Name -eq $TargetDefinition.name }
            UnPublish-Space -Org $TargetOrg -Definition $TargetDefinition
            Assert-VerifiableMock
        }
        It "removes all service bindings" {
            Mock Get-Space { $TargetSpace } -Verifiable -ParameterFilter { $Name -eq $TargetDefinition.name }
            Mock Remove-AllServiceBindings -Verifiable -ParameterFilter { $Space -eq $TargetSpace }
            Mock Get-ServiceInstance { $TargetServiceInstance } -Verifiable -ParameterFilter {$Space -eq $TargetSpace }
            Mock Remove-Service -Verifiable -ParameterFilter { $Guid -eq $TargetServiceInstance.guid }
            UnPublish-Space -Org $TargetOrg -Definition $TargetDefinition
            Assert-VerifiableMock
        }
        It "waits on all service operations" {
            Mock Get-Space { $TargetSpace } -Verifiable -ParameterFilter { $Name -eq $TargetDefinition.name }
            Mock Remove-AllServiceBindings -Verifiable -ParameterFilter { $Space -eq $TargetSpace }
            Mock Get-ServiceInstance { $TargetServiceInstance } -Verifiable -ParameterFilter {$Space -eq $TargetSpace }
            Mock Remove-Service -Verifiable -ParameterFilter { $Guid -eq $TargetServiceInstance.guid }
            Mock Wait-ServiceOperations -Verifiable -ParameterFilter { $Space -eq $TargetSpace -and $Timeout -eq 60 }
            UnPublish-Space -Org $TargetOrg -Definition $TargetDefinition
            Assert-VerifiableMock
        }
        It "waits on space removal" {
            Mock Get-Space { $TargetSpace } -Verifiable -ParameterFilter { $Name -eq $TargetDefinition.name }
            Mock Remove-AllServiceBindings -Verifiable -ParameterFilter { $Space -eq $TargetSpace }
            Mock Get-ServiceInstance { $TargetServiceInstance } -Verifiable -ParameterFilter {$Space -eq $TargetSpace }
            Mock Remove-Service -Verifiable -ParameterFilter { $Guid -eq $TargetServiceInstance.guid }
            Mock Wait-RemoveSpace -Verifiable -ParameterFilter { $Space -eq $TargetSpace -and $Timeout -eq 60 }
            UnPublish-Space -Org $TargetOrg -Definition $TargetDefinition
            Assert-VerifiableMock
        }
    }
    Context "parameters" {
        It "ensures 'Org' is not null" {
            { Unpublish-Space -Org $null -Definition $TargetDefinition } | Should -Throw "Cannot validate argument on parameter 'Org'. The argument is null or empty"
        }
        It "ensures 'Definition' is not null" {
            { Unpublish-Space -Org $TargetOrg  -Definition $null } | Should -Throw "Cannot validate argument on parameter 'Definition'. The argument is null or empty"
        }
        It "supports positional" {
            { Unpublish-Space $TargetOrg $TargetDefinition 30 }
        }
        It "supports 'Org' from pipeline" {
            { $TargetOrg | Unpublish-Space -Definition $TargetDefinition }
        }

    }
}
