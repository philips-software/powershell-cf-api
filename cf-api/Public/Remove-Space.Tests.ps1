Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Remove-Space.ps1"
    . "$PSScriptRoot\Get-BaseHost.ps1"
    . "$PSScriptRoot\Get-Header.ps1"
    . "$PSScriptRoot\Invoke-Retry.ps1"
}

Describe "Remove-Service" {
    BeforeAll {
        Mock Get-baseHost { "basehost" }
        Mock Get-Header { @{} }
        Mock Invoke-Retry { & $ScriptBlock } -Verifiable
        Mock Invoke-WebRequest
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $response = "{'foo': 'bar'}"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetSpace = @{metadata=@{guid="1"}}
    }
    Context "calls depdendent cmdlets" {
        It "returns correct result when service_instances returns <StatusCode>" -TestCases @( @{StatusCode=202}) {
            param ($StatusCode)
            Mock Invoke-WebRequest {@{StatusCode=$StatusCode;Content=$response}}
            Remove-Space -Space $TargetSpace
            Should -Invoke Invoke-WebRequest -ParameterFilter {$Uri -eq "basehost/v2/spaces/$($TargetSpace.metadata.guid)?async=true&recursive=true" -and $Method -eq "Delete" }
        }
    }
    Context "parameters" {
        It "ensures 'ServiceBinding' is not null" {
            {Remove-Space -Space $null } | Should -Throw "*Cannot validate argument on parameter 'Space'. The argument is null or empty*"
        }
        It "supports positional" {
            Mock Invoke-WebRequest {@{StatusCode=202;Content=$response}}
            Remove-Space $TargetSpace
        }
        It "supports 'Space' from pipeline" {
            Mock Invoke-WebRequest {@{StatusCode=202;Content=$response}}
            $TargetSpace | Remove-Space
        }
    }
}