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
            $job = Remove-Space -Space $space
            Write-Debug $job | ConvertTo-Json
            $jobStatus = Wait-JobStatus -Job $job
            ($jobStatus.entity.status -ne 'failed')
        } | Wait-Until -Seconds $Seconds -Timeout $Timeout
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}
