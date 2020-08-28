Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Wait-ServiceOperations.ps1"
    . "$PSScriptRoot\Get-SpaceSummary.ps1"
    . "$PSScriptRoot\Wait-Until.ps1"
}

Describe "Wait-ServiceOperations" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
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
        Mock Get-SpaceSummary { $SpaceSummary }
        $SpaceSummary.services[0].last_operation.state = "complete"
        $SpaceSummary.services[1].last_operation.state = "complete"
    }
    Context "job status" {
        It "has service_plans are not 'in progress' then $true" {
            Mock Wait-Until { (& $ScriptBlock) | Should -Be $true }
            Wait-ServiceOperations -Space $TargetSpace
            Should -Invoke Get-SpaceSummary -ParameterFilter { $Space -eq $TargetSpace }
        }
        It "1 service plan is not complete then $false" {
            $SpaceSummary.services[1].last_operation.state = "in progress"
            Mock Wait-Until { (& $ScriptBlock) | Should -Be $false }
            Wait-ServiceOperations -Space $TargetSpace
            Should -Invoke Get-SpaceSummary -ParameterFilter { $Space -eq $TargetSpace }
        }
    }
    Context "parameters" {
        It "ensures 'Space' is not null" {
            {  Wait-ServiceOperations -Space $null } | Should -Throw "*Cannot validate argument on parameter 'Space'. The argument is null or empty*"
        }
        It "supports 'Space' from pipeline" {
            Mock Wait-Until { (& $ScriptBlock) }
            $TargetSpace |  Wait-ServiceOperations
            Should -Invoke Get-SpaceSummary -ParameterFilter { $Space -eq $TargetSpace }
        }
        It "supports positional parameters" {
            Mock Wait-Until { (& $ScriptBlock) } -Verifiable -ParameterFilter { $Seconds -eq 1 -and $Timeout -eq 2 }
            Wait-ServiceOperations $TargetSpace 1 2
            Should -Invoke Get-SpaceSummary -ParameterFilter { $Space -eq $TargetSpace }
        }
        It "defaults" {
            Mock Wait-Until { (& $ScriptBlock) } -Verifiable -ParameterFilter { $Seconds -eq 3 -and $Timeout -eq 900 }
            Wait-ServiceOperations $TargetSpace
            Should -Invoke Get-SpaceSummary -ParameterFilter { $Space -eq $TargetSpace }
        }
    }
}