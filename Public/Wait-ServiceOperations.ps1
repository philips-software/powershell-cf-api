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
    This parameter is how long in minutes before the command will timeout. Defaults to 15m
#>
function Wait-ServiceOperations {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Space,
        
        [Parameter()]
        [Int]
        $Seconds = 10,

        [Parameter()]
        [Int]
        $Timeout = 15
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $startDate = Get-Date
        do {
            $summary = Get-SpaceSummary -Space $Space
            if (@($summary.services | Where-Object {[Bool]($_.PsObject.Properties.name -match "service_plan")} | Where-Object { $_.last_operation.state -eq 'in progress' }).count -eq 0) {
                Write-Verbose "Wait-ServiceOperations: complete"
                return $summary
            }
            Write-Verbose "$($summary.services | Where-Object {$_.last_operation.state -ne 'succeeded'})"
            Start-Sleep -Seconds $Seconds
        } while ($startDate.AddMinutes($Timeout) -gt (Get-Date))
        $message = "Wait-ServiceOperations: timeout"
        Write-Error -Message $message
        throw $message        
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}
