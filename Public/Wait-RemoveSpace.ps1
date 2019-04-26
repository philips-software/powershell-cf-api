<#
.Synopsis
   Removes a space and waits for the operation to complete
.DESCRIPTION
   The Wait-RemoveSpace cmdlet will remove a space and wait for it to complete
.PARAMETER Space
    This parameter is the Space object
.PARAMETER Timeout
    This parameter is how long in minutes before the command will timeout. Defaults to 15m
#>
function Wait-RemoveSpace {

    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Space,
        
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
            $job = Remove-Space -Space $space
            Write-Debug $job | ConvertTo-Json
            $jobStatus = Wait-JobStatus -Job $job
            if ($jobStatus.entity.status -ne 'failed') {
                Write-Verbose "Wait-RemoveSpace: complete"
                return $jobStatus
            }
            Write-Verbose "retry..."
        } while ($startDate.AddMinutes($timeout) -gt (Get-Date))
        $message = "Wait-RemoveSpace: timeout"
        Write-Error -Message $message
        throw $message
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}
