param($major = "0", $minor = "1", $patch = "0", $Test = $true, $Analyze = $true)

trap {
    $ErrorActionPreference = "Continue";
    Write-Error $_
    exit 1
}
$ErrorActionPreference = "Stop"

# ensure the module imports
Import-Module -Name ./cf-api -Force

if ($Test) {
    & .\cf-api.tests.ps1
}

# run unit tests
Push-Location $PSScriptRoot/cf-api

if ($Analyze) {
    Install-Module -Name PSScriptAnalyzer -Force
    Invoke-ScriptAnalyzer -Path Public -Recurse # -EnableExit <= add once all warnings are cleaned up
}

$semver = "$($major).$($minor).$($patch)"
Write-Verbose "Setting version to $($semver)"

((Get-Content -path cf-api-template.nuspec -Raw) -replace '\${NUGET_VERSION}',$semver) | Set-Content -Path cf-api.nuspec
((Get-Content -path cf-api-template.psd1 -Raw) -replace '\${NUGET_VERSION}',$semver) | Set-Content -Path cf-api.psd1

Pop-Location

exit 0