$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Remove-AllServiceBindings.ps1"
. "$source\Get-SpaceSummary.ps1"
. "$source\Get-App.ps1"
. "$source\Get-ServiceBindings.ps1"
. "$source\Remove-ServiceBinding.ps1"

Describe "Remove-AllServiceBindings" {
    $TargetSpace = [PSCustomObject]@{name="myspace"}
    Context "calls depdendent cmdlets" {
        It "has no apps" {
            $TargetSpaceSummary = @{apps=@()}
            Mock Get-SpaceSummary { $TargetSpaceSummary } -Verifiable -ParameterFilter { $Space -eq $TargetSpace }
            Remove-AllServiceBindings $TargetSpace
            Assert-VerifiableMock
        }
        It "app with no bindings" {
            $TargetApp = @{name="app1"}
            $TargetSpaceSummary = @{apps=@($TargetApp)}
            $TargetServiceBindings = @()
            Mock Get-SpaceSummary { $TargetSpaceSummary } -Verifiable -ParameterFilter { $Space -eq $TargetSpace }
            Mock Get-App { $TargetApp } -Verifiable -ParameterFilter { $Space -eq $TargetSpace -and $Name -eq $TargetApp.name }
            Mock Get-ServiceBindings { $TargetServiceBindings } -Verifiable -ParameterFilter { $App -eq $TargetApp }
            Remove-AllServiceBindings $TargetSpace
            Assert-VerifiableMock
        }
        It "app with one binding is removed" {
            $TargetApp = @{name="app1"}
            $TargetSpaceSummary = @{apps=@($TargetApp)}
            $TargetServiceBinding = @{}
            $TargetServiceBindings = @($TargetServiceBinding)
            Mock Get-SpaceSummary { $TargetSpaceSummary } -Verifiable -ParameterFilter { $Space -eq $TargetSpace }
            Mock Get-App { $TargetApp } -Verifiable -ParameterFilter { $Space -eq $TargetSpace -and $Name -eq $TargetApp.name }
            Mock Get-ServiceBindings { $TargetServiceBindings } -Verifiable -ParameterFilter { $App -eq $TargetApp }
            Mock Remove-ServiceBinding -Verifiable -ParameterFilter { $ServiceBinding -eq $TargetServiceBinding }
            Remove-AllServiceBindings $TargetSpace
            Assert-VerifiableMock
        }
    }
    Context "parameters" {
        It "ensures 'Space' is not null" {
            {Remove-AllServiceBindings -Space $null } | Should -Throw "Cannot validate argument on parameter 'Space'. The argument is null or empty"
        }
        It "supports positional" {
            { Remove-AllServiceBindings $null } | Should -Throw "Cannot validate argument on parameter 'Space'. The argument is null or empty"
        }
    }
}
