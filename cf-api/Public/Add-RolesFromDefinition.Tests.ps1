Set-StrictMode -Version Latest

BeforeAll {
. "$PSScriptRoot\Add-RolesFromDefinition.ps1"
. "$PSScriptRoot\Get-SpaceRoles.ps1"
. "$PSScriptRoot\Find-SpaceRoleByUsername.ps1"
. "$PSScriptRoot\Set-SpaceRole.ps1"
}

Describe "Add-RolesFromDefinition" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetSpace = [PSCustomObject]@{}
        $role1 = [PSCustomObject]@{entity=[PSCustomObject]@{username = "user1"}}
        $role2 = [PSCustomObject]@{entity=[PSCustomObject]@{username = "user2"}}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetRoles = [PSCustomObject]@{resources = @($role1;$role2)}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetUserNames = @("user1")
        Mock Get-SpaceRoles { $TargetRoles }
        Mock Set-SpaceRole
    }
    Context "space role does not exist" {
        It "sets space role" {
            Mock Find-SpaceRoleByUsername { $null }
            Mock Set-SpaceRole
            Add-RolesFromDefinition -Space $TargetSpace -UserNames $TargetUserNames -RoleName "role1"
            Should -Invoke Set-SpaceRole -ParameterFilter {
                $Space -eq $TargetSpace -and `
                $Username -eq "user1" -and `
                $Role -eq "role1"
            }
        }
    }
    Context "space role exists" {
        It "does not set space role" {
            Mock Find-SpaceRoleByUsername { $role1 }
            Add-RolesFromDefinition -Space $TargetSpace -UserNames $TargetUserNames -RoleName "role1"
            Should -Invoke Set-SpaceRole -Times 0 -Exactly
        }
    }
    Context "parameters" {
        It "ensures 'Space' is not null" {
            { Add-RolesFromDefinition -Space $null -UserNames $TargetUserNames -RoleName "role1" } | Should -Throw "*Cannot validate argument on parameter 'Space'. The argument is null or empty*"
        }
        It "ensures 'UserNames' is not empty" {
            { Add-RolesFromDefinition -Space $TargetSpace -UserNames @() -RoleName "role1" } | Should -Throw "*Cannot validate argument on parameter 'UserNames'. The argument is null, empty, or an element of the argument collection contains a null value*"
        }
        It "ensures 'RoleName' is not empty" {
            { Add-RolesFromDefinition -Space $TargetSpace -UserNames $TargetUserNames -RoleName "" } | Should -Throw "*Cannot validate argument on parameter 'RoleName'. The argument is null or empty*"
        }
        It "ensures 'RoleName' is not null" {
            { Add-RolesFromDefinition -Space $TargetSpace -UserNames $TargetUserNames -RoleName $null } | Should -Throw "*Cannot validate argument on parameter 'RoleName'. The argument is null or empty*"
        }
        It "supports 'Space' from pipeline" {
            Mock Find-SpaceRoleByUsername { $role1 }
            $TargetUserNames = @("user1")
            $TargetSpace | Add-RolesFromDefinition -UserNames $TargetUserNames -RoleName "role1"
        }
        It "supports positional" {
            Mock Find-SpaceRoleByUsername { $role1 }
            $TargetUserNames = @("user1")
            Add-RolesFromDefinition $TargetSpace $TargetUserNames "role1"
        }
    }

}