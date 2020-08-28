Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Publish-Space.ps1"
    . "$PSScriptRoot\Get-Space.ps1"
    . "$PSScriptRoot\New-Space.ps1"
    . "$PSScriptRoot\Add-RolesFromDefinition.ps1"
    . "$PSScriptRoot\Get-ServiceInstance.ps1"
    . "$PSScriptRoot\New-ServiceAsync.ps1"
    . "$PSScriptRoot\New-UserProvidedService.ps1"
    . "$PSScriptRoot\Wait-ServiceOperations.ps1"
}

Describe "Publish-Space" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetOrg = [PSCustomObject]@{name="myorg"}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetSpace = [PSCustomObject]@{name="myspace"}
        $TargetUserServices = @()
        $TargetDeveloperRoles = @([PSCustomObject]@{})
        $TargetManagerRoles = @([PSCustomObject]@{})
        $TargetAuditorRoles = @([PSCustomObject]@{})
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TargetDefinition = [PSCustomObject]@{
            name="myspace"
            userservices=$TargetUserServices
            roles=@{
                developers=$TargetDeveloperRoles
                managers=$TargetManagerRoles
                auditors=$TargetAuditorRoles
            }
            services=@()
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
    }
    Context "space does not exists" {
        It "creates new" {
            Mock Get-Space
            Mock New-Space { $TargetSpace }
            Publish-Space -Org $TargetOrg -Definition $TargetDefinition
            Should -Invoke Get-Space -ParameterFilter { $Name -eq $TargetDefinition.name }
            Should -Invoke New-Space -ParameterFilter { $Org -eq $TargetOrg -and $Name -eq $TargetDefinition.name }
        }
    }
    Context "space exists" {
        It "skips new" {
            Mock Get-Space { $TargetSpace }
            Publish-Space -Org $TargetOrg -Definition $TargetDefinition
            Should -Invoke Get-Space -ParameterFilter { $Name -eq $TargetDefinition.name }
        }
    }
    Context "roles" {
        It "adds" {
            Mock Get-Space { $TargetSpace }
            Mock Add-RolesFromDefinition
            Mock Wait-ServiceOperations
            Publish-Space -Org $TargetOrg -Definition $TargetDefinition
            Should -Invoke Add-RolesFromDefinition -ParameterFilter {
                $RoleName -eq "developers" -and $Space -eq $TargetSpace
            }
            Should -Invoke Wait-ServiceOperations -ParameterFilter { $Space -eq $TargetSpace -and $Timeout -eq 60 }
        }
    }
    Context "services" {
        Context "does not exist" {
            It "creates" {
                Mock Get-Space { $TargetSpace }
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
                Mock Get-ServiceInstance
                Mock New-ServiceAsync
                Mock Wait-ServiceOperations
                Publish-Space -Org $TargetOrg -Definition $TargetDefinition
                Should -Invoke Get-ServiceInstance -ParameterFilter { $Space -eq $TargetSpace -and $Name -eq $TargetService.name }
                Should -Invoke New-ServiceAsync -ParameterFilter { $Space -eq $TargetSpace -and $ServiceName -eq $TargetService.service -and $Plan -eq $TargetService.plan -and $Name -eq $TargetService.name  }
                Should -Invoke Wait-ServiceOperations -ParameterFilter { $Space -eq $TargetSpace -and $Timeout -eq 60 }
            }
        }
        Context "exists" {
            It "does not create" {
                Mock Get-Space { $TargetSpace }
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
                Mock Get-ServiceInstance { $TargetService }
                Mock Wait-ServiceOperations
                Publish-Space -Org $TargetOrg -Definition $TargetDefinition
                Should -Invoke New-ServiceAsync -Exactly 0
                Should -Invoke Get-ServiceInstance -ParameterFilter { $Space -eq $TargetSpace -and $Name -eq $TargetService.name }
                Should -Invoke Wait-ServiceOperations -ParameterFilter { $Space -eq $TargetSpace -and $Timeout -eq 60 }
            }
        }
    }
    Context "user services" {
        Context "does not exist" {
            It "creates" {
                Mock Get-Space { $TargetSpace }
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
                Mock Get-ServiceInstance
                Mock New-UserProvidedService
                Mock Wait-ServiceOperations
                Publish-Space -Org $TargetOrg -Definition $TargetDefinition
                Should -Invoke Get-ServiceInstance -ParameterFilter { $Space -eq $TargetSpace -and $Name -eq $TargetUserService.name }
                Should -Invoke New-UserProvidedService -ParameterFilter { $Space -eq $TargetSpace -and $Name -eq $TargetUserService.name -and $SyslogDrainUrl -eq $TargetUserService.syslog_drain_url -and $RouteServiceUrl -eq $TargetUserService.route_service_url }
                Should -Invoke Wait-ServiceOperations -ParameterFilter { $Space -eq $TargetSpace -and $Timeout -eq 60 }
            }
        }
        Context "exist" {
            It "does not create" {
                Mock Get-Space { $TargetSpace }
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
                Mock Get-ServiceInstance { $TargetUserService }
                Mock Wait-ServiceOperations
                Publish-Space -Org $TargetOrg -Definition $TargetDefinition
                Should -Invoke  Get-ServiceInstance -ParameterFilter { $Space -eq $TargetSpace -and $Name -eq $TargetUserService.name }
                Should -Invoke New-UserProvidedService -Exactly 0
                Should -Invoke Wait-ServiceOperations -ParameterFilter { $Space -eq $TargetSpace -and $Timeout -eq 60 }
            }
        }
        Context "parameters" {
            It "ensures 'Org' cannot be null" {
                {  Publish-Space -Org $null -Definition @{} } | Should -Throw "*Cannot validate argument on parameter 'Org'. The argument is null or empty*"
            }
            It "ensures  'Definition' cannot be null" {
                {  Publish-Space -Org @{} -Definition $null } | Should -Throw "*Cannot validate argument on parameter 'Definition'. The argument is null or empty*"
            }
            It "supports positional" {
                {
                    Mock Get-Space
                    Mock New-Space { $TargetSpace }
                    Publish-Space $TargetOrg $TargetDefinition
                    Should -Invoke Get-Space -ParameterFilter { $Name -eq $TargetDefinition.name }
                    Should -Invoke New-Space -ParameterFilter { $Org -eq $TargetOrg -and $Name -eq $TargetDefinition.name }
                }
            }
            It "supports 'Org' from pipeline" {
                {
                    Mock Get-Space
                    Mock New-Space { $TargetSpace }
                    $TargetOrg | Publish-Space -Definition $TargetDefinition
                    Should -Invoke Get-Space -ParameterFilter { $Name -eq $TargetDefinition.name }
                    Should -Invoke New-Space -ParameterFilter { $Org -eq $TargetOrg -and $Name -eq $TargetDefinition.name }
                }
            }
       }
    }
}