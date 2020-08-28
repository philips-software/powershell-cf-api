Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Set-Headers.ps1"
}

Describe "Set-Headers" {
    Context "SciptLevel" {
        It "sets script level vars and returns header" {
            $TargetToken = @{access_token="1"; expires_in=0}
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
            $TargetHeader = @{
                "Authorization"="Bearer $($TargetToken.access_token)"
                "Content-Type"="application/json"
                "Accept"="application/json"
            }
            Set-Headers -Token $TargetToken | Should -Not -BeNullOrEmpty
            (Get-Variable -Name "headers" -Scope Script).Value | Should -Not -BeNullOrEmpty
            (Get-Variable -Name "token" -Scope Script).Value | Should -Not -BeNullOrEmpty
        }
        It "sets script level vars for expire at using slew seconds" {
            $TargetDate = [pscustomobject]@{}
            $TargetExpiresAt = New-Object DateTime 1983, 1, 1, 0, 0, 0, ([DateTimeKind]::Utc)
            $TargetExpireSlewSeconds = -1
            $TargetDate | Add-Member -MemberType ScriptMethod -Name "AddSeconds" -Value {
                param($seconds)
                process {
                    $seconds | should be 2
                    return $TargetExpiresAt
                }
            }
            $TargetToken = @{access_token="1";expires_in=1}
            Mock Get-Date { $TargetDate }
            Set-Headers -Token $TargetToken -ExpireSlewSeconds $TargetExpireSlewSeconds
            (Get-Variable -Name "tokenExpiresAt" -Scope Script).Value | should -Be $TargetExpiresAt
        }

    }
}