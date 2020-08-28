Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-SpaceRoles.ps1"
    . "$PSScriptRoot\..\Private\Invoke-GetRequest.ps1"
}

Describe "Get-SpaceRoles" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Space = [PSCustomObject]@{metadata=@{guid="1234"}}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $RoleName = "role1"
        $SpaceRoles = @()
        Mock Invoke-GetRequest { $SpaceRoles }
    }
    Context "API call" {
        It "is called with the correct URL" {
            Get-SpaceRoles -Space $Space -Role $RoleName
            Should -Invoke Invoke-GetRequest -ParameterFilter {$path -eq "/v2/spaces/$($Space.metadata.guid)/$($RoleName)"}
        }
        It "returns the resources" {
            (Get-SpaceRoles -Space $Space -Role $RoleName) | Should -Be $SpaceRoles
        }
    }
    Context "parameters" {
        It "ensures 'Role' cannot be empty" {
            { Get-SpaceRoles -Space @() -Role "" } | Should -Throw "*Cannot validate argument on parameter 'Role'. The argument is null or empty*"
        }
        It "ensures 'Role' cannot be null" {
            { Get-SpaceRoles -Space @() -Role $null } | Should -Throw "*Cannot validate argument on parameter 'Role'. The argument is null or empty*"
        }
        It "ensures 'Space' cannot be null" {
            { Get-SpaceRoles -Space $null -Role "role1" } | Should -Throw "*Cannot validate argument on parameter 'Space'. The argument is null or empty*"
        }
        It "supports positional" {
            Get-SpaceRoles $Space $RoleName | Should -Be $SpaceRoles
        }
        It "supports 'Space' from pipeline" {
            $Space | Get-SpaceRoles -Role $RoleName | Should -Be $SpaceRoles
        }
    }
}