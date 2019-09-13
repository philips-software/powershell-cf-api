$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-App.ps1"
. "$source\..\Private\Invoke-GetRequest.ps1"

Describe "Get-App" {
    Context "API call" {
        $App = New-Object PsObject -Property @{Name="myApp"}
        $Space = New-Object PsObject -Property @{metadata=@{guid="123"}}
        $invokeResponse = New-Object PsObject -Property @{resources=@($App)}
        Mock Invoke-GetRequest { $invokeResponse } `
            -Verifiable -ParameterFilter {$path -eq "/v2/apps?q=name%3A$($App.Name)&q=space_guid%3A$($Space.metadata.guid)"}
        
        It "Called with the correct URL" {
            Get-App -Space $Space -Name $App.Name
            Assert-VerifiableMock
        }
        It "Returns the first resource object" {
            (Get-App -Space $Space -Name $App.Name) | Should be $app
        }
        It "Uses value from pipeline" {
            $Space | Get-App -Name $App.Name | Should be $app
        }
    }
    Context "Parameter validation" {
        It "That Name cannot be empty" {
            { Get-App -Name "" } | Should -Throw "The argument is null or empty"
        }        
        It "That Name cannot be null" {
            { Get-App -Name $null } | Should -Throw "The argument is null or empty"
        }
        It "That Space cannot be empty" {
            { Get-App -Name "foo" -Space $null } | Should -Throw "The argument is null or empty"
        }
    }    
}