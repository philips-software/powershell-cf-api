$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Publish-Space.ps1"
. "$source\Get-Space.ps1"
. "$source\New-Space.ps1"
. "$source\Add-RolesFromDefinition.ps1"
. "$source\Get-ServiceInstance.ps1"
. "$source\New-ServiceAsync.ps1"
. "$source\New-UserProvidedService.ps1"
. "$source\Wait-ServiceOperations.ps1"
Describe "Publish-Space" {
    $TargetOrg = [PSCustomObject]@{name="myorg"}
    $TargetSpace = [PSCustomObject]@{name="myspace"}
    $TargetUserServices = @()
    $TargetDeveloperRoles = @([PSCustomObject]@{})
    $TargetManagerRoles = @([PSCustomObject]@{})
    $TargetAuditorRoles = @([PSCustomObject]@{})
    $TargetDefinition = [PSCustomObject]@{
        name="myspace"
        userservices=$TargetUserServices        
        roles=@{
            developers=$TargetDeveloperRoles
            managers=$TargetManagerRoles
            auditors=$TargetAuditorRoles
        }
    }
    Mock Get-Space
    Mock Add-RolesFromDefinition
    Mock Get-ServiceInstance
    Mock Wait-ServiceOperations
    Mock Add-RolesFromDefinition
    Mock Get-ServiceInstance
    Mock Wait-ServiceOperations
    Mock New-ServiceAsync
    Mock New-UserProvidedService
    Context "space does not exists" {
        Mock Get-Space -Verifiable -ParameterFilter { $Name -eq $TargetDefinition.name }
        Mock New-Space { $TargetSpace } -Verifiable -ParameterFilter { $Org -eq $TargetOrg -and $Name -eq $TargetDefinition.name }
        It "creates new" {
            Publish-Space -Org $TargetOrg -Definition $TargetDefinition
            Assert-VerifiableMock
        }
    }
    Context "space exists" {
        It "skips new" {
            Mock Get-Space { $TargetSpace } -Verifiable -ParameterFilter { $Name -eq $TargetDefinition.name }
            Publish-Space -Org $TargetOrg -Definition $TargetDefinition
            Assert-VerifiableMock
        }
    }
    Context "roles" {
        It "adds" {
            Mock Get-Space { $TargetSpace }
            Mock Add-RolesFromDefinition -Verifiable -ParameterFilter { ((Compare-Object $UserNames $TargetDeveloperRoles) -eq $null) -and $RoleName -eq "developers" -and $Space -eq $TargetSpace }
            Mock Add-RolesFromDefinition -Verifiable -ParameterFilter { ((Compare-Object $UserNames $TargetManagerRoles) -eq $null) -and $RoleName -eq "managers" -and $Space -eq $TargetSpace }
            Mock Add-RolesFromDefinition -Verifiable -ParameterFilter { ((Compare-Object $UserNames $TargetAuditorRoles) -eq $null) -and $RoleName -eq "auditors" -and $Space -eq $TargetSpace }
            Mock Wait-ServiceOperations -Verifiable { $Space -eq $TargetSpace -and $Timeout -eq 60 }
            Publish-Space -Org $TargetOrg -Definition $TargetDefinition
            Assert-VerifiableMock
        }
    }
    Context "services" {
        Context "does not exist" {
            Mock Get-Space { $TargetSpace }
            It "creates" {
                $TargetService = [PSCustomObject]@{name="myservice1";service="s1";plan="p1";params=@()}
                $TargetServices = @($TargetService)
                $TargetDefinition = [PSCustomObject]@{
                    name="myspace"
                    userservices=$TargetUserServices
                    services=$TargetServices
                    roles=@{
                        developers=$TargetDeveloperRoles
                        managers=$TargetManagerRoles
                        auditors=$TargetAuditorRoles
                    }
                }
                Mock Get-ServiceInstance -Verifiable -ParameterFilter { $Space -eq $TargetSpace -and $Name -eq $TargetService.name }
                Mock New-ServiceAsync -Verifiable -ParameterFilter { $Space -eq $TargetSpace -and $ServiceName -eq $TargetService.service -and $Plan -eq $TargetService.plan -and $Name -eq $TargetService.name  }
                Mock Wait-ServiceOperations -Verifiable { $Space -eq $TargetSpace -and $Timeout -eq 60 }
                Publish-Space -Org $TargetOrg -Definition $TargetDefinition
                Assert-VerifiableMock
            }
        }
        Context "exists" {
            Mock Get-Space { $TargetSpace }
            It "does not create" {
                $TargetService = [PSCustomObject]@{name="myservice1";service="s1";plan="p1";params=@()}
                $TargetServices = @($TargetService)
                $TargetDefinition = [PSCustomObject]@{
                    name="myspace"
                    userservices=@()
                    services=$TargetServices
                    roles=@{
                        developers=$TargetDeveloperRoles
                        managers=$TargetManagerRoles
                        auditors=$TargetAuditorRoles
                    }
                }
                Mock Get-ServiceInstance { $TargetService } -Verifiable -ParameterFilter { $Space -eq $TargetSpace -and $Name -eq $TargetService.name }
                Mock Wait-ServiceOperations -Verifiable { $Space -eq $TargetSpace -and $Timeout -eq 60 }
                Publish-Space -Org $TargetOrg -Definition $TargetDefinition
                Assert-MockCalled New-ServiceAsync -Exactly 0
                Assert-VerifiableMock
            }
        }
    }
    Context "user services" {
        Context "does not exist" {
            Mock Get-Space { $TargetSpace }
            It "creates" {
                $TargetUserService = [PSCustomObject]@{name="myservice1";service="s1";plan="p1";params=@();syslog_drain_url="a";route_service_url="b"}
                $TargetUserServices = @($TargetUserService)
                $TargetDefinition = [PSCustomObject]@{
                    name="myspace"
                    userservices=$TargetUserServices
                    services=@()
                    roles=@{
                        developers=$TargetDeveloperRoles
                        managers=$TargetManagerRoles
                        auditors=$TargetAuditorRoles
                    }
                }
                Mock Get-ServiceInstance -Verifiable -ParameterFilter { $Space -eq $TargetSpace -and $Name -eq $TargetUserService.name }
                Mock New-UserProvidedService -Verifiable -ParameterFilter { $Space -eq $TargetSpace -and $Name -eq $TargetUserService.name -and $SyslogDrainUrl -eq $TargetUserService.syslog_drain_url -and $RouteServiceUrl -eq $TargetUserService.route_service_url }
                Mock Wait-ServiceOperations -Verifiable { $Space -eq $TargetSpace -and $Timeout -eq 60 }
                Publish-Space -Org $TargetOrg -Definition $TargetDefinition
                Assert-VerifiableMock
            }
        }
        Context "exist" {
            Mock Get-Space { $TargetSpace }
            It "does not create" {
                $TargetUserService = [PSCustomObject]@{name="myservice1";service="s1";plan="p1";params=@();syslog_drain_url="a";route_service_url="b"}
                $TargetUserServices = @($TargetUserService)
                $TargetDefinition = [PSCustomObject]@{
                    name="myspace"
                    userservices=$TargetUserServices
                    services=@()
                    roles=@{
                        developers=$TargetDeveloperRoles
                        managers=$TargetManagerRoles
                        auditors=$TargetAuditorRoles
                    }
                }
                Mock Get-ServiceInstance { $TargetUserService } -Verifiable -ParameterFilter { $Space -eq $TargetSpace -and $Name -eq $TargetUserService.name }
                Assert-MockCalled New-UserProvidedService -Exactly 0
                Mock Wait-ServiceOperations -Verifiable { $Space -eq $TargetSpace -and $Timeout -eq 60 }
                Publish-Space -Org $TargetOrg -Definition $TargetDefinition
                Assert-VerifiableMock
            }
        }
        Context "parameters" {
            It "ensures 'Org' cannot be null" {
                {  Publish-Space -Org $null -Definition @{} } | Should -Throw "Cannot validate argument on parameter 'Org'. The argument is null or empty"
            }        
            It "ensures  'Definition' cannot be null" {
                {  Publish-Space -Org @{} -Definition $null } | Should -Throw "Cannot validate argument on parameter 'Definition'. The argument is null or empty"
            }
            It "supports positional" {
                {  
                    Mock Get-Space -Verifiable -ParameterFilter { $Name -eq $TargetDefinition.name }
                    Mock New-Space { $TargetSpace } -Verifiable -ParameterFilter { $Org -eq $TargetOrg -and $Name -eq $TargetDefinition.name }
                    Publish-Space $TargetOrg $TargetDefinition
                    Assert-VerifiableMock
                }                 
            }
            It "supports 'Org' from pipeline" {
                {  
                    Mock Get-Space -Verifiable -ParameterFilter { $Name -eq $TargetDefinition.name }
                    Mock New-Space { $TargetSpace } -Verifiable -ParameterFilter { $Org -eq $TargetOrg -and $Name -eq $TargetDefinition.name }
                    $TargetOrg | Publish-Space -Definition $TargetDefinition
                    Assert-VerifiableMock
                }                 
            }
       }
    }
}