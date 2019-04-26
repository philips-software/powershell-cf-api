function Find-SpaceRoleByUsername($roles, $name) {
    return (@($roles.resources | Where-Object {$_.entity.username -eq $name})[0])
}