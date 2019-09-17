$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-BaseHost.ps1"
Describe "Get-BaseHost" {
    Context "Access Script Level Variables" {
        It "throws exceptions when script level variable is not set" {
            { Get-BaseHost } | Should -Throw "baseHost is not set in script variable. Call Get-Credentials first"
        }
        It "is set" {
            $hostUrl = "http://localhost"
            Set-Variable -Scope Script -Name baseHost -Value $hostUrl
            Get-BaseHost | Should be $hostUrl
        }
        It "is null" {            
            Set-Variable -Scope Script -Name baseHost -Value $null
            { Get-BaseHost } | Should -Throw "baseHost is not set in script variable. Call Get-Credentials first"
        }

    }
}