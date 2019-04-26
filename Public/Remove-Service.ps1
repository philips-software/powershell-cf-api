<#
.Synopsis
   Removes a service using the guid
.DESCRIPTION
   The Remove-Service cmdlet removes a single service using a guid
.PARAMETER Guid
    This parameter is the guid of a service
#>
function Remove-Service {

    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Guid
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $base = Get-BaseHost
        $url = "$($base)/v2/service_instances/$($Guid)?accepts_incomplete=true&async=true"
        $header = Get-Header
        $response = (Invoke-WebRequest -Uri $url -Method Delete -Header $header)
        Write-Debug $response
        if (($response.StatusCode -ne 204) -and ($response.StatusCode -ne 202)) {
            $message = "Remove-Service: $($url) $($response.StatusCode)"
            Write-Error -Message $message
            throw $message
        }
        Write-Output ($response | ConvertFrom-Json)            
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}

