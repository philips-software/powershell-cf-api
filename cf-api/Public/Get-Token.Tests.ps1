Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Token.ps1"
    . "$PSScriptRoot\Invoke-Retry.ps1"
}

Describe "Get-Token" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $params = @{
            Username = "user1"
            Password = "pass1"
            CloudFoundryAPI = "http://cf.com"
        }
    }
    Context "API call" {
        It "is called with the correct URLs" {
            $Content = "{'name': 'foo'}"
            Mock Invoke-WebRequest {
                if ($Uri -eq "$($params.CloudFoundryAPI)/v2/info") {
                    return @{
                        StatusCode=200
                        Content="{'authorization_endpoint': 'http://auth'}"
                    }
                }
                if ($Uri -Match "http://auth/oauth/token") {
                    return @{
                        StatusCode=200
                        Content=$Content
                    }
                }
            }
            Get-Token @params
            Should -Invoke Invoke-WebRequest -ParameterFilter {
                if ($Uri.AbsoluteUri -eq "$($params.CloudFoundryAPI)/v2/info") {
                    $Method -eq "Get"
                } elseif ($Uri.AbsoluteUri -Match "http://auth/oauth/token") {
                    $Method -eq "Post" -and $Body -eq "grant_type=password&password=$($params.Password)&scope=&username=$($params.Username)"
                } else {
                    $false
                }
            }
        }
    }
    Context  "info API call" {
        It "fails" {
            Mock Invoke-WebRequest {
                if ($Uri -eq "$($params.CloudFoundryAPI)/v2/info") { @{ StatusCode=400 } }
            }
            {Get-Token @params} | Should -Throw "http://cf.com/v2/info 400"
        }
    }
    Context "auth API call" {
        It "fails" {
            $Content = "{'name': 'foo'}"
            Mock -Command Invoke-WebRequest {
                if ($Uri -eq "$($params.CloudFoundryAPI)/v2/info") {
                    return @{ StatusCode=200; Content="{'authorization_endpoint': 'http://auth'}" }
                }
                if ($Uri -Match "http://auth/oauth/token") {
                    return @{ StatusCode=400; Content=$Content }
                }
            }
            {Get-Token @params} | Should -Throw "http://auth/oauth/token 400"
        }
    }
}