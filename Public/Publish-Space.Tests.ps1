$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Publish-Space.ps1"
. "$source\Get-Space.ps1"
. "$source\New-Space.ps1"
. "$source\..\Private\Add-RolesFromDefinition.ps1"
. "$source\Get-ServiceInstance.ps1"
. "$source\New-ServiceAsync.ps1"
. "$source\New-UserProvidedService.ps1"
. "$source\Wait-ServiceOperations.ps1"
#$DebugPreference = "continue"
#$InformationPreference = "continue"
Describe "Publish-Space" {
    $TargetOrg = [PSCustomObject]@{name="myorg"}
    $TargetSpace = [PSCustomObject]@{name="myspace"}
    $TargetUserServices = @()
    $TargetDeveloperRoles = @([PSCustomObject]@{})
    $TargetManagerRoles = @([PSCustomObject]@{})
    $TargetAuditorRoles = @([PSCustomObject]@{})
    $TargetDefinition = [PSCustomObject]@{
        name="myspace"
        usersservices=$TargetUserServices        
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
    Mock Get-ServiceInstance { $null }
    Mock Wait-ServiceOperations
    Mock New-ServiceAsync
    Context "space does not exists" {
        Mock Get-Space { $null } -Verifiable -ParameterFilter { $Name -eq $TargetDefinition.name }
        Mock New-Space { $TargetSpace } -Verifiable -ParameterFilter { $Org -eq $TargetOrg -and $Name -eq $TargetDefinition.name }
        It "new" {
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
            Mock Add-RolesFromDefinition -Verifiable -ParameterFilter { ((Compare-Object $UserNames $TargetDeveloperRoles) -eq $null) -and $RoleName -eq "developers" }
            Mock Add-RolesFromDefinition -Verifiable -ParameterFilter { ((Compare-Object $UserNames $TargetManagerRoles) -eq $null) -and $RoleName -eq "managers" }
            Mock Add-RolesFromDefinition -Verifiable -ParameterFilter { ((Compare-Object $UserNames $TargetAuditorRoles) -eq $null) -and $RoleName -eq "auditors" }
            Publish-Space -Org $TargetOrg -Definition $TargetDefinition
            Assert-VerifiableMock
        }
    }
    Context "services" {
        Context "does not exist" {
            Mock Get-Space { $TargetSpace }
            It "create" {
                $TargetService = [PSCustomObject]@{name="myservice1";service="s1";plan="p1";params=@()}
                $TargetServices = @($TargetService)
                $TargetDefinition = [PSCustomObject]@{
                    name="myspace"
                    usersservices=$TargetUserServices
                    services=$TargetServices
                    roles=@{
                        developers=$TargetDeveloperRoles
                        managers=$TargetManagerRoles
                        auditors=$TargetAuditorRoles
                    }
                }
                Mock Get-ServiceInstance { $null } -Verifiable -ParameterFilter { $Space -eq $TargetSpace -and $Name -eq $TargetService.name }
                Mock New-ServiceAsync -Verifiable -ParameterFilter { $Space -eq $TargetSpace -and $ServiceName -eq $TargetService.service -and $Plan -eq $TargetService.plan -and $Name -eq $TargetService.name  }
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
                    usersservices=@()
                    services=$TargetServices
                    roles=@{
                        developers=$TargetDeveloperRoles
                        managers=$TargetManagerRoles
                        auditors=$TargetAuditorRoles
                    }
                }
                Mock Get-ServiceInstance { $TargetService } -Verifiable -ParameterFilter { $Space -eq $TargetSpace -and $Name -eq $TargetService.name }
                Publish-Space -Org $TargetOrg -Definition $TargetDefinition
                Assert-MockCalled New-ServiceAsync -Exactly 0
                Assert-VerifiableMock
            }
        }
    }
    Context "user services" {
        Context "does not exist" {
            Mock Get-Space { $TargetSpace }
            It "create" {
                $TargetUserService = [PSCustomObject]@{name="myservice1";service="s1";plan="p1";params=@()}
                $TargetUserServices = @($TargetUserService)
                $TargetDefinition = [PSCustomObject]@{
                    name="myspace"
                    usersservices=@()
                    services=@()
                    roles=@{
                        developers=$TargetDeveloperRoles
                        managers=$TargetManagerRoles
                        auditors=$TargetAuditorRoles
                    }
                }
                #Mock Get-ServiceInstance { $TargetService } -Verifiable -ParameterFilter { $Space -eq $TargetSpace -and $Name -eq $TargetService.name }
                #Mock Get-ServiceInstance { $null } -Verifiable -ParameterFilter { $Space -eq $TargetSpace -and $Name -eq $TargetUserService.name }
                #Mock New-UserProvidedService -Verifiable -ParameterFilter { $Space -eq $TargetSpace -and $Name }
                Publish-Space -Org $TargetOrg -Definition $TargetDefinition
                Assert-VerifiableMock
            }
        }
    }

}