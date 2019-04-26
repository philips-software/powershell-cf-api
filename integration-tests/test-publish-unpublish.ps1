param ($orgname, $username, $password)
Import-Module "$PSScriptRoot/../cf-api.psm1" -Force
$org = Get-OrgCredentials $orgname $username $password -Verbose 
$def = Get-Content .\test-definition.json -Verbose | ConvertFrom-Json
Publish-Space -Org $org -Definition $def -Verbose 
UnPublish-Space -Org $org -Definition $def -Verbose 