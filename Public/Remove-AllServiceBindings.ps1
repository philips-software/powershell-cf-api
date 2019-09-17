<#
.Synopsis
   Removes all service bindings from a cloud foundry space
.DESCRIPTION
   The Remove-AllServiceBindings cmdlet removes all service bindings in a space
.PARAMETER Space
    This parameter is a Space object
#>
function Remove-AllServiceBindings {

    [CmdletBinding()]
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

        $summary = Get-SpaceSummary -Space $Space
        Write-Verbose ($summary| ConvertTo-Json)

        foreach ($app in $summary.apps) {
            $fullApp = Get-App -Space $Space -Name $app.name            
            $serviceBindings = Get-ServiceBindings -App $fullApp
            foreach ($serviceBinding in $serviceBindings) {
                Remove-ServiceBinding -ServiceBinding $serviceBinding | Out-Null
            }
        }        
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }    
}

