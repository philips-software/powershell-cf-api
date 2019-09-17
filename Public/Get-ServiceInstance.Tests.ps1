$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-ServiceInstance.ps1"
. "$source\Get-SpaceSummary.ps1"

Describe "Get-ServiceBindings" {
    $Space = New-Object PsObject
    $service1 = [PSCustomObject]@{name="service1"}
    $service2 = [PSCustomObject]@{name="service2"}
    $Summary = [PSCustomObject]@{services=@($service2, $service1)}
    Mock Get-SpaceSummary { $Summary } -Verifiable -ParameterFilter {$space -eq $Space}  
    Context "API call" {
        It "is called with correct space object" {
            Get-ServiceInstance -Space $Space -Name $service1.name
            Assert-VerifiableMock
        }
        It "returns null when space Name not found" {
            (Get-ServiceInstance -Space $Space -Name "service3") | Should be $null
        }
    }
    Context "parameters" {
        It "ensures 'Space' cannot be null" {
            { Get-ServiceInstance -Space $null } | Should -Throw "Cannot validate argument on parameter 'Space'. The argument is null or empty"
        }
        It "ensures 'Name' cannot be null" {
            { Get-ServiceInstance -Space @{} -Name $null } | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty"
        }
        It "ensures 'Name' cannot be empty" {
            { Get-ServiceInstance -Space (New-Object PsObject) -Name "" } | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty"
        }
        It "supports positional" {
            (Get-ServiceInstance $Space "service1") | Should be $service1
        }
        It "supports 'Space' from pipeline" {
            ($Space | Get-ServiceInstance -Name $service1.name) | Should be $service1
        }
    }    
}