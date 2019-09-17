

<#
.Synopsis
   Set the headers for all rest calls from the CloudFoundry UAA token
.DESCRIPTION
   The Set-Headers cmdlet sets the script level headers required for all calls
.PARAMETER Token
    This is the auth token object
.PARAMETER ExpireSlewSeconds
    This is the offset to apply to get a new token. (Default is 30s)
#>
function Set-Headers {

    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory, Position=0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Token,

        [Parameter(Position = 1)]
        [int]
        $ExpireSlewSeconds = 30
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $header = @{
            "Authorization"="Bearer $($Token.access_token)"
            "Content-Type"="application/json"
            "Accept"="application/json"
        }
        Set-Variable -Name "headers" -Scope Script -Value $header
        Set-Variable -Name "token" -Scope Script -Value $Token
        $start = Get-Date
        $expiresAt = $start.AddSeconds($Token.expires_in - $ExpireSlewSeconds)
        Write-Debug "Token will expires at $($expiresAt)"
        Set-Variable -Name tokenExpiresAt -Scope Script -Value $expiresAt

        Write-Output $header
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}
