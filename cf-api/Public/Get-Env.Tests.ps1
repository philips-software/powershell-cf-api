Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Env.ps1"
    . "$PSScriptRoot\..\Private\Invoke-GetRequest.ps1"
}

Describe "Get-Env" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $App = [PSCustomObject]@{metadata=@{guid="123"}}
        $Env = [PSCustomObject]@{name="foo"}
        Mock Invoke-GetRequest { $env }
    }
    Context "API call" {
        It "is called with the correct URL" {
            Get-Env $App
            Should -Invoke Invoke-GetRequest -ParameterFilter {$path -eq "/v2/apps/$($App.metadata.guid)/env"}
        }
        It "returns the psobject" {
            (Get-Env $App) | Should -Be $Env
        }
    }
    Context "parameters" {
        It "ensures 'App' cannot be null" {
            { Get-Env -App $null } | Should -Throw "*The argument is null or empty*"
        }
        It "supports positional" {
            Get-Env $App
            Should -Invoke Invoke-GetRequest -ParameterFilter {$path -eq "/v2/apps/$($App.metadata.guid)/env"}
        }
        It "supports 'App' from pipeline" {
            $App | Get-Env | Should -Be $Env
            Should -Invoke Invoke-GetRequest -ParameterFilter {$path -eq "/v2/apps/$($App.metadata.guid)/env"}
        }
    }
}