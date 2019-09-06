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
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Space,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Username,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Role
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

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
        Write-Output ($response | ConvertFrom-Json)        
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}
