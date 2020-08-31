Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\New-UserProvidedService.ps1"
    . "$PSScriptRoot\..\Private\Get-BaseHost.ps1"
    . "$PSScriptRoot\..\Private\Get-Header.ps1"
    . "$PSScriptRoot\..\Private\Invoke-Retry.ps1"
}

Describe "New-UserProvidedService" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetSpace = [PSCustomObject]@{metadata=@{guid="1"}}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetName="ups"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TheContent = "{'foo':'bar'}"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetRouteServiceUrl ="rs"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetSyslogDrainUrl = "sdu"
        $TargetHeader = @{}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetParams = @()
        Mock Invoke-Retry { & $ScriptBlock }
        Mock Get-BaseHost { "basehost" }
        Mock Get-Header { $TargetHeader }
    }
    Context "API Call" {
        It "calls proper web request" {
            Mock Invoke-WebRequest {@{StatusCode=201;Content=$TheContent}}
            New-UserProvidedService -Space $TargetSpace -Name $TargetName -Params $TargetParams -SyslogDrainUrl $TargetSyslogDrainUrl -RouteServiceUrl $TargetRouteServiceUrl #| Should MatchHashtable ($TheContent | ConvertFrom-Json)
            Should -Invoke Invoke-WebRequest
            # -ParameterFilter {
            #     $MatchBody = @{
            #         "credentials"=$TargetParams
            #         "name"=$TargetName
            #         "route_service_url"= $TargetRouteServiceUrl
            #         "space_guid"=$TargetSpace.metadata.guid
            #         "syslog_drain_url"=$TargetSyslogDrainUrl
            #     }
            #     $hashtable = @{}
            #     (ConvertFrom-Json $Body).psobject.properties | ForEach-Object { $hashtable[$_.Name] = $_.Value } | Out-Null
            #     $Uri -eq "basehost/v2/user_provided_service_instances" -and $Method -eq "Post" `
            #          -and (Compare-HashTable $hashtable $MatchBody) -eq $null `
            #          -and (Compare-HashTable $Header $TargetHeader) -eq $null
            # }
        }
    }
    Context "API return values" {
        It "returns non 201 status" {
            Mock Invoke-WebRequest {@{StatusCode=400;Content=$TheContent}}
            { New-UserProvidedService -Space $TargetSpace -Name $TargetName -Params $TargetParams -SyslogDrainUrl $TargetSyslogDrainUrl -RouteServiceUrl $TargetRouteServiceUrl }  | Should -Throw "*basehost/v2/user_provided_service_instances 400*"
        }
    }
    Context "parameters" {
        It "ensures 'Space' cannot be null" {
            {  New-UserProvidedService -Space $null -Name "x" -Params @() -SyslogDrainUrl "x" -RouteServiceUrl "x" } | Should -Throw "*Cannot validate argument on parameter 'Space'. The argument is null or empty*"
        }
        It "ensures 'Name' cannot be null" {
            {  New-UserProvidedService -Space $TargetSpace -Name $null -Params @() -SyslogDrainUrl "x" -RouteServiceUrl "x" } | Should -Throw "*Cannot validate argument on parameter 'Name'. The argument is null or empty*"
        }
        It "ensures 'Name' cannot be empty" {
            {  New-UserProvidedService -Space $TargetSpace -Name "" -Params @() -SyslogDrainUrl "x" -RouteServiceUrl "x" } | Should -Throw "*Cannot validate argument on parameter 'Name'. The argument is null or empty*"
        }
        It "supports positional" {
            Mock Invoke-WebRequest {@{StatusCode=201;Content=$TheContent}}
            New-UserProvidedService -Space $TargetSpace -Name $TargetName -Params $TargetParams -SyslogDrainUrl $TargetSyslogDrainUrl -RouteServiceUrl $TargetRouteServiceUrl
            Should -Invoke Invoke-WebRequest
        }
        It "supports 'Space' from pipeline'" {
            Mock Invoke-WebRequest {@{StatusCode=201;Content=$TheContent}}
            $TargetSpace | New-UserProvidedService -Name $TargetName -Params $TargetParams -SyslogDrainUrl $TargetSyslogDrainUrl -RouteServiceUrl $TargetRouteServiceUrl
            Should -Invoke Invoke-WebRequest
        }
   }
}