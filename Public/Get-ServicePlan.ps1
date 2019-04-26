<#
.Synopsis
   Gets the CloudFoundry service plan for a service
.DESCRIPTION
   The Get-ServicePlan cmdlet gets a service plan for a given service instance from the CloudFoundry API as defined by the API.
.PARAMETER Service
    This parameter is the Service object
#>
function Get-ServicePlan {

    [CmdletBinding()]
    [OutputType([psobject[]])]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Service
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        Write-Output @((Invoke-GetRequest "/v2/service_plans?q=service_guid%3A$($Service.metadata.guid)").resources)
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}
