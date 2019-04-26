<#
.Synopsis
   Publish a CloudFoundry space using a definition
.DESCRIPTION
   The Publish-Space cmdlet creates a new space and all defined service instances and user provided services
.PARAMETER Org
    This parameter is a org object
.PARAMETER Definition
    This parameter is the object that defines the Definition of the space
#>
function Publish-Space {

    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Org,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Definition
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        
        $space = Get-Space -Name $Definition.name
        if ($null -eq $space) {
            $space = New-Space -Org $org -Name $Definition.name
        } else {
            Write-Verbose "Publish-Space: '$($Definition.name)' exists, skipping"
        }
        Add-RolesFromDefinition $Definition.roles.developers "developers" | Out-Null
        Add-RolesFromDefinition $Definition.roles.managers "managers" | Out-Null
        Add-RolesFromDefinition $Definition.roles.auditors "auditors" | Out-Null
        foreach ($s in $Definition.services) {
            $serviceInstance = Get-ServiceInstance -Space $space -Name $s.name
            if ($null -eq $serviceInstance) {
                New-ServiceAsync -Space $space -ServiceName $s.service -Plan $s.plan -Name $s.name -Params $s.params | Out-Null
            } else {
                Write-Information "Publish-Space: service '$($s.name)' exists, skipping"
            }        
        }
        foreach ($s in $Definition.userservices) {
            $serviceInstance = Get-ServiceInstance -Space $space -Name $s.name
            if ($null -eq $serviceInstance) {
                New-UserProvidedService -Space $space -Name $s.name -Params $s.params -SyslogDrainUrl $s.syslog_drain_url -RouteServiceUrl $s.route_service_url | Out-Null
            } else {
                Write-Information "Publish-Space: userservice '$($s.name)' exists, skipping"
            } 
        }
        Wait-ServiceOperations -Space $space | out-null
        Write-Information "2"
        Write-Information "published space $($Definition.name)"
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}