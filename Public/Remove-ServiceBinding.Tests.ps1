$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Remove-ServiceBinding.ps1"
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
    $TargetServiceBinding = @{metadata=@{guid="1"}}
    Context "calls depdendent cmdlets" {
        It "returns correct result when service_instances returns <StatusCode>" -TestCases @( @{StatusCode=204}) {
            param ($StatusCode)
            Mock Invoke-WebRequest {@{StatusCode=$StatusCode;Content=$response}} -Verifiable -ParameterFilter {$Url -eq "basehost/v2/service_bindings/$($TargetServiceBinding.metadata.guid)?accepts_incomplete=true" -and $Method -eq "Delete" }
            Remove-ServiceBinding  -ServiceBinding $TargetServiceBinding | Should  MatchHashtable ($response | ConvertFrom-Json)
            Assert-VerifiableMock
        }
    }
    Context "parameters" {
        It "ensures 'ServiceBinding' is not null" {
            {Remove-ServiceBinding -ServiceBinding $null } | Should -Throw "Cannot validate argument on parameter 'ServiceBinding'. The argument is null or empty"
        }
        It "supports positional" {
            Mock Invoke-WebRequest {@{StatusCode=204;Content=$response}}
            Remove-ServiceBinding $TargetServiceBinding | Should MatchHashtable ($response | ConvertFrom-Json)
        }
        It "'ServiceBinding' from pipeline" {
            Mock Invoke-WebRequest {@{StatusCode=204;Content=$response}}
            $TargetServiceBinding | Remove-ServiceBinding  | Should MatchHashtable ($response | ConvertFrom-Json)
        }
    }
}