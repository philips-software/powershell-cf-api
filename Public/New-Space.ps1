<#
.Synopsis
   Creates a new cloud foundry space
.DESCRIPTION
   The New-Space cmdlet creates a new space and returns the space object
.PARAMETER Org
    This parameter is the Org object
.PARAMETER Name
    This parameter is the name of the new space
.EXAMPLE
    $space = (Get-Org -Name "myorg" | New-Space "myspace")
#>
function New-Space {

    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Org,

        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $body = @{
            "organization_guid" = $Org.metadata.guid
            "name" = $Name
        } 
        $bodyJson = $body | ConvertTo-Json
        $base = Get-BaseHost
        $url = "$($base)/v2/spaces"
        
        $header = Get-Header
        $response = (Invoke-WebRequest -Uri $url -Method Post -Header $header -Body $bodyJson)
        Write-Debug $response
        if ($response.StatusCode -ne 201) {
            $message = "New-Space: $($url) $($response.StatusCode)"
            Write-Error -Message $message
            throw $message
        }
        Write-Output ($response | ConvertFrom-Json)        
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}
