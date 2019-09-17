$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-App.ps1"
. "$source\..\Private\Invoke-GetRequest.ps1"

Describe "Get-App" {
    $TargetApp = [PSCustomObject]@{Name="myApp"}
    $TargetSpace = [PSCustomObject]@{metadata=@{guid="123"}}
    $response = [PSCustomObject]@{resources=@($TargetApp)}
    Mock Invoke-GetRequest { $response } -Verifiable -ParameterFilter {$path -eq "/v2/apps?q=name%3A$($TargetApp.Name)&q=space_guid%3A$($TargetSpace.metadata.guid)"}
    Context "API call" {        
        It "is called with the correct URL" {
            Get-App -Space $TargetSpace -Name $TargetApp.Name
            Assert-VerifiableMock
        }
        It "returns the first resource object" {
            (Get-App -Space $TargetSpace -Name $TargetApp.Name) | Should be $Targetapp
        }
    }
    Context "parameters" {
        It "ensures 'Name' cannot be empty" {
            { Get-App -Name "" } | Should -Throw "The argument is null or empty"
        }        
        It "ensures 'Name' cannot be null" {
            { Get-App -Name $null } | Should -Throw "The argument is null or empty"
        }
        It "ensures 'Space' cannot be empty" {
            { Get-App -Name "foo" -Space $null } | Should -Throw "The argument is null or empty"
        }
        It "supports positional" {
            Get-App $TargetSpace $TargetApp.Name
            Assert-VerifiableMock            
        }
        It "supports 'Space' from pipeline" {
            $TargetSpace | Get-App -Name $TargetApp.Name | Should be $Targetapp
        }
    }    
}