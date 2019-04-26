<#
.Synopsis
   Waits for a cloud foundry service to complete creation
.DESCRIPTION
   The Wait-CreateService cmdlet waits for a service instance to complete creation
.PARAMETER Space
    This parameter is the Space object
.PARAMETER ServiceInstance
    This parameter is the service instance object
.PARAMETER Seconds
    This parameter is how long many seconds between each poll. Defaults to 3s.
.PARAMETER Timeout
    This parameter is how long in minutes before the command will timeout. Defaults to 15m
#>
function Wait-CreateService {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Space,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $ServiceInstance,

        [Parameter()]
        [Int]
        $Seconds = 3,

        [Parameter()]
        [Int]
        $Timeout = 15
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $startDate = Get-Date
        do {
            $summary = Get-SpaceSummary -Space $Space
            $operation = $summary.services | Where-Object {$_.name -eq $ServiceInstance.entity.name } | Select-Object -first 1 | Select-Object -Property last_operation | ConvertTo-Json | ConvertFrom-Json
            Write-Verbose "service instance '$($serviceinstance.entity.name)' $($operation.last_operation.type) $($operation.last_operation.state)..."
            if ($operation.last_operation.state -ne 'in progress') {
                Write-Verbose "Wait-CreateService: complete"
                return
            }
            Start-Sleep -Seconds $Seconds
        } while ($startDate.AddMinutes($Timeout) -gt (Get-Date))
        $message = "Wait-CreateService: timeout"
        Write-Error -Message $message
        throw $message
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}
