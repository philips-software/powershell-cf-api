$VerbosePreference = "continue"
((Get-Content -path ./cf-api.nuspec -Raw) -replace '\${NUGET_VERSION}','99.99.99') | Set-Content -Path ./cf-api.nuspec
((Get-Content -path ./cf-api.psd1 -Raw) -replace '\${NUGET_VERSION}','99.99.99') | Set-Content -Path ./cf-api.psd1
& nuget pack -NoPackageAnalysis
import-module -Name ./cf-api -Force