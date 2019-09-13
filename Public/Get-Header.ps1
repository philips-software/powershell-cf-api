<#
.Synopsis
   Gets the header for a rest calls
.DESCRIPTION
   The Get-Header cmdlet gets the script level variables and handles refresh tokens if nessesary
.PARAMETER Token
    This is the auth token object
#>
function Get-Header {

    [CmdletBinding()]
    [OutputType([psobject])]
    param()

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $header = Get-Variable -Scope Script -Name headers -ValueOnly
        if ($null -eq $header) {
            $message = "header is not set in script varaible. Call Get-Credentials first"
            Write-Error -Message $message
            throw $message
        }

        $token = Get-Variable -Scope Script -Name token -ValueOnly
        if ($null -eq $token) {
            $message = "token is not set in script varaible. Call Get-Credentials first"
            Write-Error -Message $message
            throw $message
        }
        $tokenExpiresAt = Get-Variable -Scope Script -Name tokenExpiresAt -ValueOnly
        
        $now = Get-Date
        Write-Debug "$($now) $($tokenExpiresAt)"
        if ($now -gt $tokenExpiresAt) {
            Write-Debug "*************** Refresh Token *************** "
            $url = Get-Variable -Scope Script -Name oAuthTokenEndpoint -ValueOnly
            $body = "grant_type=refresh_token&refresh_token=$($token.refresh_token)"            
            $refreshHeader = @{
                "Authorization"="Basic Y2Y6"
                "Accept"="application/json"
                "Content-Type"="application/x-www-form-urlencoded; charset=UTF-8"
            }
            $response = Invoke-Retry -ScriptBlock {
                Write-Output (Invoke-WebRequest -uri $url -Method Post -Header $refreshHeader -Body $body )
            }            
            Write-Debug $response
            if ($response.StatusCode -ne 200) {
                $message = "$($url) $($response.StatusCode)"
                Write-Error -Message $message
                throw $message
            }
            $token = ($response | ConvertFrom-Json)
            $header = Set-Headers $token
        }
        return $header
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}
