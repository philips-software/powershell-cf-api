$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-SpaceSummary.ps1"
. "$source\..\Private\Invoke-GetRequest.ps1"

Describe "Get-SpaceSummary" {
    Context "API call" {
        $Space = New-Object PsObject -Property @{metadata=@{guid="1234"}}
        $Summary = @{}
        Mock Invoke-GetRequest { $Summary } `
            -Verifiable -ParameterFilter {$path -eq "/v2/spaces/$($space.metadata.guid)/summary"}
        
        It "Called with the correct URL" {
            Get-SpaceSummary -Space $Space
            Assert-VerifiableMock
        }
        It "Returns the summary" {
            (Get-SpaceSummary -Space $Space) | Should be $Summary
        }
        It "Uses value from pipeline" {
            $Space | Get-SpaceSummary | Should be $Summary
        }
        It "Uses positional arguments" {
            Get-SpaceSummary $Space | Should be $Summary
        }

    }
    Context "Parameter validation" {
        It "That Space cannot be null" {
            { Get-SpaceSummary -Space $null } | Should -Throw "Cannot validate argument on parameter 'Space'. The argument is null or empty"
        }
    }    
}