<#
.Synopsis
   Gets the CloudFoundry space summary
.DESCRIPTION
   The Get-SpaceSummary cmdlet gets a space summary for a given space
.PARAMETER Space
    This parameter is the Space object
.EXAMPLE
   Get-Space "myspace" | Get-SpaceSummary | ConvertTo-Json
#>
function Get-SpaceSummary {

    [CmdletBinding()]
    [OutputType([psobject[]])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Space
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        Write-Output (Invoke-GetRequest "/v2/spaces/$($space.metadata.guid)/summary")
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
