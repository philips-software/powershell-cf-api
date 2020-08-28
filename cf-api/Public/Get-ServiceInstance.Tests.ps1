Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-ServiceInstance.ps1"
    . "$PSScriptRoot\Get-SpaceSummary.ps1"
}

Describe "Get-ServiceBindings" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Space = New-Object PsObject
        $service1 = [PSCustomObject]@{name="service1"}
        $service2 = [PSCustomObject]@{name="service2"}
        $Summary = [PSCustomObject]@{services=@($service2, $service1)}
        Mock Get-SpaceSummary { $Summary }
    }
    Context "API call" {
        It "is called with correct space object" {
            Get-ServiceInstance -Space $Space -Name $service1.name
            Should -Invoke Get-SpaceSummary -ParameterFilter {$space -eq $Space}
        }
        It "returns null when space Name not found" {
            (Get-ServiceInstance -Space $Space -Name "service3") | Should -Be $null
        }
    }
    Context "parameters" {
        It "ensures 'Space' cannot be null" {
            { Get-ServiceInstance -Space $null } | Should -Throw "*Cannot validate argument on parameter 'Space'. The argument is null or empty*"
        }
        It "ensures 'Name' cannot be null" {
            { Get-ServiceInstance -Space @{} -Name $null } | Should -Throw "*Cannot validate argument on parameter 'Name'. The argument is null or empty*"
        }
        It "ensures 'Name' cannot be empty" {
            { Get-ServiceInstance -Space (New-Object PsObject) -Name "" } | Should -Throw "*Cannot validate argument on parameter 'Name'. The argument is null or empty*"
        }
        It "supports positional" {
            (Get-ServiceInstance $Space "service1") | Should -Be $service1
        }
        It "supports 'Space' from pipeline" {
            ($Space | Get-ServiceInstance -Name $service1.name) | Should -Be $service1
        }
    }
}