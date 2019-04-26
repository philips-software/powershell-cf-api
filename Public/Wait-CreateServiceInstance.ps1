<#
.Synopsis
   Creates a new service and waits for completion
.DESCRIPTION
   The Wait-CreateServiceInstance cmdlet waits for a service instance to complete creation
.PARAMETER Space
    This parameter is the Space object
.PARAMETER ServiceName
    This parameter is the service name
.PARAMETER Plan
    This parameter is the plan name
.PARAMETER Name
    This parameter is the service instance name
#>
function Wait-CreateServiceInstance {

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
        $ServiceName,

        [Parameter(Mandatory)]
        [String]
        $Plan,

        [Parameter(Mandatory)]
        [String]
        $Name
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $serviceinstance = New-ServiceAsync -Space $space -ServiceName $servicename -Plan $plan -Name $name
        Wait-CreateService -Space $space -ServiceInstance $serviceinstance
        Write-Output $serviceinstance
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}
