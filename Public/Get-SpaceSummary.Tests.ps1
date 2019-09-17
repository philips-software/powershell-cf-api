$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-SpaceSummary.ps1"
. "$source\..\Private\Invoke-GetRequest.ps1"

Describe "Get-SpaceSummary" {
    $Space = [PSCustomObject]@{metadata=@{guid="1234"}}
    $Summary = @{}
    Mock Invoke-GetRequest { $Summary } -Verifiable -ParameterFilter {$path -eq "/v2/spaces/$($space.metadata.guid)/summary"}
    Context "API call" {       
        It "is called with the correct URL" {
            Get-SpaceSummary -Space $Space
            Assert-VerifiableMock
        }
        It "returns the summary" {
            (Get-SpaceSummary -Space $Space) | Should be $Summary
        }
    }
    Context "parameters" {
        It "ensures 'Space' cannot be null" {
            { Get-SpaceSummary -Space $null } | Should -Throw "Cannot validate argument on parameter 'Space'. The argument is null or empty"
        }
        It "supports positional" {
            Get-SpaceSummary $Space | Should be $Summary
        }
        It "supports 'Space' from pipeline" {
            $Space | Get-SpaceSummary | Should be $Summary
        }
    }    
}