Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Wait-CreateService.ps1"
    . "$PSScriptRoot\Get-SpaceSummary.ps1"
    . "$PSScriptRoot\..\Private\Wait-Until.ps1"
}

Describe "Wait-CreateService" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetSpace = [PSCustomObject]@{}
        $SpaceSummary = [PSCustomObject]@{
            services = @(
                [PSCustomObject]@{
                    name="service1"
                    last_operation = @{
                        type = "create"
                        state = ""
                    }
                }

            )
        }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetServiceInstance = [PSCustomObject]@{
            entity=@{
                name="service1"
            }
        }
        Mock Get-SpaceSummary { $SpaceSummary }
    }
    Context "service instance complete" {
        It "has state 'in progress' then retry $true" {
             $SpaceSummary.services[0].last_operation.state = "succeded"
             Mock Wait-Until { (& $ScriptBlock) | Should -Be $true }
             Wait-CreateService -Space $TargetSpace -ServiceInstance $TargetServiceInstance
             Should -Invoke Wait-Until
             Should -Invoke Get-SpaceSummary -ParameterFilter { $Space -eq $TargetSpace }
        }
        It "has state not 'in progress' then retry $false " {
            $SpaceSummary.services[0].last_operation.state = "in progress"
            Mock Wait-Until { (& $ScriptBlock) | Should -Be $false }
            Wait-CreateService -Space $TargetSpace -ServiceInstance $TargetServiceInstance
            Should -Invoke Wait-Until
            Should -Invoke Get-SpaceSummary -ParameterFilter { $Space -eq $TargetSpace }
       }
    }
    Context "parameters" {
        It "ensures Space is not null" {
            { Wait-CreateService -Space $null -ServiceInstance $TargetServiceInstance } | Should -Throw "*Cannot validate argument on parameter 'Space'. The argument is null or empty*"
        }
        It "ensures ServiceInstance is not null" {
            { Wait-CreateService -Space $TargetSpace -ServiceInstance $null } | Should -Throw "*Cannot validate argument on parameter 'ServiceInstance'. The argument is null or empty*"
        }
        It "supports Space from pipeline" {
            $SpaceSummary.services[0].last_operation.state = "succeded"
            Mock Wait-Until { & $ScriptBlock }
            $TargetSpace | Wait-CreateService -ServiceInstance $TargetServiceInstance
        }
        It "supports positional" {
            $SpaceSummary.services[0].last_operation.state = "succeded"
            Mock Wait-Until { & $ScriptBlock } -Verifiable -ParameterFilter {$Seconds -eq 34 -and $Timeout -eq 35}
            Wait-CreateService $TargetSpace $TargetServiceInstance 34 35
        }
        It "defaults" {
            $SpaceSummary.services[0].last_operation.state = "succeded"
            Mock Wait-Until { & $ScriptBlock } -Verifiable -ParameterFilter {$Seconds -eq 3 -and $Timeout -eq 900}
            Wait-CreateService $TargetSpace $TargetServiceInstance
        }
    }
}