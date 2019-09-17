$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Set-Headers.ps1"
. "$source\..\Private\PesterMatchHashtable.ps1"

Describe "Set-Headers" {
    Context "SciptLevel" {
        It "sets script level vars and returns header" {
            $TargetToken = @{access_token="1"}
            $TargetHeader = @{
                "Authorization"="Bearer $($TargetToken.access_token)"
                "Content-Type"="application/json"
                "Accept"="application/json"
            }
            Set-Headers -Token $TargetToken | Should MatchHashTable $TargetHeader
            (Get-Variable -Name "headers" -Scope Script).Value | should MatchHashTable $TargetHeader
            (Get-Variable -Name "token" -Scope Script).Value | should MatchHashTable $TargetToken
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
            (Get-Variable -Name "tokenExpiresAt" -Scope Script).Value | should be $TargetExpiresAt
        }

    }
}