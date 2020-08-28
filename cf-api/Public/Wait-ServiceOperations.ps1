<#
.Synopsis
   Waits for all service operations in a space to complete
.DESCRIPTION
   The Wait-ServiceOperations cmdlet will wait until all service operations to complete or a timeout occurs
.PARAMETER Space
    This parameter is the Space object
.PARAMETER Seconds
    This parameter is how long many seconds between each poll. Defaults to 3s.
.PARAMETER Timeout
    This parameter is how long in seconds before the command will timeout. Defaults to 15m
#>
function Wait-ServiceOperations {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Space,

        [Parameter(Position = 1)]
        [Int]
        $Seconds = 3,

        [Parameter(Position = 2)]
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
            (@($summary.services | Where-Object {[Bool]($_.PsObject.Properties.name -match "service_plan")} | Where-Object { $_.last_operation.state -eq 'in progress' }).count -eq 0)
        } | Wait-Until -Seconds $Seconds -Timeout $Timeout
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
