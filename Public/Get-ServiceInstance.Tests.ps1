$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-ServiceInstance.ps1"
. "$source\Get-SpaceSummary.ps1"

Describe "Get-ServiceBindings" {
    Context "API call" {
        $Space = New-Object PsObject
        $service1 = New-Object PsObject -Property @{name="service1"}
        $service2 = New-Object PsObject -Property @{name="service2"}
        $Summary = New-Object PsObject -Property @{services=@($service2, $service1)}
        Mock Get-SpaceSummary { $Summary } `
            -Verifiable -ParameterFilter {$space -eq $Space}
        
        It "Called with correct space object" {
            Get-ServiceInstance -Space $Space -Name $service1.name
            Assert-VerifiableMock
        }
        It "Name not found" {
            (Get-ServiceInstance -Space $Space -Name "service3") | Should be $null
        }
        It "Parameter order" {
            (Get-ServiceInstance $Space "service1") | Should be $service1
        }
        It "Uses Space from pipeline" {
            ($Space | Get-ServiceInstance -Name $service1.name) | Should be $service1
        }
    }
    Context "Parameter validation" {
        It "Space cannot be null" {
            { Get-ServiceInstance -Space $null } | Should -Throw "Cannot validate argument on parameter 'Space'. The argument is null or empty"
        }
        It "Name cannot be null" {
            { Get-ServiceInstance -Space @{} -Name $null } | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty"
        }
        It "Name cannot be empty" {
            { Get-ServiceInstance -Space (New-Object PsObject) -Name "" } | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty"
        }
    }    
}