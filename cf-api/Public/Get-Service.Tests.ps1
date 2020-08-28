Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Service.ps1"
    . "$PSScriptRoot\..\Private\Invoke-GetRequest.ps1"
}

Describe "Get-Service" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Space = [PSCustomObject]@{metadata=@{guid="123"}}
        $Service = [PSCustomObject]@{Name="service1"}
        $invokeResponse = [PSCustomObject]@{resources=@($Service)}
        Mock Invoke-GetRequest { $invokeResponse }
    }
    Context "API call" {
        It "is called with the correct URL" {
            Get-Service -Space $Space -Name $Service.Name
            Should -Invoke Invoke-GetRequest -ParameterFilter {$path -eq "/v2/spaces/$($Space.metadata.guid)/services?q=label%3A$($Service.Name)"}
        }
        It "returns the first resource object" {
            (Get-Service -Space $Space -Name $Service.Name) | Should -Be $Service
        }
    }
    Context "parameters" {
        It "ensures 'Name' cannot be empty" {
            { Get-Service -Space @{} -Name "" } | Should -Throw "*Cannot validate argument on parameter 'Name'. The argument is null or empty*"
        }
        It "ensures 'Name' cannot be null" {
            { Get-Service -Space @{} -Name $null } | Should -Throw "*Cannot validate argument on parameter 'Name'. The argument is null or empty*"
        }
        It "ensures 'Space' cannot be null" {
            { Get-Service -Space $null -Name "foo" } | Should -Throw "*Cannot validate argument on parameter 'Space'. The argument is null or empty*"
        }
        It "support positional" {
            (Get-Service $Space $Service.Name) | Should -Be $Service
        }
        It "supports 'Space' from pipeline" {
            ($Space | Get-Service -Name $Service.Name) | Should -Be $Service
        }
    }
}