$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Wait-RemoveSpace.ps1"
. "$source\Remove-Space.ps1"
. "$source\Wait-JobStatus.ps1"
. "$source\Wait-Until.ps1"

Describe "Wait-RemoveSpace" {
    $TargetSpace = [PSCustomObject]@{}
    $TargetJob = [PSCustomObject]@{}
    $JobStatus = [PSCustomObject]@{entity=@{status=""}}
    Mock Wait-JobStatus { $JobStatus } -Verifiable -ParameterFilter { $Job -eq $TargetJob }
    Mock Remove-Space { $TargetJob } -Verifiable -ParameterFilter { $Space -eq $TargetSpace }
    Context "job status" {
        It "has state not 'failed' then $true" {
            $JobStatus.entity.status="in progress"            
             Mock Wait-Until { (& $ScriptBlock) | Should be $true }
             Wait-RemoveSpace -Space $TargetSpace             
             Assert-VerifiableMock
        }
        It "has state 'failed' then $false" {
            $JobStatus.entity.status="failed"            
             Mock Wait-Until { (& $ScriptBlock) | Should be $false }
             Wait-RemoveSpace -Space $TargetSpace
             Assert-VerifiableMock
        }
        It "passes Seconds and Timeout to Wait-Until" {
            $JobStatus.entity.status="in progress"
            Mock Wait-Until { (& $ScriptBlock) | Should be $true } -Verifiable -ParameterFilter { $Seconds -eq 33 -and $Timeout -eq 34 }
            Wait-RemoveSpace -Space $TargetSpace -Seconds 33 -Timeout 34
            Assert-VerifiableMock
        }
    }
    Context "parameters" {
        It "ensures 'Space' is not null" {
            { Wait-RemoveSpace -Space $null } | Should -Throw "Cannot validate argument on parameter 'Space'. The argument is null or empty"
        }
        It "supports 'Space' from pipeline" {
            $JobStatus.entity.status="in progress"
            Mock Wait-Until { (& $ScriptBlock) | Should be $true }
            $TargetSpace | Wait-RemoveSpace
            Assert-VerifiableMock
        }
        It "supports positional parameters" {
            $JobStatus.entity.status="in progress"
            Mock Wait-Until { (& $ScriptBlock) | Should be $true } -Verifiable -ParameterFilter { $Seconds -eq 1 -and $Timeout -eq 2 }
            Wait-RemoveSpace $TargetSpace 1 2
            Assert-VerifiableMock
        }
        It "defaults" {
            $JobStatus.entity.status="in progress"
            Mock Wait-Until { (& $ScriptBlock) | Should be $true } -Verifiable -ParameterFilter { $Seconds -eq 3 -and $Timeout -eq 900 }
            Wait-RemoveSpace $TargetSpace
            Assert-VerifiableMock
        }        
    }
}