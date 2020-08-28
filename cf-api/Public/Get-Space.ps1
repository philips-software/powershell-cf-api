<#
.Synopsis
   Gets a CloudFoundry Space object
.DESCRIPTION
   The Get-Space cmdlet gets the App object from the CloudFoundry API
.PARAMETER Org
    This parameter is a org object
.PARAMETER Name
    This parameter is the name of the space
.EXAMPLE
    Get-Space -Name "myspace" | ConvertTo-Json
#>
function Get-Space {

    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        ((Invoke-GetRequest "/v2/spaces?order-by=name&q=name%3A$($Name)").resources[0])
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}