$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\New-Space.ps1"
. "$source\Get-BaseHost.ps1"
. "$source\Get-Header.ps1"
. "$source\Invoke-Retry.ps1"
. "$source\..\Private\Compare-HashTable.ps1"
. "$source\..\Private\PesterMatchHashtable.ps1"

$ErrorActionPreference = "Stop"

Describe "New-Space" {
    $TargetOrg = New-Object PsObject -Property @{metadata=@{guid="1"}}
    $TheContent = "{'foo':'bar'}"
    $TargetName="space1"
    $TargetHeader = @{}
    Mock Invoke-Retry { & $ScriptBlock } -Verifiable
    Mock Get-BaseHost { "basehost" } -Verifiable
    Mock Get-Header { $TargetHeader } -Verifiable
    Context "API Call" {        
        Mock Invoke-WebRequest {@{StatusCode=201;Content=$TheContent}} -Verifiable -ParameterFilter {
            $MatchBody = @{
                "organization_guid" = $TargetOrg.metadata.guid
                "name" = $TargetName
            }
            $hashtable = @{}
            (ConvertFrom-Json $Body).psobject.properties | ForEach-Object { $hashtable[$_.Name] = $_.Value } | Out-Null
            $Uri -eq "basehost/v2/spaces" -and $Method -eq "Post" `
                -and (Compare-HashTable $hashtable $MatchBody) -eq $null `
                -and (Compare-HashTable $Header $TargetHeader) -eq $null
        }
        It "calls proper web request" {
            New-Space -Org $TargetOrg -Name $TargetName | Should MatchHashtable ($TheContent | ConvertFrom-Json)
            Assert-VerifiableMock
        }
        It "params by position" {
            New-Space $TargetOrg $TargetName | Should MatchHashtable ($TheContent | ConvertFrom-Json)
            Assert-VerifiableMock
        }
        It "supports pipeline" {
            $TargetOrg | New-Space -Name $TargetName | Should MatchHashtable ($TheContent | ConvertFrom-Json)
            Assert-VerifiableMock
        }
    }
    Context "API return values" {
        It "Returns non 201 status" {
            Mock Invoke-WebRequest {@{StatusCode=400;Content=$TheContent}}
            { New-Space -Org $TargetOrg -Name $TargetName }  | Should -Throw "basehost/v2/spaces 400"
        }
    }
    Context "Parameter validation" {
        It "That Org cannot be null" {
            {  New-Space -Org $null -Name "x" } | Should -Throw "Cannot validate argument on parameter 'Org'. The argument is null or empty"
        }        
   }    

}