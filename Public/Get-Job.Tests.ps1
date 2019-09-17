$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-Job.ps1"
. "$source\..\Private\Invoke-GetRequest.ps1"

Describe "Get-Job" {
    $Job = [PSCustomObject]@{entity=@{guid="123"}}
    Mock Invoke-GetRequest { $job } -Verifiable -ParameterFilter {$path -eq "/v2/jobs/$($Job.entity.guid)"}
    Context "API call" {        
        It "is called with the correct URL" {
            Get-Job -Job $Job
            Assert-VerifiableMock
        }
        It "returns the first resource object" {
            (Get-Job -Job $Job) | Should be $Job
        }
    }
    Context "parameters" {
        It "esures 'Job' cannot be null" {
            { Get-Job -Job $null } | Should -Throw "The argument is null or empty"
        }
        It "supports positional" {
            Get-Job $Job
            Assert-VerifiableMock
        }
        It "supports 'Job' from pipeline" {
            $Job | Get-Job | Should be $Job
            Assert-VerifiableMock
        }
    }    
}