$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-BaseHost.ps1"
$ErrorActionPreference = "silentlyContinue"
Describe "Get-BaseHost" {
    Context "Access Script Level Variables" {
        It "is not set" {
            { Get-BaseHost } | Should -Throw "baseHost is not set in script varaible. Call Get-Credentials first"
        }
        It "is set" {
            $h = "http://localhost"
            Set-Variable -Scope Script -Name baseHost -Value $h
            Get-BaseHost | Should be $h
        }
        It "is null" {            
            Set-Variable -Scope Script -Name baseHost -Value $null
            { Get-BaseHost } | Should -Throw "baseHost is not set in script varaible. Call Get-Credentials first"
        }

    }
}