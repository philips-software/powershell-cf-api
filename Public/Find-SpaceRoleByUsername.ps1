<#
.Synopsis
   Finds a role assinged to a user name
.DESCRIPTION
   The Find-SpaceRoleByUserName cmdlet gets the role where the username is assigned
.PARAMETER Roles
    This parameter is a Roles object
.PARAMETER Name
    This parameter is the name of the user
.EXAMPLE
   $role = Get-Space "myspace" | Get-SpaceRoles -Role "developers" | Find-SpaceRoleByUserName "mlindell"
#>
function Find-SpaceRoleByUsername {

    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Roles,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        return (@($Roles.resources | Where-Object {$_.entity.username -eq $Name})[0])
    }
 
    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }        
    
}