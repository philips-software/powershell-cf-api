Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Wait-JobStatus.ps1"
    . "$PSScriptRoot\Get-Job.ps1"
    . "$PSScriptRoot\..\Private\Wait-Until.ps1"
}

Describe "Wait-JobStatus" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetJob = [PSCustomObject]@{}
        $JobStatus = [PSCustomObject]@{
            entity=@{
                status=""
            }
        }
        Mock Get-Job { $JobStatus }
    }
    Context "job status" {
        It "has state 'finished' then $true" {
            $JobStatus.entity.status="finished"
             Mock Wait-Until { (& $ScriptBlock) | Should -Be $true }
             Wait-JobStatus -Job $TargetJob
             Should -Invoke Get-Job -ParameterFilter { $Job -eq $TargetJob }
        }
        It "has state 'failed' then $true" {
            $JobStatus.entity.status="failed"
            Mock Wait-Until { (& $ScriptBlock) | Should -Be $true }
            Wait-JobStatus -Job $TargetJob
            Should -Invoke Get-Job -ParameterFilter { $Job -eq $TargetJob }
        }
        It "has state 'in progress' then $false" {
            $JobStatus.entity.status="in progress"
            Mock Wait-Until { (& $ScriptBlock) | Should -Be $false }
            Wait-JobStatus -Job $TargetJob
            Should -Invoke Get-Job -ParameterFilter { $Job -eq $TargetJob }
        }
        It "has state specified then $true" {
            $JobStatus.entity.status="foobar"
            Mock Wait-Until { (& $ScriptBlock) | Should -Be $true }
            Wait-JobStatus -Job $TargetJob -ForStatus "foobar"
            Should -Invoke Get-Job -ParameterFilter { $Job -eq $TargetJob }
        }
        It "passes Seconds and Timeout to Wait-Until" {
            $JobStatus.entity.status="foobar"
            Mock Wait-Until { (& $ScriptBlock) | Should -Be $true } -Verifiable -ParameterFilter { $Seconds -eq 33 -and $Timeout -eq 34 }
            Wait-JobStatus -Job $TargetJob -ForStatus "foobar" -Seconds 33 -Timeout 34
            Should -Invoke Get-Job -ParameterFilter { $Job -eq $TargetJob }
        }
    }
    Context "parameters" {
        It "ensures 'Job' is not null" {
            { Wait-JobStatus -Job $null } | Should -Throw "*Cannot validate argument on parameter 'Job'. The argument is null or empty*"
        }
        It "ensures 'ForStatus' is not null" {
            { Wait-JobStatus -Job $TargetJob -ForStatus $null } | Should -Throw "*Cannot validate argument on parameter 'ForStatus'. The argument is null or empty*"
        }
        It "ensures 'ForStatus' is not empty" {
            { Wait-JobStatus -Job $TargetJob -ForStatus "" } | Should -Throw "*Cannot validate argument on parameter 'ForStatus'. The argument is null or empty*"
        }
        It "supports Job from pipeline" {
            $JobStatus.entity.status="finished"
            Mock Wait-Until { & $ScriptBlock }
            $TargetJob | Wait-JobStatus
            Should -Invoke Get-Job -ParameterFilter { $Job -eq $TargetJob }
        }
        It "supports positional parameters" {
            $JobStatus.entity.status="finished"
            Mock Wait-Until { & $ScriptBlock }
            Wait-JobStatus $TargetJob "failed" 3 10
            Should -Invoke Get-Job -ParameterFilter { $Job -eq $TargetJob }
        }
        It "defaults" {
            $JobStatus.entity.status="finished"
            Mock Wait-Until { & $ScriptBlock } -Verifiable -ParameterFilter { $Seconds -eq 3 -and $Timeout -eq 900 }
            Wait-JobStatus $TargetJob "failed"
            Should -Invoke Get-Job -ParameterFilter { $Job -eq $TargetJob }
        }

    }
}

