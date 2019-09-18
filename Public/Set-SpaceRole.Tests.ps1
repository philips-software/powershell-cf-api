$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Set-SpaceRole.ps1"
. "$source\Get-BaseHost.ps1"
. "$source\Get-Header.ps1"
. "$source\Invoke-Retry.ps1"
. "$source\..\Private\Compare-HashTable.ps1"
. "$source\..\Private\PesterMatchHashtable.Tests.ps1"

Describe "SetSpaceRole" {
    Mock Get-baseHost { "basehost" }
    Mock Get-Header { @{} }
    Mock Invoke-Retry { & $ScriptBlock } -Verifiable
    Mock Invoke-WebRequest
    $response = "{'foo': 'bar'}"
    $TargetSpace = [pscustomobject]@{
        entity=[pscustomobject]@{auditors_url="auditurl"}
        metadata=@{guid="1"}
    }
    $TargetUserName = "user1"
    $TargetRole = "auditors"
    $TargetBody  = @{"username" = $TargetUserName }
    Context "API calls" {
        It "returns correct result when service_instances returns <StatusCode>" -TestCases @( @{StatusCode=201}) {
            param ($StatusCode)
            Mock Invoke-WebRequest {@{StatusCode=$StatusCode;Content=$response}} -Verifiable -ParameterFilter {
                $hashtable = @{}
                (ConvertFrom-Json $Body).psobject.properties | ForEach-Object { $hashtable[$_.Name] = $_.Value }
                $url -eq "basehostauditurl" -and $Method -eq "Put" -And (Compare-HashTable $hashtable $TargetBody) -eq $null
            }
            Set-SpaceRole -Space $TargetSpace -UserName $TargetUserName -Role $TargetRole | Should  MatchHashtable ($response | ConvertFrom-Json)
            Assert-VerifiableMock
        }
    }
    Context "parameters" {
        Mock Invoke-WebRequest {@{StatusCode=201;Content=$response}}
        It "ensures 'Space' is not null" {
            {Set-SpaceRole -Space $null -UserName $TargetUserName -Role $TargetRole } | Should -Throw "Cannot validate argument on parameter 'Space'. The argument is null or empty"
        }
        It "ensures 'Username' is not empty" {
            {Set-SpaceRole -Space $TargetSpace -UserName "" -Role $TargetRole } | Should -Throw "Cannot validate argument on parameter 'UserName'. The argument is null or empty"
        }
        It "ensures 'Username' is not null" {
            {Set-SpaceRole -Space $TargetSpace -UserName $null -Role $TargetRole } | Should -Throw "Cannot validate argument on parameter 'UserName'. The argument is null or empty"
        }
        It "ensures 'Role' is not empty" {
            {Set-SpaceRole -Space $TargetSpace -UserName $TargetRole -Role "" } | Should -Throw "Cannot validate argument on parameter 'Role'. The argument is null or empty"
        }
        It "ensures 'Role' is not null" {
            {Set-SpaceRole -Space $TargetSpace -UserName $TargetRole -Role $null } | Should -Throw "Cannot validate argument on parameter 'Role'. The argument is null or empty"
        }
        It "supports positional" {            
            Set-SpaceRole $TargetSpace $TargetUserName $TargetRole
        }
        It "supports 'Space' from pipeline" {
            $TargetSpace | Set-SpaceRole -UserName $TargetUserName -Role $TargetRole
        }

    }
}