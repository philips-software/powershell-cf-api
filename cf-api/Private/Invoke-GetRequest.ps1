
<#
.Synopsis
   Calls a Rest Get Web Request
.DESCRIPTION
   The Invoke-GetRequest cmdlet makes a get Rest call
.PARAMETER Path
    The url path to call (should not include the basehost address)
#>
function Invoke-GetRequest {

    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline )]
        [ValidateNotNullOrEmpty()]
        [String]
        $Path
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        $base = Get-BaseHost
        $url = "$($base)$($path)"
        $header = Get-Header
        $response = Invoke-Retry -ScriptBlock {
            Write-Output (Invoke-WebRequest -uri $url -Method Get -Header $header)
        }
        Write-Debug $response | ConvertTo-Json -Depth 20
        if ($response.StatusCode -ne 200) {
            $message = "$($function): $($url) $($response.StatusCode) expected 200"
            Write-Error -Message $message
            throw $message
        }
        Write-Output $response | ConvertFrom-Json 
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}