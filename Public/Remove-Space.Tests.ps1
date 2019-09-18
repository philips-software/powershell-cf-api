$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Remove-Space.ps1"
. "$source\Get-BaseHost.ps1"
. "$source\Get-Header.ps1"
. "$source\Invoke-Retry.ps1"
. "$source\..\Private\Compare-HashTable.ps1"
. "$source\..\Private\PesterMatchHashtable.Tests.ps1"

Describe "Remove-Service" {
    Mock Get-baseHost { "basehost" }
    Mock Get-Header { @{} }
    Mock Invoke-Retry { & $ScriptBlock } -Verifiable
    Mock Invoke-WebRequest
    $response = "{'foo': 'bar'}"
    $TargetSpace = @{metadata=@{guid="1"}}
    Context "calls depdendent cmdlets" {
        It "returns correct result when service_instances returns <StatusCode>" -TestCases @( @{StatusCode=202}) {
            param ($StatusCode)
            Mock Invoke-WebRequest {@{StatusCode=$StatusCode;Content=$response}} -Verifiable -ParameterFilter {$Url -eq "basehost/v2/spaces/$($TargetSpace.metadata.guid)?async=true&recursive=true" -and $Method -eq "Delete" }
            Remove-Space -Space $TargetSpace | Should  MatchHashtable ($response | ConvertFrom-Json)
            Assert-VerifiableMock
        }
    }
    Context "parameters" {
        It "ensures 'ServiceBinding' is not null" {
            {Remove-Space -Space $null } | Should -Throw "Cannot validate argument on parameter 'Space'. The argument is null or empty"
        }
        It "supports positional" {
            Mock Invoke-WebRequest {@{StatusCode=202;Content=$response}}
            Remove-Space $TargetSpace | Should MatchHashtable ($response | ConvertFrom-Json)
        }
        It "supports 'Space' from pipeline" {
            Mock Invoke-WebRequest {@{StatusCode=202;Content=$response}}
            $TargetSpace | Remove-Space | Should MatchHashtable ($response | ConvertFrom-Json)
        }
    }
}