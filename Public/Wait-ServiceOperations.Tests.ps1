$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Wait-ServiceOperations.ps1"
. "$source\Get-SpaceSummary.ps1"
. "$source\Wait-Until.ps1"

Describe "Wait-ServiceOperations" {
    $TargetSpace = [PSCustomObject]@{}
    $SpaceSummary = [PSCustomObject]@{
        services = @(
            [PSCustomObject]@{
                name="service1"
                service_plan = [PSCustomObject]@{}
                last_operation = @{
                    type = "create"
                    state = ""
                }
            },
            [PSCustomObject]@{
                name="service1"
                service_plan = [PSCustomObject]@{}
                last_operation = @{
                    type = "create"
                    state = ""
                }
            }            
        )
    }        
    Mock Get-SpaceSummary { $SpaceSummary } -Verifiable -ParameterFilter { $Space -eq $TargetSpace }
    $SpaceSummary.services[0].last_operation.state = "complete"
    $SpaceSummary.services[1].last_operation.state = "complete"
    Context "job status" {
        It "has service_plans are not 'in progress' then $true" {
            Mock Wait-Until { (& $ScriptBlock) | Should be $true }
            Wait-ServiceOperations -Space $TargetSpace
            Assert-VerifiableMock
        }
        It "1 service plan is not complete then $false" {
            $SpaceSummary.services[1].last_operation.state = "in progress"
            Mock Wait-Until { (& $ScriptBlock) | Should be $false }
            Wait-ServiceOperations -Space $TargetSpace
            Assert-VerifiableMock
        }
    }
    Context "parameters" {
        It "ensures 'Space' is not null" {
            {  Wait-ServiceOperations -Space $null } | Should -Throw "Cannot validate argument on parameter 'Space'. The argument is null or empty"
        }
        It "supports 'Space' from pipeline" {
            Mock Wait-Until { (& $ScriptBlock) }
            $TargetSpace |  Wait-ServiceOperations
            Assert-VerifiableMock
        }
        It "supports positional parameters" {
            Mock Wait-Until { (& $ScriptBlock) } -Verifiable -ParameterFilter { $Seconds -eq 1 -and $Timeout -eq 2 }
            Wait-ServiceOperations $TargetSpace 1 2
            Assert-VerifiableMock
        }
        It "defaults" {
            Mock Wait-Until { (& $ScriptBlock) } -Verifiable -ParameterFilter { $Seconds -eq 3 -and $Timeout -eq 900 }
            Wait-ServiceOperations $TargetSpace
            Assert-VerifiableMock
        }        
    }
}