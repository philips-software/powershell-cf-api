Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Wait-RemoveSpace.ps1"
    . "$PSScriptRoot\Remove-Space.ps1"
    . "$PSScriptRoot\Wait-JobStatus.ps1"
    . "$PSScriptRoot\..\Private\Wait-Until.ps1"
}

Describe "Wait-RemoveSpace" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetSpace = [PSCustomObject]@{}
        $TargetJob = [PSCustomObject]@{}
        $JobStatus = [PSCustomObject]@{entity=@{status=""}}
        Mock Wait-JobStatus { $JobStatus }
        Mock Remove-Space { $TargetJob }
    }
    Context "job status" {
        It "has state not 'failed' then $true" {
            $JobStatus.entity.status="in progress"
             Mock Wait-Until { (& $ScriptBlock) | Should -Be $true }
             Wait-RemoveSpace -Space $TargetSpace
             Should -Invoke Wait-JobStatus -ParameterFilter { $Job -eq $TargetJob }
             Should -Invoke Remove-Space -ParameterFilter { $Space -eq $TargetSpace }
        }
        It "has state 'failed' then $false" {
            $JobStatus.entity.status="failed"
             Mock Wait-Until { (& $ScriptBlock) | Should -Be $false }
             Wait-RemoveSpace -Space $TargetSpace
             Should -Invoke Wait-JobStatus -ParameterFilter { $Job -eq $TargetJob }
             Should -Invoke Remove-Space -ParameterFilter { $Space -eq $TargetSpace }
        }
        It "passes Seconds and Timeout to Wait-Until" {
            $JobStatus.entity.status="in progress"
            Mock Wait-Until { (& $ScriptBlock) | Should -Be $true } -Verifiable -ParameterFilter { $Seconds -eq 33 -and $Timeout -eq 34 }
            Wait-RemoveSpace -Space $TargetSpace -Seconds 33 -Timeout 34
            Should -Invoke Wait-JobStatus -ParameterFilter { $Job -eq $TargetJob }
            Should -Invoke Remove-Space -ParameterFilter { $Space -eq $TargetSpace }
       }
    }
    Context "parameters" {
        It "ensures 'Space' is not null" {
            { Wait-RemoveSpace -Space $null } | Should -Throw "*Cannot validate argument on parameter 'Space'. The argument is null or empty*"
        }
        It "supports 'Space' from pipeline" {
            $JobStatus.entity.status="in progress"
            Mock Wait-Until { (& $ScriptBlock) | Should -Be $true }
            $TargetSpace | Wait-RemoveSpace
            Should -Invoke Wait-JobStatus -ParameterFilter { $Job -eq $TargetJob }
            Should -Invoke Remove-Space -ParameterFilter { $Space -eq $TargetSpace }
       }
        It "supports positional parameters" {
            $JobStatus.entity.status="in progress"
            Mock Wait-Until { (& $ScriptBlock) | Should -Be $true } -Verifiable -ParameterFilter { $Seconds -eq 1 -and $Timeout -eq 2 }
            Wait-RemoveSpace $TargetSpace 1 2
            Should -Invoke Wait-JobStatus -ParameterFilter { $Job -eq $TargetJob }
            Should -Invoke Remove-Space -ParameterFilter { $Space -eq $TargetSpace }
       }
        It "defaults" {
            $JobStatus.entity.status="in progress"
            Mock Wait-Until { (& $ScriptBlock) | Should -Be $true } -Verifiable -ParameterFilter { $Seconds -eq 3 -and $Timeout -eq 900 }
            Wait-RemoveSpace $TargetSpace
            Should -Invoke Wait-JobStatus -ParameterFilter { $Job -eq $TargetJob }
            Should -Invoke Remove-Space -ParameterFilter { $Space -eq $TargetSpace }
       }
    }
}