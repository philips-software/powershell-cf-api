$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-SpaceRoles.ps1"
. "$source\..\Private\Invoke-GetRequest.ps1"

Describe "Get-SpaceRoles" {
    Context "API call" {
        $Space = New-Object PsObject -Property @{metadata=@{guid="1234"}}
        $RoleName = "role1"
        $SpaceRoles = @()
        Mock Invoke-GetRequest { $SpaceRoles } `
            -Verifiable -ParameterFilter {$path -eq "/v2/spaces/$($Space.metadata.guid)/$($RoleName)"}
        
        It "Called with the correct URL" {
            Get-SpaceRoles -Space $Space -Role $RoleName
            Assert-VerifiableMock
        }
        It "Returns the resources" {
            (Get-SpaceRoles -Space $Space -Role $RoleName) | Should be $SpaceRoles
        }
        It "Uses value from pipeline" {
            $Space | Get-SpaceRoles -Role $RoleName | Should be $SpaceRoles
        }
    }
    Context "Parameter validation" {
        It "That Role cannot be empty" {
            { Get-SpaceRoles -Space @() -Role "" } | Should -Throw "Cannot validate argument on parameter 'Role'. The argument is null or empty"
        }        
        It "That Role cannot be null" {
            { Get-SpaceRoles -Space @() -Role $null } | Should -Throw "Cannot validate argument on parameter 'Role'. The argument is null or empty"
        }
        It "That Space cannot be null" {
            { Get-SpaceRoles -Space $null -Role "role1" } | Should -Throw "Cannot validate argument on parameter 'Space'. The argument is null or empty"
        }
    }    
}