$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\New-ServiceAsync.ps1"
. "$source\Get-Service.ps1"
. "$source\Get-ServicePlans.ps1"
. "$source\New-Service.ps1"

Describe "New-ServiceAsync" {    
    $TheSpace = New-Object PsObject
    $TheService = New-Object PsObject
    $TheNewService = New-Object PsObject
    $TheServicePlans = New-Object PsObject
    Mock Get-Service { $TheService } -Verifiable -ParameterFilter { $Space -eq $TheSpace -and $Name -eq "servicename1" }
    Mock Get-ServicePlans { $TheServicePlans } -Verifiable -ParameterFilter { $Service -eq $TheService }
    Mock New-Service { $TheNewService } -Verifiable -ParameterFilter { $Space -eq $TheSpace -and $ServicePlans -eq $TheServicePlans -and $Plan -eq "plan1" -and $Name -eq "newservicename1"}    
    Context "dependent cmdlets" {
        It "calls all cmdlets" {
            New-ServiceAsync -Space $TheSpace -ServiceName "servicename1" -Plan "plan1" -Name "newservicename1" | Should be $TheNewService
            Assert-VerifiableMock
        }
    }
    Context "parameters" {
        It "ensures 'Space' cannot be null" {
            {  New-ServiceAsync -Space $null -ServiceName "x" -Plan "x" -Name "x"} | Should -Throw "Cannot validate argument on parameter 'Space'. The argument is null or empty"
        }        
        It "ensures 'SeviceName' cannot be null" {
            {  New-ServiceAsync -Space $@{} -ServiceName $null -Plan "x" -Name "x"} | Should -Throw "Cannot validate argument on parameter 'ServiceName'. The argument is null or empty"
        }        
        It "ensures 'SeviceName' cannot be empty" {
            {  New-ServiceAsync -Space $@{} -ServiceName "" -Plan "x" -Name "x"} | Should -Throw "Cannot validate argument on parameter 'ServiceName'. The argument is null or empty"
        }        
        It "ensures 'Plan' cannot be null" {
            {  New-ServiceAsync -Space $@{} -ServiceName "x" -Plan $null -Name "x"} | Should -Throw "Cannot validate argument on parameter 'Plan'. The argument is null or empty"
        }        
        It "ensures 'Plan' cannot be empty" {
            {  New-ServiceAsync -Space $@{} -ServiceName "x" -Plan "" -Name "x"} | Should -Throw "Cannot validate argument on parameter 'Plan'. The argument is null or empty"
        }        
        It "ensures 'Name' cannot be null" {
            {  New-ServiceAsync -Space $@{} -ServiceName "x" -Plan "x" -Name $null} | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty"
        }        
        It "ensures 'Name' cannot be empty" {
            {  New-ServiceAsync -Space $@{} -ServiceName "x" -Plan "x" -Name ""} | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty"
        }        
        It "supports positional" {
            New-ServiceAsync $TheSpace "servicename1" "plan1" "newservicename1" @() | Should be $TheNewService
            Assert-VerifiableMock
        }        
        It "supports 'Space' from pipeline" {
            $TheSpace  | New-ServiceAsync -ServiceName "servicename1" -Plan "plan1" -Name "newservicename1" | Should be $TheNewService
            Assert-VerifiableMock
        }        
    }    

}