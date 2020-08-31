Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Set-SpaceRole.ps1"
    . "$PSScriptRoot\..\Private\Get-BaseHost.ps1"
    . "$PSScriptRoot\..\Private\Get-Header.ps1"
    . "$PSScriptRoot\..\Private\Invoke-Retry.ps1"
}
Describe "SetSpaceRole" {
    BeforeAll {
        Mock Get-BaseHost { "basehost" }
        Mock Get-Header { @{} }
        Mock Invoke-Retry { & $ScriptBlock } -Verifiable
        Mock Invoke-WebRequest
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $response = "{'foo': 'bar'}"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetSpace = [pscustomobject]@{
            entity=[pscustomobject]@{auditors_url="auditurl"}
            metadata=@{guid="1"}
        }
        $TargetUserName = "user1"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetRole = "auditors"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetBody  = @{"username" = $TargetUserName }
    }
    Context "API calls" {
        It "returns correct result when service_instances returns <StatusCode>" -TestCases @( @{StatusCode=201}) {
            param ($StatusCode)
            Mock Invoke-WebRequest {@{StatusCode=$StatusCode;Content=$response}}
            Set-SpaceRole -Space $TargetSpace -UserName $TargetUserName -Role $TargetRole
            Should -Invoke Invoke-WebRequest -ParameterFilter {
                $uri -eq "basehostauditurl" -and $Method -eq "Put"
            }
        }
    }
    Context "parameters" {
        BeforeAll {
            Mock Invoke-WebRequest {@{StatusCode=201;Content=$response}}
        }
        It "ensures 'Space' is not null" {
            {Set-SpaceRole -Space $null -UserName $TargetUserName -Role $TargetRole } | Should -Throw "*Cannot validate argument on parameter 'Space'. The argument is null or empty*"
        }
        It "ensures 'Username' is not empty" {
            {Set-SpaceRole -Space $TargetSpace -UserName "" -Role $TargetRole } | Should -Throw "*Cannot validate argument on parameter 'UserName'. The argument is null or empty*"
        }
        It "ensures 'Username' is not null" {
            {Set-SpaceRole -Space $TargetSpace -UserName $null -Role $TargetRole } | Should -Throw "*Cannot validate argument on parameter 'UserName'. The argument is null or empty*"
        }
        It "ensures 'Role' is not empty" {
            {Set-SpaceRole -Space $TargetSpace -UserName $TargetRole -Role "" } | Should -Throw "*Cannot validate argument on parameter 'Role'. The argument is null or empty*"
        }
        It "ensures 'Role' is not null" {
            {Set-SpaceRole -Space $TargetSpace -UserName $TargetRole -Role $null } | Should -Throw "*Cannot validate argument on parameter 'Role'. The argument is null or empty*"
        }
        It "supports positional" {
            Set-SpaceRole $TargetSpace $TargetUserName $TargetRole
        }
        It "supports 'Space' from pipeline" {
            $TargetSpace | Set-SpaceRole -UserName $TargetUserName -Role $TargetRole
        }

    }
}