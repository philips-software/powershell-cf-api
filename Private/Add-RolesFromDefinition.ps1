<#
.Synopsis
   Adds roles from a definition
.DESCRIPTION
   The Add-RolesFromDefinition cmdlet will create roles if they do not exist
.PARAMETER UserNames
    This parameter is an array of users names
.PARAMETER RoleName
    This parameter is the name of the role
#>
function Add-RolesFromDefinition {

    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        $UserNames,

        [Parameter( Position = 1, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $RoleName
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        foreach ($u in $UserNames) {
            $roles = Get-SpaceRoles -Space $space -Role $RoleName
            $role = Find-SpaceRoleByUsername $roles $u
            if ($null -eq $role) {
                Set-SpaceRole -Space $space -Username $u -Role $rolename
            } else {
                Write-Verbose "Publish-Space: '$($u)' is already in '$($rolename)', skipping"
            }
        }    
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }        
}