function Add-RolesFromDefinition($usernames, $rolename) {
    foreach ($u in $usernames) {
        $roles = Get-SpaceRoles -Space $space -Role $rolename
        $role = Find-SpaceRoleByUsername $roles $u
        if ($null -eq $role) {
            Set-SpaceRole -Space $space -Username $u -Role $rolename
        } else {
            Write-Verbose "Publish-Space: '$($u)' is already in '$($rolename)', skipping"
        }
    }
}