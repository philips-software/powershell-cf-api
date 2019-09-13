<#
.Synopsis
   Gets the CloudFoundry service plans for a service
.DESCRIPTION
   The Get-ServicePlans cmdlet gets the service plans for a given service instance from the CloudFoundry API as defined by the API.
.PARAMETER Service
    This parameter is the Service object
#>
function Get-ServicePlans {

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
