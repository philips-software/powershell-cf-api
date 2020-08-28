<#
.Synopsis
   Unpublishes a CloudFoundry space using a definition
.DESCRIPTION
   The Unpublish-Space cmdlet unpublishes a cloud foundry space using a definition
.PARAMETER Org
    This parameter is the Org object
.PARAMETER Definition
    This parameter is the space definition
#>
function Unpublish-Space {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Org,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Definition,

        [Parameter()]
        [Int]
        $Timeout = 60
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $space = Get-Space -Name $Definition.name
        if ($null -ne $space) {
            Remove-AllServiceBindings -Space $space
            foreach ($d in $Definition.services) {
                Remove-Service -Guid (Get-ServiceInstance -Space $space -Name $d.name).guid | Out-Null
            }
            Wait-ServiceOperations -Space $space -Timeout $Timeout| Out-Null
            Wait-RemoveSpace -Space $space -Timeout $Timeout | Out-Null
            Write-Information "Unpublished space $($Definition.name)"
        } else {
            Write-Debug "Space does not exist"
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
