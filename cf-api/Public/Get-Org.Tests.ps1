Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Org.ps1"
    . "$PSScriptRoot\..\Private\Invoke-GetRequest.ps1"
}

Describe "Get-Org" {
    BeforeAll {
        $orgName = "myorgname"
        $org = [PSCustomObject]@{name=$orgName}
        Mock Invoke-GetRequest { [PSCustomObject]@{resources=@($org)} }
    }
    Context "API calls" {
        It "is called with the correct URL" {
            Get-Org -Name $orgName
            Should -Invoke Invoke-GetRequest -ParameterFilter {$path -eq "/v2/organizations?order-by=name&q=name%3A$($orgName)"}
        }
        It "returns the first resource object" {
            (Get-Org -Name $orgName) | Should -Be $org
        }
    }
    Context "parameters" {
        It "ensures 'Name' cannot be empty" {
            { Get-Org "" } | Should -Throw "*The argument is null or empty*"
        }
        It "ensures 'Name' cannot be null" {
            { Get-Org $null } | Should -Throw "*The argument is null or empty*"
        }
        It "support positional" {
            Get-Org $orgName | Should -Be $org
        }
        It "supports 'Name' from pipeline" {
            $orgName | Get-Org | Should -Be $org
        }
    }
}