$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-SpaceRoles.ps1"
. "$source\..\Private\Invoke-GetRequest.ps1"

Describe "Get-SpaceRoles" {
    $Space = [PSCustomObject]@{metadata=@{guid="1234"}}
    $RoleName = "role1"
    $SpaceRoles = @()
    Mock Invoke-GetRequest { $SpaceRoles } -Verifiable -ParameterFilter {$path -eq "/v2/spaces/$($Space.metadata.guid)/$($RoleName)"}
    Context "API call" {        
        It "is called with the correct URL" {
            Get-SpaceRoles -Space $Space -Role $RoleName
            Assert-VerifiableMock
        }
        It "returns the resources" {
            (Get-SpaceRoles -Space $Space -Role $RoleName) | Should be $SpaceRoles
        }
    }
    Context "parameters" {
        It "ensures 'Role' cannot be empty" {
            { Get-SpaceRoles -Space @() -Role "" } | Should -Throw "Cannot validate argument on parameter 'Role'. The argument is null or empty"
        }        
        It "ensures 'Role' cannot be null" {
            { Get-SpaceRoles -Space @() -Role $null } | Should -Throw "Cannot validate argument on parameter 'Role'. The argument is null or empty"
        }
        It "ensures 'Space' cannot be null" {
            { Get-SpaceRoles -Space $null -Role "role1" } | Should -Throw "Cannot validate argument on parameter 'Space'. The argument is null or empty"
        }
        It "supports positional" {
            Get-SpaceRoles $Space $RoleName | Should be $SpaceRoles
        }
        It "supports 'Space' from pipeline" {
            $Space | Get-SpaceRoles -Role $RoleName | Should be $SpaceRoles
        }
    }    
}