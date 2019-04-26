<#
.Synopsis
   Gets the CloudFoundry space roles
.DESCRIPTION
   The Get-SpaceRoles cmdlet gets a space roles for a given space and role name
.PARAMETER Space
    This parameter is the Space object
.PARAMETER Role
    This parameter is the Role name 
.EXAMPLE
   Get-Space "myspace" | Get-SpaceRoles -Role "developers" | ConvertTo-Json
#>
function Get-SpaceRoles {

    [CmdletBinding()]
    [OutputType([psobject[]])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]        
        [psobject]
        $Space,

        [Parameter( Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Role
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        Write-Output @(Invoke-GetRequest "/v2/spaces/$($Space.metadata.guid)/$($Role)")
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}
