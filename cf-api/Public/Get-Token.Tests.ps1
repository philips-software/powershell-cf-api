# Set-StrictMode -Version Latest

# BeforeAll {
#     . "$PSScriptRoot\Get-Token.ps1"
#     . "$PSScriptRoot\Invoke-Retry.ps1"
#     . "$PSScriptRoot\..\Private\Compare-HashTable.ps1"
#     . "$PSScriptRoot\..\Private\PesterMatchHashtable.Tests.ps1"
# }


# Describe "Get-Token" {
#     BeforeAll {
#         [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
#         $params = @{
#             Username = "user1"
#             Password = "pass1"
#             CloudFoundryAPI = "http://cf.com"
#         }
#     }
#     Context "API call" {
#         It "is called with the correct URLs" {
#             $Content = "{'name': 'foo'}"
#             Mock -Command Invoke-WebRequest {
#                 if ($Uri -eq "$($CloudFoundryAPI)/v2/info") {
#                     return @{
#                         StatusCode=200
#                         Content="{'authorization_endpoint': 'http://auth'}"
#                     }
#                 }
#                 if ($Uri -Match "http://auth/oauth/token") {
#                     return @{
#                         StatusCode=200
#                         Content=$Content
#                     }
#                 } `
#             }
#             (Get-Token @params) | Should MatchHashtable $Content
#             Should -Invoke Invoke-WebRequest -ParameterFilter {
#                 $matchHeader = @{
#                     "Authorization"="Basic Y2Y6"
#                     "Accept"="application/json"
#                     "Content-Type"="application/x-www-form-urlencoded; charset=UTF-8"
#                 }
#                 if ($Uri -eq "$($CloudFoundryAPI)/v2/info") {
#                     return $Method -eq "Get" -and (Compare-Hashtable $Header $matchHeader) -eq $null
#                 }
#                 if ($Uri -Match "http://auth/oauth/token") {
#                     return $Method -eq "Post" -and (Compare-HashTable $Header $matchHeader) -eq $null -and $Body -eq "grant_type=password&password=$($Password)&scope=&username=$($Username)"
#                 }
#                 $false
#             }
#         }
#     }
#     Context  "failed API call" {
#         It "fails" {
#             Mock -Command Invoke-WebRequest {
#                 if ($Uri -eq "$($CloudFoundryAPI)/v2/info") {
#                     return @{
#                         StatusCode=400
#                     }
#                 }
#             }
#             {Get-Token @params} | Should -Throw "400"
#         }
#     }
#     Context "fail API auth" {
#         It "fail" {
#             $Content = "{'name': 'foo'}"
#             Mock -Command Invoke-WebRequest {
#                 if ($Uri -eq "$($CloudFoundryAPI)/v2/info") {
#                     return @{
#                         StatusCode=200
#                         Content="{'authorization_endpoint': 'http://auth'}"
#                     }
#                 }
#                 if ($Uri -Match "http://auth/oauth/token") {
#                     return @{
#                         StatusCode=400
#                         Content=$Content
#                     }
#                 } `
#             }
#             {Get-Token @params} | Should -Throw "400"
#         }
#     }
# }