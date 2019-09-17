$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-Env.ps1"
. "$source\..\Private\Invoke-GetRequest.ps1"

Describe "Get-Env" {
    $App = [PSCustomObject]@{metadata=@{guid="123"}}
    $Env = [PSCustomObject]@{name="foo"}
    Mock Invoke-GetRequest { $env } -Verifiable -ParameterFilter {$path -eq "/v2/apps/$($App.metadata.guid)/env"}
    Context "API call" {        
        It "is called with the correct URL" {
            Get-Env $App
            Assert-VerifiableMock
        }
        It "returns the psobject" {
            (Get-Env $App) | Should be $Env
        }
    }
    Context "parameters" {
        It "ensures 'App' cannot be null" {
            { Get-Env -App $null } | Should -Throw "The argument is null or empty"
        }
        It "supports positional" {
            Get-Env $App
            Assert-VerifiableMock
        }
        It "supports 'App' from pipeline" {
            $App | Get-Env | Should be $Env
            Assert-VerifiableMock
        }
    }    
}