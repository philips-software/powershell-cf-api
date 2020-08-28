Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Remove-AllServiceBindings.ps1"
    . "$PSScriptRoot\Get-SpaceSummary.ps1"
    . "$PSScriptRoot\Get-App.ps1"
    . "$PSScriptRoot\Get-ServiceBindings.ps1"
    . "$PSScriptRoot\Remove-ServiceBinding.ps1"
    }

Describe "Remove-AllServiceBindings" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetSpace = [PSCustomObject]@{name="myspace"}
    }
    Context "calls depdendent cmdlets" {
        It "has no apps" {
            $TargetSpaceSummary = @{apps=@()}
            Mock Get-SpaceSummary { $TargetSpaceSummary }
            Remove-AllServiceBindings $TargetSpace
            Should -Invoke Get-SpaceSummary -ParameterFilter { $Space -eq $TargetSpace }
        }
        It "app with no bindings" {
            $TargetApp = @{name="app1"}
            $TargetSpaceSummary = @{apps=@($TargetApp)}
            $TargetServiceBindings = @()
            Mock Get-SpaceSummary { $TargetSpaceSummary }
            Mock Get-App { $TargetApp }
            Mock Get-ServiceBindings { $TargetServiceBindings }
            Remove-AllServiceBindings $TargetSpace
            Should -Invoke Get-SpaceSummary -ParameterFilter { $Space -eq $TargetSpace }
            Should -Invoke Get-App -ParameterFilter { $Space -eq $TargetSpace -and $Name -eq $TargetApp.name }
            Should -Invoke Get-ServiceBindings -ParameterFilter { $App -eq $TargetApp }
        }
        It "app with one binding is removed" {
            $TargetApp = @{name="app1"}
            $TargetSpaceSummary = @{apps=@($TargetApp)}
            $TargetServiceBinding = @{}
            $TargetServiceBindings = @($TargetServiceBinding)
            Mock Get-SpaceSummary { $TargetSpaceSummary }
            Mock Get-App { $TargetApp }
            Mock Get-ServiceBindings { $TargetServiceBindings }
            Mock Remove-ServiceBinding
            Remove-AllServiceBindings $TargetSpace
            Should -Invoke Get-SpaceSummary -ParameterFilter { $Space -eq $TargetSpace }
            Should -Invoke Get-App -ParameterFilter { $Space -eq $TargetSpace -and $Name -eq $TargetApp.name }
            Should -Invoke Get-ServiceBindings -ParameterFilter { $App -eq $TargetApp }
            Should -Invoke Remove-ServiceBinding -ParameterFilter { $ServiceBinding -eq $TargetServiceBinding }
        }
    }
    Context "parameters" {
        It "ensures 'Space' is not null" {
            {Remove-AllServiceBindings -Space $null } | Should -Throw "*Cannot validate argument on parameter 'Space'. The argument is null or empty*"
        }
        It "supports positional" {
            { Remove-AllServiceBindings $null } | Should -Throw "*Cannot validate argument on parameter 'Space'. The argument is null or empty*"
        }
    }
}
