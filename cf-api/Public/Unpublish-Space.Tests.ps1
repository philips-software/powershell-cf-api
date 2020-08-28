Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Unpublish-Space.ps1"
    . "$PSScriptRoot\Get-Space.ps1"
    . "$PSScriptRoot\Remove-AllServiceBindings.ps1"
    . "$PSScriptRoot\Remove-Service.ps1"
    . "$PSScriptRoot\Get-ServiceInstance.ps1"
    . "$PSScriptRoot\Wait-ServiceOperations.ps1"
    . "$PSScriptRoot\Wait-RemoveSpace.ps1"
}
Describe "UnPublish-Space" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetOrg = [PSCustomObject]@{name="myorg"}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetSpace = [PSCustomObject]@{}
        $TargetUserServices = @()
        $TargetService = [PSCustomObject]@{name="service1"}
        $TargetServices = @($TargetService)
        $TargetDeveloperRoles = @([PSCustomObject]@{})
        $TargetManagerRoles = @([PSCustomObject]@{})
        $TargetAuditorRoles = @([PSCustomObject]@{})
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetServiceInstance = [PSCustomObject]@{guid="1"}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
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
    }
    Context "calls dependenct cmdlets" {
        It "skips when space does not exist" {
            Mock Get-Space
            UnPublish-Space -Org $TargetOrg -Definition $TargetDefinition
            Should -Invoke Get-Space -ParameterFilter { $Name -eq $TargetDefinition.name }
        }
        It "removes all service bindings" {
            Mock Get-Space { $TargetSpace }
            Mock Remove-AllServiceBindings
            Mock Get-ServiceInstance { $TargetServiceInstance }
            Mock Remove-Service
            UnPublish-Space -Org $TargetOrg -Definition $TargetDefinition
            Should -Invoke Get-Space -ParameterFilter { $Name -eq $TargetDefinition.name }
            Should -Invoke Remove-AllServiceBindings -ParameterFilter { $Space -eq $TargetSpace }
            Should -Invoke Get-ServiceInstance -ParameterFilter {$Space -eq $TargetSpace }
            Should -Invoke Remove-Service -ParameterFilter { $Guid -eq $TargetServiceInstance.guid }
        }
        It "waits on all service operations" {
            Mock Get-Space { $TargetSpace }
            Mock Remove-AllServiceBindings
            Mock Get-ServiceInstance { $TargetServiceInstance }
            Mock Remove-Service
            Mock Wait-ServiceOperations
            UnPublish-Space -Org $TargetOrg -Definition $TargetDefinition
            Should -Invoke Get-Space -ParameterFilter { $Name -eq $TargetDefinition.name }
            Should -Invoke Remove-AllServiceBindings -ParameterFilter { $Space -eq $TargetSpace }
            Should -Invoke Get-ServiceInstance -ParameterFilter {$Space -eq $TargetSpace }
            Should -Invoke Remove-Service -ParameterFilter { $Guid -eq $TargetServiceInstance.guid }
            Should -Invoke Wait-ServiceOperations -ParameterFilter { $Space -eq $TargetSpace -and $Timeout -eq 60 }
        }
        It "waits on space removal" {
            Mock Get-Space { $TargetSpace }
            Mock Remove-AllServiceBindings
            Mock Get-ServiceInstance { $TargetServiceInstance }
            Mock Remove-Service
            Mock Wait-RemoveSpace
            UnPublish-Space -Org $TargetOrg -Definition $TargetDefinition
            Should -Invoke Get-Space -ParameterFilter { $Name -eq $TargetDefinition.name }
            Should -Invoke Remove-AllServiceBindings -ParameterFilter { $Space -eq $TargetSpace }
            Should -Invoke Get-ServiceInstance -ParameterFilter {$Space -eq $TargetSpace }
            Should -Invoke Remove-Service -ParameterFilter { $Guid -eq $TargetServiceInstance.guid }
            Should -Invoke Wait-RemoveSpace -ParameterFilter { $Space -eq $TargetSpace -and $Timeout -eq 60 }
        }
    }
    Context "parameters" {
        It "ensures 'Org' is not null" {
            { Unpublish-Space -Org $null -Definition $TargetDefinition } | Should -Throw "*Cannot validate argument on parameter 'Org'. The argument is null or empty*"
        }
        It "ensures 'Definition' is not null" {
            { Unpublish-Space -Org $TargetOrg  -Definition $null } | Should -Throw "*Cannot validate argument on parameter 'Definition'. The argument is null or empty*"
        }
        It "supports positional" {
            { Unpublish-Space $TargetOrg $TargetDefinition 30 }
        }
        It "supports 'Org' from pipeline" {
            { $TargetOrg | Unpublish-Space -Definition $TargetDefinition }
        }
    }
}
