$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-Env.ps1"
. "$source\..\Private\Invoke-GetRequest.ps1"

Describe "Get-Env" {
    Context "API call" {
        $App = New-Object PsObject -Property @{metadata=@{guid="123"}}
        $Env = New-Object PsObject -Property @{name="foo"}
        Mock Invoke-GetRequest { $env } `
            -Verifiable -ParameterFilter {$path -eq "/v2/apps/$($App.metadata.guid)/env"}
        
        It "Called with the correct URL" {
            Get-Env $App
            Assert-VerifiableMock
        }
        It "Returns the psobject" {
            (Get-Env $App) | Should be $Env
        }
        It "Uses App from pipeline" {
            $App | Get-Env | Should be $Env
        }
    }
    Context "Parameter validation" {
        It "App cannot be null" {
            { Get-Env -App $null } | Should -Throw "The argument is null or empty"
        }
    }    
}