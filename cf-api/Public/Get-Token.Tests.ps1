Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Token.ps1"
    . "$PSScriptRoot\Invoke-Retry.ps1"
}

Describe "Get-Token" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification = 'pester supported')]
        $params = @{
            Username        = "user1"
            Password        = "pass1"
            CloudFoundryAPI = "http://cf.com"
        }

        Mock Invoke-WebRequest -ParameterFilter { $Uri -like "*/v2/info" } -Verifiable {
            @{ StatusCode = 200; Content = "{'authorization_endpoint': 'http://auth'}" }
        }
        Mock Invoke-WebRequest -ParameterFilter { $Uri -like "*/oauth/token" } -Verifiable {
            @{ StatusCode = 200; Content = '{"name":"foo"}' }
        }
        Mock Invoke-WebRequest { throw "this mock should never be called" }
    }
    Context "API call" {
        It "authenticates with username and password against the api" {
            Get-Token @params | ConvertTo-Json -Compress | Should -Be '{"name":"foo"}'

            Assert-MockCalled Invoke-WebRequest -ParameterFilter { $Uri -like "*/v2/info" } -Exactly -Times 1 -Scope It
            Assert-MockCalled Invoke-WebRequest -ParameterFilter { $Uri -like "*/oauth/token" } -Exactly -Times 1 -Scope It

            Assert-MockCalled Invoke-WebRequest -ParameterFilter {
                $Headers["Authorization"] -eq "Basic Y2Y6"
                $Headers["Accept"] -eq "application/json"
                $Headers["Content-Type"] -eq "application/x-www-form-urlencoded; charset=UTF-8"
            } -Exactly -Times 2 -Scope It

            Assert-MockCalled Invoke-WebRequest -ParameterFilter {
                $Body -eq "grant_type=password&password=pass1&scope=&username=user1"
            } -Exactly -Times 1 -Scope It
        }

        It "authenticates with passcode against the api" {
            Get-Token -Passcode "XXXXXXXX" -CloudFoundryAPI "http://cf.com" -ErrorAction Stop

            Assert-MockCalled Invoke-WebRequest -ParameterFilter { $Uri -like "*/v2/info" } -Exactly -Times 1 -Scope It
            Assert-MockCalled Invoke-WebRequest -ParameterFilter { $Uri -like "*/oauth/token" } -Exactly -Times 1 -Scope It

            Assert-MockCalled Invoke-WebRequest -ParameterFilter {
                $Body -eq "grant_type=password&passcode=XXXXXXXX&token_format=jwt"
            } -Exactly -Times 1 -Scope It
        }
    }
    It "returns an error when the info endpoint can't be called" {
        Mock Invoke-WebRequest -ParameterFilter { $Uri -like "*/v2/info" } -Verifiable {
            @{ StatusCode = 400 }
        }

        { Get-Token @params -ErrorAction Stop } | Should -Throw "http://cf.com/v2/info 400"
    }
    It "returns an error when no auth token can be retrieved" {
        Mock Invoke-WebRequest -ParameterFilter { $Uri -like "*/oauth/token" } -Verifiable {
            @{ StatusCode = 400; Content = '{"name":"foo"}' }
        }

        { Get-Token @params -ErrorAction Stop } | Should -Throw "http://auth/oauth/token 400"
    }
}
