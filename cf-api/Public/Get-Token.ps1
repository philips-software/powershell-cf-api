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
.PARAMETER Passcode
    Authenticate using a one time password.
    This is common when using SSO for authentication.
    The OTP can be retrieved at /passcode.
    http://docs.cloudfoundry.org/api/uaa/version/74.18.0/index.html#one-time-passcode
.PARAMETER CloudFoundryAPI
    This parameter is the cloud foundry api endpoint to use
.EXAMPLE
   $token = Get-Token "bjones" "SD*&@#@kdfj$" "https://example.com"
.EXAMPLE
   $token = Get-Token -Passcode "AbCDEfGH" "https://example.com"
#>
function Get-Token {

    [CmdletBinding(DefaultParameterSetName = "UserAndPassword")]
    [OutputType([psobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '', Justification = 'needed to collect')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'needed to collect')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUsernameAndPasswordParams', '', Justification = 'needed to collect')]
    param(
        [Parameter( Position = 0, Mandatory, ParameterSetName = "UserAndPassword")]
        [ValidateNotNullOrEmpty()]
        [String]
        $Username,

        [Parameter( Position = 1, Mandatory, ParameterSetName = "UserAndPassword")]
        [ValidateNotNullOrEmpty()]
        [String]
        $Password,

        [Parameter( Position = 0, Mandatory, ParameterSetName = "Passcode")]
        [ValidateNotNullOrEmpty()]
        [String]
        $Passcode,


        [Parameter( Position = 2, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $CloudFoundryAPI
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        # obtain an access token
        Write-Verbose "Logging into into $($CloudFoundryAPI)"
        Set-Variable -Name baseHost -Scope Script -Value $CloudFoundryAPI
        $url = "$($CloudFoundryAPI)/v2/info"
        Write-Debug $url
        $header = @{
            "Authorization" = "Basic Y2Y6"
            "Accept"        = "application/json"
            "Content-Type"  = "application/x-www-form-urlencoded; charset=UTF-8"
        }
        $response = Invoke-Retry -ScriptBlock {
            Write-Output (Invoke-WebRequest -Uri $url -Method Get -Header $header)
        }
        if ($response.StatusCode -ne 200) {
            $message = "$($url) $($response.StatusCode)"
            Write-Error $message
            throw $message
        }
        $url = ($response.Content | ConvertFrom-Json).authorization_endpoint + "/oauth/token"
        Set-Variable -Name oAuthTokenEndpoint -Scope Script -Value $url

        switch ($PsCmdLet.ParameterSetName) {
            "UserAndPassword" {
                $body = "grant_type=password&password=$Password&scope=&username=$Username"; break
            }
            "Passcode" {
                $body = "grant_type=password&passcode=$Passcode&token_format=jwt"; break
            }
            Default { throw "Uncaught ParameterSet" }
        }


        $response = Invoke-Retry -ScriptBlock {
            Write-Output (Invoke-WebRequest -Uri $url -Method Post -Header $header -Body $body)
        }
        if ($response.StatusCode -ne 200) {
            $message = "Get-Credentials: $($url) $($response.StatusCode)"
            Write-Error -Message $message
            throw $message
        }
        Write-Output $response.Content | ConvertFrom-Json
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
