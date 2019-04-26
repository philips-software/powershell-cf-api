<#
.Synopsis
   Creates a new service and waits for completion
.DESCRIPTION
   The Wait-JobStatus cmdlet waits for a service instance to complete creation
.PARAMETER Job
    This parameter is the Job object
.PARAMETER ForStatus
    This parameter is the status name to wait. (the default is 'finished')
.PARAMETER Seconds
    This parameter is how long many seconds between each poll. Defaults to 3s.
.PARAMETER Timeout
    This parameter is how long in minutes before the command will timeout. Defaults to 15m
#>
function Wait-JobStatus {

    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Job,
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        $ForStatus = "finished",

        [Parameter()]
        [Int]
        $Seconds = 3,

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
            $jobStatus = Get-Job -Job $job
            if (($jobStatus.entity.status -eq $forStatus) -or ($jobStatus.entity.status -eq 'failed')) {
                Write-Verbose "Wait-Job: complete"
                Write-Output $jobStatus
                return
            }
            Start-Sleep -Seconds $seconds
        } while ($startDate.AddMinutes($timeout) -gt (Get-Date))
        $message = "Wait-Job: timeout"
        Write-Error -Message $message
        throw $message    
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}
