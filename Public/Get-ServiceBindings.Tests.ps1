$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-ServiceBindings.ps1"
. "$source\..\Private\Invoke-GetRequest.ps1"

Describe "Get-ServiceBindings" {
    $App = [PSCustomObject]@{entity=@{service_bindings_url="http://bits/1"}}
    $ServiceBindings = @([PSCustomObject]@{name="foo"})
    $invokeResponse = [PSCustomObject]@{resources=$ServiceBindings}
    Mock Invoke-GetRequest { $invokeResponse } -Verifiable -ParameterFilter {$path -eq "$($App.entity.service_bindings_url)"}
    Context "API call" {        
        It "is called with the correct URL" {
            Get-ServiceBindings -App $App
            Assert-VerifiableMock
        }
        It "returns first resource object" {
            (Get-ServiceBindings -App $App) | Should be $ServiceBindings
        }
    }
    Context "parameters" {
        It "ensures 'App' cannot be null" {
            { Get-ServiceBindings -App $null } | Should -Throw "Cannot validate argument on parameter 'App'. The argument is null or empty"
        }
        It "supports positional" {
            Get-ServiceBindings $App | Should be $ServiceBindings
        }
        It "supports 'App' from pipeline" {
            $App | Get-ServiceBindings | Should be $ServiceBindings
        }
    }    
}