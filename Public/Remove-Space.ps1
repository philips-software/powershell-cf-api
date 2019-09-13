<#
.Synopsis
   Removes a new cloud foundry space
.DESCRIPTION
   The Remove-Space cmdlet removes an existing space 
.PARAMETER Space
    This parameter is the Space object
.EXAMPLE
    Get-Space -Name "myspace" | Remove-Space
#>
function Remove-Space {

    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Space
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        $base = Get-BaseHost
        $url = "$($base)/v2/spaces/$($Space.metadata.guid)?async=true&recursive=true"
        $header = Get-Header
        $response = Invoke-Retry -ScriptBlock {
            Write-Output (Invoke-WebRequest -Uri $url -Method Delete -Header $header)
        }        
        Write-Debug $response
        if ($response.StatusCode -ne 202) {
            $message = "Remove-Space: $($url) $($response.StatusCode)"
            Write-Error -Message $message
            throw $message
        }
        Write-Output  $response | ConvertFrom-Json
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}
