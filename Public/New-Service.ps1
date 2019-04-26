<#
.Synopsis
   Creates a new cloud foundry service
.DESCRIPTION
   The New-Service cmdlet creates a new service and returns the service object as defined by the API
.PARAMETER Space
    This parameter is the Space object
.PARAMETER ServicePlans
    This parameter is the available service plans for the space
.PARAMETER Plan
    This parameter is the the name of the plan to use
.PARAMETER Name
    This parameter is the the name of the service instance
.PARAMETER params
    This parameter is an dictionary of the parameters
.EXAMPLE  

#>
function New-Service {

    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Space,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [psobject[]]
        $ServicePlans,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Plan,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        $params = @()
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $serviceplan = $ServicePlans | Where-Object {$_.entity.name -eq $Plan}
        if ($serviceplan.Count -eq 0) {
            $message = "New-Service: $($url) $($response.StatusCode)"
            Write-Error -Message $message
            throw $message
        }
        $base = Get-BaseHost        
        $url = "$($base)/v2/service_instances?accepts_incomplete=true"
        $body = @{      
            "name" = $Name
            "parameters" = $Params
            "service_plan_guid" = $serviceplan[0].metadata.guid
            "space_guid" = $Space.metadata.guid
        } 
        $header = Get-Header
        $response = (Invoke-WebRequest -Uri $url -Method Post -Header $header -Body ($body | ConvertTo-Json))
        Write-Debug $response
        if (($response.StatusCode -ne 202) -and ($response.StatusCode -ne 201)) {
            $message = "New-Service: $($url) $($response.StatusCode)"
            Write-Error -Message $message
            throw $message
        }
        Write-Output ($response | ConvertFrom-Json) 
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}
