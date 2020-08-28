Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Space.ps1"
    . "$PSScriptRoot\..\Private\Invoke-GetRequest.ps1"
}

Describe "Get-Space" {
    BeforeAll {
        $Space = [PSCustomObject]@{name="app1"}
        $invokeResponse = [PSCustomObject]@{resources=@($Space)}
        Mock Invoke-GetRequest { $invokeResponse }
    }
    Context "API call" {
        It "is called with the correct URL" {
            Get-Space -Name $Space.Name
            Should -Invoke Invoke-GetRequest -ParameterFilter {$path -eq "/v2/spaces?order-by=name&q=name%3A$($Space.name)"}
        }
        It "returns the first resource object" {
            (Get-Space -Name $Space.Name) | Should -Be $Space
        }
    }
    Context "parameters" {
        It "ensures 'Name' cannot be empty" {
            { Get-Space -Name "" } | Should -Throw "*Cannot validate argument on parameter 'Name'. The argument is null or empty*"
        }
        It "ensures 'Name' cannot be null" {
            { Get-Space -Name $null } | Should -Throw "*Cannot validate argument on parameter 'Name'. The argument is null or empty*"
        }
        It "supports positional" {
            Get-Space $Space.Name | Should -Be $Space
        }
        It "supports 'Space' from pipeline" {
            $Space.Name | Get-Space | Should -Be $Space
        }
    }
}