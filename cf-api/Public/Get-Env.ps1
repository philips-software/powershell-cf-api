<#
.Synopsis
   Gets a CloudFoundry Env object for an App
.DESCRIPTION
   The Get-Env cmdlet gets the Env object from the CloudFoundry API
.PARAMETER App
    This parameter is a App object
#>
function Get-Env {

    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $App
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        Write-Output (Invoke-GetRequest "/v2/apps/$($App.metadata.guid)/env")
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}