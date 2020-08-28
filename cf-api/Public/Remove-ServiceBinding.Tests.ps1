Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Remove-ServiceBinding.ps1"
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
        $TargetServiceBinding = @{metadata=@{guid="1"}}
    }
    Context "calls depdendent cmdlets" {
        It "returns correct result when service_instances returns <StatusCode>" -TestCases @( @{StatusCode=204}) {
            param ($StatusCode)
            Mock Invoke-WebRequest {@{StatusCode=$StatusCode;Content=$response}}
            Remove-ServiceBinding  -ServiceBinding $TargetServiceBinding
            Should -Invoke Invoke-WebRequest -ParameterFilter {$Uri -eq "basehost/v2/service_bindings/$($TargetServiceBinding.metadata.guid)?accepts_incomplete=true" -and $Method -eq "Delete" }
        }
    }
    Context "parameters" {
        It "ensures 'ServiceBinding' is not null" {
            {Remove-ServiceBinding -ServiceBinding $null } | Should -Throw "*Cannot validate argument on parameter 'ServiceBinding'. The argument is null or empty*"
        }
        It "supports positional" {
            Mock Invoke-WebRequest {@{StatusCode=204;Content=$response}}
            Remove-ServiceBinding $TargetServiceBinding
        }
        It "'ServiceBinding' from pipeline" {
            Mock Invoke-WebRequest {@{StatusCode=204;Content=$response}}
            $TargetServiceBinding | Remove-ServiceBinding
        }
    }
}