<#
.Synopsis
   Set the roles in a space
.DESCRIPTION
   The Set-SpaceRole cmdlet sets the roles in a space
.PARAMETER Space
    This parameter is the Space object
.PARAMETER Username
    This parameter is the username
.PARAMETER Role
    This parameter is the role name
#>
function Set-SpaceRole {

    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Space,
        
        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Username,

        [Parameter(Mandatory, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Role
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        $path = ($Space.entity | Select-Object -ExpandProperty "$($Role)_url")
        $base = Get-BaseHost
        $url = "$($base)$($path)"
        $body = @{"username" = $Username }
        $header = Get-Header
        $response = Invoke-Retry -ScriptBlock {
            Write-Output (Invoke-WebRequest -Uri $url -Method 'Put' -Header $header -Body ($body | ConvertTo-Json))
        }
        Write-Debug $response
        if ($response.StatusCode -ne 201) {
            $message = "Set-SpaceRole: $($url) $($response.StatusCode)"
            Write-Error -Message $message
            throw $message
        }
        Write-Output ($response.content | ConvertFrom-Json)        
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}
