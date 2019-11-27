$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Find-SpaceRoleByUsername.ps1"

Describe "Get-SpaceRoleByUserName" {    
    $role1 = [PSCustomObject]@{entity=[PSCustomObject]@{username = "user1"}}
    $role2 = [PSCustomObject]@{entity=[PSCustomObject]@{username = "user2"}}
    $TargetRoles = [PSCustomObject]@{
        resources = @($role1;$role2)
    }
    Context "matches" {
        It "returns matching username" {
            Find-SpaceRoleByUserName -Roles $TargetRoles -Name "user2" | Should be $role2
        }
    }
    Context "parameters" {
        It "ensures 'Role' is not null" {
            { Find-SpaceRoleByUserName -Roles $null -Name "user2" } | Should -Throw "Cannot validate argument on parameter 'Roles'. The argument is null or empty"
        }
        It "ensures 'Name' is not empty" {
            { Find-SpaceRoleByUserName -Roles $TargetRoles -Name "" } | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty"
        }
        It "ensures 'Name' is not null" {
            { Find-SpaceRoleByUserName -Roles $TargetRoles -Name $null } | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty"
        }
        It "supports 'Roles' from pipeline" {
            $TargetRoles | Find-SpaceRoleByUserName -Name "user2" | Should be $role2
        }
        It "supports positional" {
            Find-SpaceRoleByUserName $TargetRoles "user2" | Should be $role2
        }
    }
}
