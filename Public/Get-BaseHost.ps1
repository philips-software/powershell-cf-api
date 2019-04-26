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

        $baseHost = Get-Variable -Scope Script -Name baseHost -ValueOnly
        if ($null -eq $baseHost) {
            $message = "baseHost is not set in script varaible. Call Get-Credentials first"
            Write-Error -Message $message
            throw $message
        }
        return $baseHost
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}
