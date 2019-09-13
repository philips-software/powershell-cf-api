$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-OrgCredentials.ps1"
. "$source\Get-Token.ps1"
. "$source\Set-Headers.ps1"
. "$source\Get-Org.ps1"

Describe "Get-OrgCredentials" {
    Context "API call" {
        $Token = New-Object PsObject -Property @{}
        $Org = New-Object PsObject -Property @{name="myorg"}
        Mock Get-Token { $Token } `
            -Verifiable -ParameterFilter {$OrgName -eq "org1" -and $Username -eq "user1" -and $Password -eq "pass" -and $CloudFoundryAPI -eq "http://cfapi"}
        Mock Set-Headers -ParameterFilter { $Token -eq $Token }
        Mock Get-Org { $Org } -ParameterFilter { $Token -eq $Token }

        It "Called with the values" {
            Get-OrgCredentials -OrgName "org1" -Username "user1" -Password "pass" -CloudFoundryAPI "http://cfapi"
            Assert-VerifiableMock
        }

        It "Returns the object" {
            (Get-OrgCredentials -OrgName "org1" -Username "user1" -Password "pass" -CloudFoundryAPI "http://cfapi") `
              | Should be $Org
        }
        It "parameter order" {
            Get-OrgCredentials "org1" "user1" "pass" "http://cfapi"
            Assert-VerifiableMock
        }
    }
    Context "Parameter validation" {
        It "OrgName cannot be empty" {
            { (Get-OrgCredentials -OrgName "" -Username "user1" -Password "pass" -CloudFoundryAPI "http://cfapi") } `
              | Should -Throw "Cannot validate argument on parameter 'OrgName'. The argument is null or empty."
        }
        It "OrgName cannot be null" {
            { (Get-OrgCredentials -OrgName "$null" -Username "user1" -Password "pass" -CloudFoundryAPI "http://cfapi") } `
              | Should -Throw "Cannot validate argument on parameter 'OrgName'. The argument is null or empty."
        }
        It "Username cannot be empty" {
            { (Get-OrgCredentials -OrgName "org1" -Username "" -Password "pass" -CloudFoundryAPI "http://cfapi") } `
              | Should -Throw "Cannot validate argument on parameter 'Username'. The argument is null or empty."
        }
        It "Username cannot be null" {
            { (Get-OrgCredentials -OrgName "org1" -Username $null -Password "pass" -CloudFoundryAPI "http://cfapi") } `
              | Should -Throw "Cannot validate argument on parameter 'Username'. The argument is null or empty."
        }
        It "Password cannot be empty" {
            { (Get-OrgCredentials -OrgName "org1" -Username "user1" -Password "" -CloudFoundryAPI "http://cfapi") } `
              | Should -Throw "Cannot validate argument on parameter 'Password'. The argument is null or empty."
        }
        It "Password cannot be null" {
            { (Get-OrgCredentials -OrgName "org1" -Username "user1" -Password $null -CloudFoundryAPI "http://cfapi") } `
              | Should -Throw "Cannot validate argument on parameter 'Password'. The argument is null or empty."
        }
        It "CloudFoundryAPI cannot be empty" {
            { (Get-OrgCredentials -OrgName "org1" -Username "user1" -Password "pass" -CloudFoundryAPI "") } `
              | Should -Throw "Cannot validate argument on parameter 'CloudFoundryAPI'. The argument is null or empty."
        }
        It "CloudFoundryAPI cannot be null" {
            { (Get-OrgCredentials -OrgName "org1" -Username "user1" -Password "pass" -CloudFoundryAPI $null) } `
              | Should -Throw "Cannot validate argument on parameter 'CloudFoundryAPI'. The argument is null or empty."
        }
    }    
}