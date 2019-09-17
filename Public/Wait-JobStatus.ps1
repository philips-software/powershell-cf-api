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
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Job,
        
        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ForStatus = "finished",

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
            $jobStatus = Get-Job -Job $Job
            (($jobStatus.entity.status -eq $forStatus) -or ($jobStatus.entity.status -eq 'failed'))
        } | Wait-Until -Seconds $Seconds -Timeout $Timeout
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}
