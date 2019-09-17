$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Wait-Until.ps1"

Describe "Wait-Until" {
    Mock Start-Sleep
    Context "calls" {
        It "returns on $true" {
            Wait-Until { $true }
            Assert-MockCalled Start-Sleep -Times 0 -Exactly
        }
        It "retries on $false" {
            $script:callCount = 0
            Wait-Until { 
                if ($script:callCount -eq 0) { $false } else { $true }
                $script:callCount += 1
            }
            Assert-MockCalled Start-Sleep -Times 1 -Exactly
        }
        It "retries until timeout" {
            { Wait-Until { $false } -Timeout .01 } | Should -Throw "timeout"
            Assert-MockCalled Start-Sleep -Times 1
        }
        It "sleeps for configured 'Seconds'" {
            Mock Start-Sleep -Verifiable -ParameterFilter { $Seconds -eq 2 }
            { Wait-Until { $false }  -Seconds 2  -Timeout .01 } | Should -Throw "timeout"
            Assert-VerifiableMock
        }
        It "sleeps for default of 5 seconds" {
            Mock Start-Sleep -Verifiable -ParameterFilter { $Seconds -eq 5 }
            $script:callCount = 0
            Wait-Until { 
                if ($script:callCount -eq 0) { $false } else { $true }
                $script:callCount += 1
            }
            Assert-VerifiableMock
        }
    }
    Context "parameters" {
        It "ensure 'ScriptBlock' is not null" {
            { Wait-Until -ScriptBlock $null } |  Should -Throw "Cannot validate argument on parameter 'ScriptBlock'. The argument is null or empty"
        }
        It "supports 'ScriptBlock' from pipeline" {
            { $true } | Wait-Until 
        }
        It "supports positional" {
            Wait-Until { $true } 1 1
        }
    }
}
