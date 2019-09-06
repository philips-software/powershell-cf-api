<#
.Synopsis
   This cmdlet gets a cloudfoundry token
.DESCRIPTION
   Logs into cloudfoundry sets the script level variables for the header and returns it
.PARAMETER URL
    The API end point for the CloudFoundry org
.PARAMETER Username
    This parameter is used to identify the username to authenticate
.PARAMETER Password
    This parameter is used to identify the username's password to authenticate
.PARAMETER CloudFoundryAPI
    This parameter is the cloud foundry api endpoint to use
.EXAMPLE
   $token = Get-Token "Wellcentive" "bjones" "SD*&@#@kdfj$"
#>
function Get-Token {

    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter( Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Username,

        [Parameter( Position = 1, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Password,

        [Parameter( Position = 2, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $CloudFoundryAPI
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"        
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        # obtain an access token
        Write-Verbose "Logging into into $($CloudFoundryAPI)"
        Set-Variable -Name baseHost -Scope Script -Value $CloudFoundryAPI
        $url = "$($CloudFoundryAPI)/v2/info"
        Write-Debug $url
        $headers = @{
            "Authorization"="Basic Y2Y6"
            "Accept"="application/json"
            "Content-Type"="application/x-www-form-urlencoded; charset=UTF-8"
        }
        $response = Invoke-Retry -ScriptBlock {
            Write-Output (Invoke-WebRequest -uri $url -Method Get -Header $headers)
        }       
        if ($response.StatusCode -ne 200) {
            $message = "$($url) $($response.StatusCode)"
            Write-Error $message
            throw $message
        }
        $url = ($response | ConvertFrom-Json).authorization_endpoint + "/oauth/token"
        Set-Variable -Name oAuthTokenEndpoint -Scope Script -Value $url
        $body = "grant_type=password&password=$($Password)&scope=&username=$($Username)"
        $response = Invoke-Retry -ScriptBlock {
            Write-Output (Invoke-WebRequest -uri $url -Method Post -Header $headers -Body $body)
        }        
        Write-Debug $response

        if ($response.StatusCode -ne 200) {
            $message = "Get-Credentials: $($url) $($response.StatusCode)"
            Write-Error -Message $message
            throw $message
        }                    
        Write-Output $response | ConvertFrom-Json
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}