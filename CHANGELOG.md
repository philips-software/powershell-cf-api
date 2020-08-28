## 2.0.3

  - CI/Github action build updated
  - Publish to PowerShellGallery.com for use of Install-Module
  - All unit tests now use Pester v5
  - minor documentation clean up

## 2.0.0

__Breaking changes:__
- Corrected Cmdlet named 'Get-ServicePlan' to 'Get-ServicePlans'

_Potential breaking changes:_
- New-Service: error message corrected when plan is not found
- New-UserProvidedService: positional parameters did not include "Space"

Minor corrections:
- Get-ServiceInstance: now has positional parameter for 'Name'
- Get-Space: supports 'Name' from pipeline
- New-Space: supports positional parameters

Changes:
- Add full suite of Pester tests.

## 1.0.7

  - Publish-Space: Added -Timeout param with 60m defaults
  - UnPublish-Space: Added -Timeout param with 60m defaults

## 1.0.6

  - Get-Env: added

## 1.0.5 - Inital release

  Please excuse that the initial release is 1.0.5. The previous semver were incorrectly published as nuget package and cannot be removed.

