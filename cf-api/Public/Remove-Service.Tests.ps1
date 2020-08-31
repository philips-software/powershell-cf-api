Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Remove-Service.ps1"
    . "$PSScriptRoot\..\Private\Get-BaseHost.ps1"
    . "$PSScriptRoot\..\Private\Get-Header.ps1"
    . "$PSScriptRoot\..\Private\Invoke-Retry.ps1"
}

Describe "Remove-Service" {
    BeforeAll {
        Mock Get-baseHost { "basehost" }
        Mock Get-Header { @{} }
        Mock Invoke-Retry { & $ScriptBlock }
        Mock Invoke-WebRequest
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $response = "{'foo': 'bar'}"
    }
    Context "calls depdendent cmdlets" {
        It "returns correct result when service_instances returns <StatusCode>" -TestCases @( @{StatusCode=204}, @{StatusCode=202}) {
            param ($StatusCode)
            Mock Invoke-WebRequest {@{StatusCode=$StatusCode;Content=$response}}
            Remove-Service -Guid "1"
            Should -Invoke Invoke-WebRequest -ParameterFilter {
                $Uri -eq "basehost/v2/service_instances/1?accepts_incomplete=true&async=true"
            }
        }
    }
    Context "parameters" {
        It "ensures 'Guid' is not null" {
            {Remove-Service -Guid $null } | Should -Throw "*Cannot validate argument on parameter 'Guid'. The argument is null or empty*"
        }
        It "ensures 'Guid' is not empty" {
            {Remove-Service -Guid "" } | Should -Throw "*Cannot validate argument on parameter 'Guid'. The argument is null or empty*"
        }
        It "supports positional" {
            Mock Invoke-WebRequest {@{StatusCode=204;Content=$response}}
            "1" | Remove-Service
        }
    }
}