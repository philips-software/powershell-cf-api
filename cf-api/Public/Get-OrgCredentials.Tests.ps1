Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-OrgCredentials.ps1"
    . "$PSScriptRoot\Get-Token.ps1"
    . "$PSScriptRoot\Set-Headers.ps1"
    . "$PSScriptRoot\Get-Org.ps1"
}

Describe "Get-OrgCredentials" {
    BeforeAll {
        $Token = [PSCustomObject]@{}
        $Org = $Token = [PSCustomObject]@{name="myorg"}
        Mock Get-Token { $Token }
        Mock Set-Headers -ParameterFilter { $Token -eq $Token }
        Mock Get-Org { $Org } -ParameterFilter { $Token -eq $Token }
    }
    Context "API call" {
        It "Called with the values" {
            Get-OrgCredentials -OrgName "org1" -Username "user1" -Password "pass" -CloudFoundryAPI "http://cfapi"
            Should -Invoke Get-Token -ParameterFilter {
                $Username -eq "user1" -and $Password -eq "pass" -and $CloudFoundryAPI -eq "http://cfapi"
            }
        }
        It "Returns the object" {
            (Get-OrgCredentials -OrgName "org1" -Username "user1" -Password "pass" -CloudFoundryAPI "http://cfapi") | Should -Be $Org
        }
    }
    Context "parameters" {
        It "ensures 'OrgName' cannot be empty" {
            { (Get-OrgCredentials -OrgName "" -Username "user1" -Password "pass" -CloudFoundryAPI "http://cfapi") } `
              | Should -Throw "*Cannot validate argument on parameter 'OrgName'. The argument is null or empty*"
        }
        It "ensures 'OrgName' cannot be null" {
            { (Get-OrgCredentials -OrgName "$null" -Username "user1" -Password "pass" -CloudFoundryAPI "http://cfapi") } `
              | Should -Throw "*Cannot validate argument on parameter 'OrgName'. The argument is null or empty*"
        }
        It "ensures 'Username' cannot be empty" {
            { (Get-OrgCredentials -OrgName "org1" -Username "" -Password "pass" -CloudFoundryAPI "http://cfapi") } `
              | Should -Throw "*Cannot validate argument on parameter 'Username'. The argument is null or empty*"
        }
        It "ensures 'Username' cannot be null" {
            { (Get-OrgCredentials -OrgName "org1" -Username $null -Password "pass" -CloudFoundryAPI "http://cfapi") } `
              | Should -Throw "*Cannot validate argument on parameter 'Username'. The argument is null or empty*"
        }
        It "ensures 'Password' cannot be empty" {
            { (Get-OrgCredentials -OrgName "org1" -Username "user1" -Password "" -CloudFoundryAPI "http://cfapi") } `
              | Should -Throw "*Cannot validate argument on parameter 'Password'. The argument is null or empty*"
        }
        It "ensures 'Password' cannot be null" {
            { (Get-OrgCredentials -OrgName "org1" -Username "user1" -Password $null -CloudFoundryAPI "http://cfapi") } `
              | Should -Throw "*Cannot validate argument on parameter 'Password'. The argument is null or empty*"
        }
        It "ensures 'CloudFoundryAPI' cannot be empty" {
            { (Get-OrgCredentials -OrgName "org1" -Username "user1" -Password "pass" -CloudFoundryAPI "") } `
              | Should -Throw "*Cannot validate argument on parameter 'CloudFoundryAPI'. The argument is null or empty*"
        }
        It "ensures 'CloudFoundryAPI' cannot be null" {
            { (Get-OrgCredentials -OrgName "org1" -Username "user1" -Password "pass" -CloudFoundryAPI $null) } `
              | Should -Throw "*Cannot validate argument on parameter 'CloudFoundryAPI'. The argument is null or empty*"
        }
        It "supports positional" {
            Get-OrgCredentials "org1" "user1" "pass" "http://cfapi"
            Should -Invoke Get-Token -ParameterFilter { $Username -eq "user1" -and $Password -eq "pass" -and $CloudFoundryAPI -eq "http://cfapi" }
        }
    }
}