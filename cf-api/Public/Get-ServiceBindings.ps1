<#
.Synopsis
   Gets the CloudFoundry ServiceBindings for an app
.DESCRIPTION
   The Get-ServiceBindings cmdlet gets the service binding objects from the CloudFoundry API as defined by the API.
.PARAMETER App
    This parameter is the App object
.EXAMPLE
   Get-Space "myspace" | Get-App -Name "myapp" | Get-ServiceBindings | ConvertTo-Json
#>
function Get-ServiceBindings {

    [CmdletBinding()]
    [OutputType([psobject[]])]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $App
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        Write-Output @((Invoke-GetRequest "$($app.entity.service_bindings_url)").resources)
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
