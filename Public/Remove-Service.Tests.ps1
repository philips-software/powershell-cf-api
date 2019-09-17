$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Remove-Service.ps1"
. "$source\Get-BaseHost.ps1"
. "$source\Get-Header.ps1"
. "$source\Invoke-Retry.ps1"
. "$source\..\Private\Compare-HashTable.ps1"
. "$source\..\Private\PesterMatchHashtable.ps1"

Describe "Remove-Service" {
    Mock Get-baseHost { "basehost" }
    Mock Get-Header { @{} }
    Mock Invoke-Retry { & $ScriptBlock } -Verifiable
    Mock Invoke-WebRequest
    $response = "{'foo': 'bar'}"
    Context "calls depdendent cmdlets" {
        It "returns correct result when service_instances returns <StatusCode>" -TestCases @( @{StatusCode=204}, @{StatusCode=202}) {
            param ($StatusCode)
            Mock Invoke-WebRequest {@{StatusCode=$StatusCode;Content=$response}} -Verifiable -ParameterFilter {$Url -eq "basehost/v2/service_instances/1?accepts_incomplete=true&async=true" }
            Remove-Service -Guid "1" | Should  MatchHashtable ($response | ConvertFrom-Json)
            Assert-VerifiableMock
        }
    }
    Context "parameters" {
        It "ensures 'Guid' is not null" {
            {Remove-Service -Guid $null } | Should -Throw "Cannot validate argument on parameter 'Guid'. The argument is null or empty"
        }
        It "ensures 'Guid' is not empty" {
            {Remove-Service -Guid "" } | Should -Throw "Cannot validate argument on parameter 'Guid'. The argument is null or empty"
        }
        It "supports positional" {
            Mock Invoke-WebRequest {@{StatusCode=204;Content=$response}}
            "1" | Remove-Service | Should MatchHashtable ($response | ConvertFrom-Json)
        }
    }
}