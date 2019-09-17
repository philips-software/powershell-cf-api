$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Wait-JobStatus.ps1"
. "$source\Get-Job.ps1"
. "$source\Wait-Until.ps1"

Describe "Wait-JobStatus" {
    $TargetJob = [PSCustomObject]@{}
    $JobStatus = [PSCustomObject]@{
        entity=@{
            status=""
        }
    }    
    Mock Get-Job { $JobStatus } -Verifiable -ParameterFilter { $Job -eq $TargetJob }
    Context "job status" {
        It "has state 'finished' then $true" {
            $JobStatus.entity.status="finished"
             Mock Wait-Until { (& $ScriptBlock) | Should be $true }
             Wait-JobStatus -Job $TargetJob
             Assert-VerifiableMock
        }
        It "has state 'failed' then $true" {
            $JobStatus.entity.status="failed"
            Mock Wait-Until { (& $ScriptBlock) | Should be $true }
            Wait-JobStatus -Job $TargetJob
            Assert-VerifiableMock
        }
        It "has state 'in progress' then $false" {
            $JobStatus.entity.status="in progress"
            Mock Wait-Until { (& $ScriptBlock) | Should be $false }
            Wait-JobStatus -Job $TargetJob
            Assert-VerifiableMock
        }
        It "has state specified then $true" {
            $JobStatus.entity.status="foobar"
            Mock Wait-Until { (& $ScriptBlock) | Should be $true }
            Wait-JobStatus -Job $TargetJob -ForStatus "foobar"
            Assert-VerifiableMock
        }
        It "passes Seconds and Timeout to Wait-Until" {
            $JobStatus.entity.status="foobar"
            Mock Wait-Until { (& $ScriptBlock) | Should be $true } -Verifiable -ParameterFilter { $Seconds -eq 33 -and $Timeout -eq 34 }
            Wait-JobStatus -Job $TargetJob -ForStatus "foobar" -Seconds 33 -Timeout 34
            Assert-VerifiableMock
        }
    }
    Context "parameters" {
        It "ensures 'Job' is not null" {
            { Wait-JobStatus -Job $null } | Should -Throw "Cannot validate argument on parameter 'Job'. The argument is null or empty"
        }
        It "ensures 'ForStatus' is not null" {
            { Wait-JobStatus -Job $TargetJob -ForStatus $null } | Should -Throw "Cannot validate argument on parameter 'ForStatus'. The argument is null or empty"
        }
        It "ensures 'ForStatus' is not empty" {
            { Wait-JobStatus -Job $TargetJob -ForStatus "" } | Should -Throw "Cannot validate argument on parameter 'ForStatus'. The argument is null or empty"
        }
        It "supports Job from pipeline" {
            $JobStatus.entity.status="finished"
            Mock Wait-Until { & $ScriptBlock }
            $TargetJob | Wait-JobStatus
            Assert-VerifiableMock
        }
        It "supports positional parameters" {
            $JobStatus.entity.status="finished"
            Mock Wait-Until { & $ScriptBlock }
            Wait-JobStatus $TargetJob "failed" 3 10
            Assert-VerifiableMock
        }
        It "defaults" {
            $JobStatus.entity.status="finished"
            Mock Wait-Until { & $ScriptBlock } -Verifiable -ParameterFilter { $Seconds -eq 3 -and $Timeout -eq 900 }
            Wait-JobStatus $TargetJob "failed" 
            Assert-VerifiableMock
        }

    }
}

