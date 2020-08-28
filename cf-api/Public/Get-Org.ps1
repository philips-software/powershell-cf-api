<#
.Synopsis
   Gets a CloudFoundry org object
.DESCRIPTION
   The Get-Org cmdlet gets the org object from the CloudFoundry API as defined by the API.
.PARAMETER Name
    This parameter is used to identify the org name to retrieve
.EXAMPLE
   $org = Get-Org -Name "Wellcentive"
#>
function Get-Org {

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
        Write-Output (Invoke-GetRequest "/v2/organizations?order-by=name&q=name%3A$($name)").resources[0]
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}