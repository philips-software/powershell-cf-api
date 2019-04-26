<#
.Synopsis
   Gets a CloudFoundry Job object
.DESCRIPTION
   The Get-Job  cmdlet gets the Job object from the CloudFoundry API as defined by the API.
.PARAMETER Name
    This parameter is used to identify the org name to retrieve
#>
function Get-Job {

    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline )]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Job
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        $response = Invoke-GetRequest "/v2/jobs/$($job.entity.guid)"
        Write-Output $response
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}