Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Job.ps1"
    . "$PSScriptRoot\..\Private\Invoke-GetRequest.ps1"
}
Describe "Get-Job" {
    BeforeAll {
        $Job = [PSCustomObject]@{entity=@{guid="123"}}
        Mock Invoke-GetRequest { $job }
    }
    Context "API call" {
        It "is called with the correct URL" {
            Get-Job -Job $Job
            Should -Invoke Invoke-GetRequest -ParameterFilter {$path -eq "/v2/jobs/$($Job.entity.guid)"}
        }
        It "returns the first resource object" {
            (Get-Job -Job $Job) | Should -Be $Job
        }
    }
    Context "parameters" {
        It "esures 'Job' cannot be null" {
            { Get-Job -Job $null } | Should -Throw "*The argument is null or empty*"
        }
        It "supports positional" {
            Get-Job $Job
            Should -Invoke Invoke-GetRequest -ParameterFilter {$path -eq "/v2/jobs/$($Job.entity.guid)"}
        }
        It "supports 'Job' from pipeline" {
            $Job | Get-Job | Should -Be $Job
            Should -Invoke Invoke-GetRequest -ParameterFilter {$path -eq "/v2/jobs/$($Job.entity.guid)"}
        }
    }
}