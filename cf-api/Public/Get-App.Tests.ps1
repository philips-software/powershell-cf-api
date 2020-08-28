Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-App.ps1"
    . "$PSScriptRoot\..\Private\Invoke-GetRequest.ps1"
}

Describe "Get-App" {
    BeforeAll {
        $TargetApp = [PSCustomObject]@{Name="myApp"}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetSpace = [PSCustomObject]@{metadata=@{guid="123"}}
        $response = [PSCustomObject]@{resources=@($TargetApp)}
        Mock Invoke-GetRequest { $response }
    }
    Context "API call" {
        It "is called with the correct URL" {
            Get-App -Space $TargetSpace -Name $TargetApp.Name
            Should -Invoke Invoke-GetRequest -ParameterFilter {$path -eq "/v2/apps?q=name%3A$($TargetApp.Name)&q=space_guid%3A$($TargetSpace.metadata.guid)"}
        }
        It "returns the first resource object" {
            (Get-App -Space $TargetSpace -Name $TargetApp.Name) | Should -Be $Targetapp
        }
    }
    Context "parameters" {
        It "ensures 'Name' cannot be empty" {
            { Get-App -Name "" } | Should -Throw "*The argument is null or empty*"
        }
        It "ensures 'Name' cannot be null" {
            { Get-App -Name $null } | Should -Throw "*The argument is null or empty*"
        }
        It "ensures 'Space' cannot be empty" {
            { Get-App -Name "foo" -Space $null } | Should -Throw "*The argument is null or empty*"
        }
        It "supports positional" {
            Get-App $TargetSpace $TargetApp.Name
            Should -Invoke Invoke-GetRequest -ParameterFilter {$path -eq "/v2/apps?q=name%3A$($TargetApp.Name)&q=space_guid%3A$($TargetSpace.metadata.guid)"}
        }
        It "supports 'Space' from pipeline" {
            $TargetSpace | Get-App -Name $TargetApp.Name | Should -Be $Targetapp
        }
    }
}