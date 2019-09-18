param ($orgname, $username, $password, $api)
Import-Module "$PSScriptRoot/../cf-api.psm1" -Force

$script:VerbosePreference = "SilentlyContinue"

Describe "Integration Test" {
    Context "Using definition" {
        $org = Get-OrgCredentials $orgname $username $password -Verbose -CloudFoundryAPI $api
        $def = Get-Content .\test-definition.json -Verbose | ConvertFrom-Json
        It "Publishes" {            
            Publish-Space -Org $org -Definition $def -Verbose 
            $Space = Get-Space "test-integration-12938472947"
            $SpaceSummary = Get-SpaceSummary -Space $Space 
            Write-Verbose ($SpaceSummary | ConvertTo-Json -Depth 20)
            $SpaceSummary.name | Should be "test-integration-12938472947"
            $SpaceSummary.services[0].name | Should be "logproxy"
            $SpaceSummary.services[0].type | Should be "user_provided_service_instance"
            $SpaceSummary.services[0].bound_app_count | Should be 0
            $SpaceSummary.services[1].name | Should be "myvault"
            $SpaceSummary.services[1].type | Should be "managed_service_instance"
            $SpaceSummary.services[1].bound_app_count | Should be 0
            $SpaceSummary.services[1].service_broker_name | Should be "hsdp-vault"
        }
        It "Unpublishes" {
            UnPublish-Space -Org $org -Definition $def -Verbose 
            Get-Space "test-integration-12938472947" | Should be $null            
        }
    }
}
