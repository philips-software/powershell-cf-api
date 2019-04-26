$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\Get-Org.ps1"
. "$here\..\Private\Invoke-GetRequest.ps1"

Describe "Get-Org" {
    Context "Rest Call" {
        $orgName = "myorgname"
        Mock Invoke-GetRequest { return New-Object PsObject -Property @{resources=@() } } -Verifiable -ParameterFilter {$path -eq "/v2/organizations?order-by=name&q=name%3A$($orgName)"}
        $result = Get-Org $orgName
        It "Called with the correct URL" {
            Assert-VerifiableMock
        }
    }
}