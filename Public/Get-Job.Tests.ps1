$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-Job.ps1"
. "$source\..\Private\Invoke-GetRequest.ps1"

Describe "Get-Job" {
    Context "API call" {
        $Job = New-Object PsObject -Property @{entity=@{guid="123"}}
        Mock Invoke-GetRequest { $job } `
            -Verifiable -ParameterFilter {$path -eq "/v2/jobs/$($Job.entity.guid)"}
        
        It "Called with the correct URL" {
            Get-Job -Job $Job
            Assert-VerifiableMock
        }
        It "Returns the first resource object" {
            (Get-Job -Job $Job) | Should be $Job
        }
        It "uses Job from pipeline" {
            $Job | Get-Job | Should be $Job
        }
    }
    Context "Parameter validation" {
        It "That Job cannot be null" {
            { Get-Job -Job $null } | Should -Throw "The argument is null or empty"
        }
    }    
}