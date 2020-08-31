Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\New-Space.ps1"
    . "$PSScriptRoot\..\Private\Get-BaseHost.ps1"
    . "$PSScriptRoot\..\Private\Get-Header.ps1"
    . "$PSScriptRoot\..\Private\Invoke-Retry.ps1"
}

Describe "New-Space" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetOrg = New-Object PsObject -Property @{metadata=@{guid="1"}}
        $TheContent = "{'foo':'bar'}"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetName="space1"
        $TargetHeader = @{}
        Mock Invoke-Retry { & $ScriptBlock } -Verifiable
        Mock Get-BaseHost { "basehost" } -Verifiable
        Mock Get-Header { $TargetHeader } -Verifiable
        Mock Invoke-WebRequest {@{StatusCode=201;Content=$TheContent}}
    }
    # Context "API call" {
    #     It "calls proper web request" {
    #         Mock Invoke-WebRequest {@{StatusCode=201;Content=$TheContent}}
    #         New-Space -Org $TargetOrg -Name $TargetName | Should MatchHashtable ($TheContent | ConvertFrom-Json)
    #         Should -Invoke Invoke-WebRequest -ParameterFilter {
    #             $MatchBody = @{
    #                 "organization_guid" = $TargetOrg.metadata.guid
    #                 "name" = $TargetName
    #             }
    #             # $hashtable = @{}
    #             # (ConvertFrom-Json $Body).psobject.properties | ForEach-Object { $hashtable[$_.Name] = $_.Value } | Out-Null
    #             # $Uri -eq "basehost/v2/spaces" -and $Method -eq "Post" `
    #             #     -and (Compare-HashTable $hashtable $MatchBody) -eq $null `
    #             #     -and (Compare-HashTable $Header $TargetHeader) -eq $null
    #         }
    #     }
    # }
    Context "API return values" {
        It "Returns non 201 status" {
            Mock Invoke-WebRequest {@{StatusCode=400;Content=$TheContent}}
            { New-Space -Org $TargetOrg -Name $TargetName } | Should -Throw "*basehost/v2/spaces 400*"
        }
    }
    Context "parameters" {
        It "ensures 'Org' cannot be null" {
            {  New-Space -Org $null -Name "x" } | Should -Throw "*Cannot validate argument on parameter 'Org'. The argument is null or empty*"
        }
        It "supports positional" {
            New-Space $TargetOrg $TargetName
        }
        It "supports 'Org' from pipeline" {
            $TargetOrg | New-Space -Name $TargetName
        }
   }

}