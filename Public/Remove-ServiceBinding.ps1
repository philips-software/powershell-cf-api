<#
.Synopsis
   Removes a service binding
.DESCRIPTION
   The Remove-ServiceBinding cmdlet removes a single service binding
.PARAMETER ServiceBinding
    This parameter is the Service Binding object
#>
function Remove-ServiceBinding {

    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory, Position=0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $ServiceBinding
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        $base = Get-BaseHost
        $url = "$($base)/v2/service_bindings/$($ServiceBinding.metadata.guid)?accepts_incomplete=true"
        $header = Get-Header
        $response = Invoke-Retry -ScriptBlock {
            Write-Output (Invoke-WebRequest -Uri $url -Method Delete -Header $header)
        }        
        Write-Debug $response
        if ($response.StatusCode -ne 204) {
            $message = "Remove-ServiceBinding: $($url) $($response.StatusCode)"
            Write-Error -Message $message
            throw $message
        }
        Write-Output ($response.content | ConvertFrom-Json)    
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}

