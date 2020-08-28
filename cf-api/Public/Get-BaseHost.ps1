<#
.Synopsis
   Gets the base host url for CF API calls
.DESCRIPTION
   The Get-BaseHost cmdlet gets the script level variable for the base host for the CF API calls
#>
function Get-BaseHost {

    [CmdletBinding()]
    [OutputType([String])]
    param()

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        if ($null -eq $script:baseHost) {
            $message = "baseHost is not set in script variable. Call Get-Credentials first"
            throw $message
        }
        return $script:baseHost
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
