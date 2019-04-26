<#
.Synopsis
   Gets a CloudFoundry Service object
.DESCRIPTION
   The Get-Service cmdlet gets the service object from the CloudFoundry API as defined by the API.
.PARAMETER Space
    This parameter is the space object
.PARAMETER Name
    This parameter is the name of the service
.EXAMPLE
   $service = Get-Service -Space $space -Name "hsdp-rabbitmq"
#>
function Get-Service {

    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Space,

        [Parameter( Position = 1, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        Write-Output (Invoke-GetRequest "/v2/spaces/$($space.metadata.guid)/services?q=label%3A$($name)").resources[0]
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}
