$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-ServiceBindings.ps1"
. "$source\..\Private\Invoke-GetRequest.ps1"

Describe "Get-ServiceBindings" {
    Context "API call" {
        $App = New-Object PsObject -Property @{entity=@{service_bindings_url="http://bits/1"}}
        $ServiceBindings = @(New-Object PsObject -Property @{name="foo"})
        $invokeResponse = New-Object PsObject -Property @{resources=$ServiceBindings}
        Mock Invoke-GetRequest { $invokeResponse } `
            -Verifiable -ParameterFilter {$path -eq "$($App.entity.service_bindings_url)"}
        
        It "Called with the correct URL" {
            Get-ServiceBindings -App $App
            Assert-VerifiableMock
        }
        It "Returns the first resource object" {
            (Get-ServiceBindings -App $App) | Should be $ServiceBindings
        }
        It "Uses App from pipeline" {
            $App | Get-ServiceBindings | Should be $ServiceBindings
        }
    }
    Context "Parameter validation" {
        It "App cannot be null" {
            { Get-ServiceBindings -App $null } | Should -Throw "Cannot validate argument on parameter 'App'. The argument is null or empty"
        }
    }    
}