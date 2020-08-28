Set-StrictMode -Version Latest

BeforeAll {
    Remove-Module "cf-api"
    Import-Module (Join-Path $PSScriptRoot "../cf-api.psd1")
}
Describe "Get-BaseHost" {
    InModuleScope "cf-api" {
        Context "Access Script Level Variables" {
            It "throws exceptions when script level variable is not set" {
                { Get-BaseHost } | Should -Throw "*baseHost is not set in script variable*"
            }
            It "is set" {
                $script:baseHost = "http://localhost"
                Get-BaseHost | Should -Be "http://localhost"
            }
            It "is null" {
                $script:baseHost = $null
                { Get-BaseHost } | Should -Throw "*baseHost is not set in script variable*"
            }
        }
    }
}
