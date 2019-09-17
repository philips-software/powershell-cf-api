$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\New-UserProvidedService.ps1"
. "$source\Get-BaseHost.ps1"
. "$source\Get-Header.ps1"
. "$source\Invoke-Retry.ps1"
. "$source\..\Private\Compare-HashTable.ps1"
. "$source\..\Private\PesterMatchHashtable.ps1"

Describe "New-UserProvidedService" {
    $TargetSpace = [PSCustomObject]@{metadata=@{guid="1"}}
    $TargetName="ups"    
    $TheContent = "{'foo':'bar'}"
    $TargetRouteServiceUrl ="rs"
    $TargetSyslogDrainUrl = "sdu"
    $TargetHeader = @{}
    $TargetParams = @()
    Mock Invoke-Retry { & $ScriptBlock } -Verifiable
    Mock Get-BaseHost { "basehost" } -Verifiable
    Mock Get-Header { $TargetHeader } -Verifiable
    Context "API Call" {
        Mock Invoke-WebRequest {@{StatusCode=201;Content=$TheContent}} -Verifiable -ParameterFilter {
            $MatchBody = @{
                "credentials"=$TargetParams
                "name"=$TargetName
                "route_service_url"= $TargetRouteServiceUrl
                "space_guid"=$TargetSpace.metadata.guid
                "syslog_drain_url"=$TargetSyslogDrainUrl
            }
            $hashtable = @{}
            (ConvertFrom-Json $Body).psobject.properties | ForEach-Object { $hashtable[$_.Name] = $_.Value } | Out-Null
            $Uri -eq "basehost/v2/user_provided_service_instances" -and $Method -eq "Post" `
                 -and (Compare-HashTable $hashtable $MatchBody) -eq $null `
                 -and (Compare-HashTable $Header $TargetHeader) -eq $null
        }
        It "calls proper web request" {
            New-UserProvidedService -Space $TargetSpace -Name $TargetName -Params $TargetParams -SyslogDrainUrl $TargetSyslogDrainUrl -RouteServiceUrl $TargetRouteServiceUrl | Should MatchHashtable ($TheContent | ConvertFrom-Json)
            Assert-VerifiableMock
        }
    }
    Context "API return values" {
        It "returns non 201 status" {            
            Mock Invoke-WebRequest {@{StatusCode=400;Content=$TheContent}}
            { New-UserProvidedService -Space $TargetSpace -Name $TargetName -Params $TargetParams -SyslogDrainUrl $TargetSyslogDrainUrl -RouteServiceUrl $TargetRouteServiceUrl }  | Should -Throw "basehost/v2/user_provided_service_instances 400"
        }
    }
    Context "parameters" {
        Mock Invoke-WebRequest {@{StatusCode=201;Content=$TheContent}} -Verifiable -ParameterFilter {
            $MatchBody = @{
                "credentials"=$TargetParams
                "name"=$TargetName
                "route_service_url"= $TargetRouteServiceUrl
                "space_guid"=$TargetSpace.metadata.guid
                "syslog_drain_url"=$TargetSyslogDrainUrl
            }
            $hashtable = @{}
            (ConvertFrom-Json $Body).psobject.properties | ForEach-Object { $hashtable[$_.Name] = $_.Value } | Out-Null
            $Uri -eq "basehost/v2/user_provided_service_instances" -and $Method -eq "Post" `
                 -and (Compare-HashTable $hashtable $MatchBody) -eq $null `
                 -and (Compare-HashTable $Header $TargetHeader) -eq $null
        }
        It "ensures 'Space' cannot be null" {
            {  New-UserProvidedService -Space $null -Name "x" -Params @() -SyslogDrainUrl "x" -RouteServiceUrl "x" } | Should -Throw "Cannot validate argument on parameter 'Space'. The argument is null or empty"
        }        
        It "ensures 'Name' cannot be null" {
            {  New-UserProvidedService -Space $TargetSpace -Name $null -Params @() -SyslogDrainUrl "x" -RouteServiceUrl "x" } | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty"
        }        
        It "ensures 'Name' cannot be empty" {
            {  New-UserProvidedService -Space $TargetSpace -Name "" -Params @() -SyslogDrainUrl "x" -RouteServiceUrl "x" } | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty"
        }        
        It "supports positional" {
            New-UserProvidedService -Space $TargetSpace -Name $TargetName -Params $TargetParams -SyslogDrainUrl $TargetSyslogDrainUrl -RouteServiceUrl $TargetRouteServiceUrl | Should MatchHashtable ($TheContent | ConvertFrom-Json)
            Assert-VerifiableMock
        }
        It "supports 'Space' from pipeline'" {
            $TargetSpace | New-UserProvidedService -Name $TargetName -Params $TargetParams -SyslogDrainUrl $TargetSyslogDrainUrl -RouteServiceUrl $TargetRouteServiceUrl | Should MatchHashtable ($TheContent | ConvertFrom-Json)
            Assert-VerifiableMock
        }
   }
}