$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-Token.ps1"
. "$source\Invoke-Retry.ps1"
. "$source\..\Private\Compare-HashTable.ps1"
. "$source\..\Private\PesterMatchHashtable.ps1"

#$DebugPreference = "continue"

$params = @{            
    Username = "user1" 
    Password = "pass1"
    CloudFoundryAPI = "http://cf.com"
}

Describe "Get-Token" {
    Context "API call" {
        It "Called with the correct URLs" {
            $Content = "{'name': 'foo'}"
            Mock -Command Invoke-WebRequest -MockWith { 
                if ($Uri -eq "$($CloudFoundryAPI)/v2/info") {
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
                } `
            } -ParameterFilter { 
                $matchHeader = @{
                    "Authorization"="Basic Y2Y6"
                    "Accept"="application/json"
                    "Content-Type"="application/x-www-form-urlencoded; charset=UTF-8"
                }
                if ($Uri -eq "$($CloudFoundryAPI)/v2/info") {
                    return $Method -eq "Get" -and (Compare-Hashtable $Header $matchHeader) -eq $null
                }
                if ($Uri -Match "http://auth/oauth/token") {
                    return $Method -eq "Post" -and (Compare-HashTable $Header $matchHeader) -eq $null -and $Body -eq "grant_type=password&password=$($Password)&scope=&username=$($Username)"
                }
                $false
            }
            (Get-Token @params) | Should MatchHashtable $Content
            Assert-VerifiableMock
        }
    }
    Context  "Failed API call" {
        It "fails" {
            Mock -Command Invoke-WebRequest -MockWith { 
                if ($Uri -eq "$($CloudFoundryAPI)/v2/info") {
                    return @{
                        StatusCode=400
                    }
                }
            }
            {Get-Token @params} | Should -Throw "400"
        }
    }
    Context "Fail API auth" {
        It "fail" {
            $Content = "{'name': 'foo'}"
            Mock -Command Invoke-WebRequest -MockWith { 
                if ($Uri -eq "$($CloudFoundryAPI)/v2/info") {
                    return @{
                        StatusCode=200
                        Content="{'authorization_endpoint': 'http://auth'}"
                    }
                }
                if ($Uri -Match "http://auth/oauth/token") {
                    return @{
                        StatusCode=400
                        Content=$Content
                    }
                } `
            }
            {Get-Token @params} | Should -Throw "400"
        }
    }
}