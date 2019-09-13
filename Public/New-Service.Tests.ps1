$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\New-Service.ps1"
. "$source\Get-BaseHost.ps1"
. "$source\Get-Header.ps1"
. "$source\Invoke-Retry.ps1"
. "$source\..\Private\Compare-HashTable.ps1"
. "$source\..\Private\PesterMatchHashtable.ps1"

$ErrorActionPreference = "Stop"

Describe "New-Service" {
    $Space = New-Object PsObject -Property @{metadata=@{guid="1"}}
    $serviceplan1 = New-Object PsObject -Property @{entity=@{name="plan1"};metadata=@{guid="2"}}
    $serviceplan2 = New-Object PsObject -Property @{entity=@{name="plan2"};metadata=@{guid="3"}}
    $ServicePlans = @($serviceplan1,$serviceplan2)
    $Name = "servicename1"
    Mock Invoke-Retry { & $ScriptBlock}
    It "Service plan not found" {
        {New-Service -Space $Space -ServicePlans $ServicePlans -Plan "notfound" -Name $Name} | Should -Throw "service plan not found"
    }
    It "given service_instances returns <StatusCode>" -TestCases @( @{StatusCode=202}, @{StatusCode=201}) {
        param ($StatusCode)
        $response = "{'foo': 'bar'}"
        Mock Get-baseHost { "http://google.com" }
        Mock Get-Header { @{} }
        Mock -Command Invoke-WebRequest -MockWith {@{StatusCode=$StatusCode;Content=$response}}
        New-Service -Space $Space -ServicePlans $ServicePlans -Plan "plan1" -Name $Name | Should MatchHashtable ($response | ConvertFrom-Json)
    }
    It "given service_instances returns <StatusCode>" -TestCases @( @{StatusCode=500}, @{StatusCode=401}) {
        param ($StatusCode)
        $response = "{'foo': 'bar'}"
        Mock Get-baseHost { "http://google.com" }
        Mock Get-Header { @{} }
        Mock -Command Invoke-WebRequest -MockWith {@{StatusCode=$StatusCode;Content=$response}}
        { New-Service -Space $Space -ServicePlans $ServicePlans -Plan "plan1" -Name $Name } | Should -Throw "http://google.com/v2/service_instances?accepts_incomplete=true $($StatusCode)"
    }    
    It "given service_instances returns <StatusCode>" -TestCases @( @{StatusCode=204}) {
        param ($StatusCode)
        $response = "{'foo': 'bar'}"
        Mock Get-baseHost { "http://google.com" }
        Mock Get-Header { @{} }
        Mock -Command Invoke-WebRequest -MockWith {@{StatusCode=$StatusCode;Content=$response}}
        { New-Service -Space $Space -ServicePlans $ServicePlans -Plan "plan1" -Name $Name } | Should -Throw " http://google.com/v2/service_instances?accepts_incomplete=true $($StatusCode)"
    }    
    Context "Correct results" {
        $response = "{'foo': 'bar'}"
        Mock Get-baseHost { "http://google.com" }
        Mock Get-Header { @{} }
        Mock -Command Invoke-WebRequest -MockWith { @{StatusCode=202;Content=$response} } `
            -ParameterFilter { 
                $MatchBody = @{      
                    "name" = $Name
                    "parameters" = @()
                    "service_plan_guid" = $serviceplan[0].metadata.guid
                    "space_guid" = $Space.metadata.guid
                }
                $hashtable = @{}
                (ConvertFrom-Json $Body).psobject.properties | ForEach-Object { $hashtable[$_.Name] = $_.Value }
                (Compare-HashTable $hashtable $MatchBody) -eq $null
            }
        it "passes" {
            New-Service -Space $Space -ServicePlans $ServicePlans -Plan "plan1" -Name $Name | Should MatchHashtable ($response | ConvertFrom-Json)
            Assert-VerifiableMock
        }
    }
}