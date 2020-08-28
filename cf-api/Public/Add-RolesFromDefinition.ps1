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
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Space,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        $UserNames,

        [Parameter( Mandatory, Position = 2)]
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
            $roles = Get-SpaceRoles -Space $Space -Role $RoleName
            $role = Find-SpaceRoleByUsername -Roles $roles -Name $u
            if ($null -eq $role) {
                Set-SpaceRole -Space $Space -Username $u -Role $RoleName
            } else {
                Write-Verbose "Publish-Space: '$($u)' is already in '$($rolename)', skipping"
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}