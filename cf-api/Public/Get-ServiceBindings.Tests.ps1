Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-ServiceBindings.ps1"
    . "$PSScriptRoot\..\Private\Invoke-GetRequest.ps1"
}

Describe "Get-ServiceBindings" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $App = [PSCustomObject]@{entity=@{service_bindings_url="http://bits/1"}}
        $ServiceBindings = @([PSCustomObject]@{name="foo"})
        $invokeResponse = [PSCustomObject]@{resources=$ServiceBindings}
        Mock Invoke-GetRequest { $invokeResponse }
    }
    Context "API call" {
        It "is called with the correct URL" {
            Get-ServiceBindings -App $App
            Should -Invoke Invoke-GetRequest -ParameterFilter {$path -eq "$($App.entity.service_bindings_url)"}
        }
        It "returns first resource object" {
            (Get-ServiceBindings -App $App) | Should -Be $ServiceBindings
        }
    }
    Context "parameters" {
        It "ensures 'App' cannot be null" {
            { Get-ServiceBindings -App $null } | Should -Throw "*Cannot validate argument on parameter 'App'. The argument is null or empty*"
        }
        It "supports positional" {
            Get-ServiceBindings $App | Should -Be $ServiceBindings
        }
        It "supports 'App' from pipeline" {
            $App | Get-ServiceBindings | Should -Be $ServiceBindings
        }
    }
}