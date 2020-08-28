Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-SpaceSummary.ps1"
    . "$PSScriptRoot\..\Private\Invoke-GetRequest.ps1"
}

Describe "Get-SpaceSummary" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Space = [PSCustomObject]@{metadata=@{guid="1234"}}
        $Summary = @{}
        Mock Invoke-GetRequest { $Summary }
    }
    Context "API call" {
        It "is called with the correct URL" {
            Get-SpaceSummary -Space $Space
            Should -Invoke Invoke-GetRequest -ParameterFilter {$path -eq "/v2/spaces/$($space.metadata.guid)/summary"}
        }
        It "returns the summary" {
            (Get-SpaceSummary -Space $Space) | Should -Be $Summary
        }
    }
    Context "parameters" {
        It "ensures 'Space' cannot be null" {
            { Get-SpaceSummary -Space $null } | Should -Throw "*Cannot validate argument on parameter 'Space'. The argument is null or empty*"
        }
        It "supports positional" {
            Get-SpaceSummary $Space | Should -Be $Summary
        }
        It "supports 'Space' from pipeline" {
            $Space | Get-SpaceSummary | Should -Be $Summary
        }
    }
}