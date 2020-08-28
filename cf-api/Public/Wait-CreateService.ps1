<#
.Synopsis
   Waits for a cloud foundry service to complete creation
.DESCRIPTION
   The Wait-CreateService cmdlet waits for a service instance to complete creation
.PARAMETER Space
    This parameter is the Space object
.PARAMETER ServiceInstance
    This parameter is the service instance object
.PARAMETER Seconds
    This parameter is how long many seconds between each poll. Defaults to 3s.
.PARAMETER Timeout
    This parameter is how long in minutes before the command will timeout. Defaults to 15m
#>
function Wait-CreateService {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Space,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $ServiceInstance,

        [Parameter(Position = 2)]
        [Int]
        $Seconds = 3,

        [Parameter(Position = 3)]
        [Int]
        $Timeout = 900
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        {
            $summary = Get-SpaceSummary -Space $Space
            $operation = $summary.services | Where-Object {$_.name -eq $ServiceInstance.entity.name } | Select-Object -first 1 | Select-Object -Property last_operation | ConvertTo-Json | ConvertFrom-Json
            Write-Verbose "service instance $($serviceinstance.entity.name)"
            Write-Verbose "last operation = $($operation.last_operation.type)"
            Write-Verbose "last state = $($operation.last_operation.state)"
            ($operation.last_operation.state -ne 'in progress')
        } | Wait-Until -Seconds $Seconds -Timeout $Timeout
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
