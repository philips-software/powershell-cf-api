<#
.Synopsis
   Executes a script block and evalutes the result as a boolean.
   If the result is $true the block exists otherwise it repeats
   after pausing for a specified period of time. If the Timeout is reached
   then an exception is thrown and processing stops.
.DESCRIPTION
   The Wait-Until cmdlet will execute a script block until success
.PARAMETER ScriptBlock
    This parameter is a ScriptBlock that must return a boolean value
.PARAMETER Seconds
    This parameter is the number of seconds to pause after each attempt.
    The default is 5 seconds
.PARAMETER Timeout
    This parameter is the amount of time in minutes to continue to try
    the ScriptBlock before an timeout error is thrown.
.EXAMPLE
   Wait-Until { ((Invoke-WebRequest -uri $url -Method Get -Header $header).StatusCode -eq 200) }
#>
function Wait-Until {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [ScriptBlock]$ScriptBlock,

        [Parameter(Position = 1)]
        [Int32]$Seconds = 5,

        [Parameter(Position = 2)]
        [Int32]$Timeout= 30
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        $startDate = Get-Date
        do {
            $ScriptBlockResult = Invoke-Command $ScriptBlock
            if ($ScriptBlockResult -eq $true) {
                Write-Verbose "Wait-Until: complete"
                return
            }
            Write-Verbose "Sleep for $($Seconds) seconds"
            Start-Sleep -Seconds $Seconds
        } while ($startDate.AddMinutes($Timeout) -gt (Get-Date))
        throw "timeout"
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}