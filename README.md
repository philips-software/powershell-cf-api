# powershell-cf-api

**Description**:  This PowerShell module can deploy and teardown CloudFoundry spaces and services via a json definition file. It is very similar to the manifest concept supported by the CLI wrt to applications.  This was implemented using the CloudFoundry APIs as an alternative to the Cloud Foundry command line interface (CLI). The powershell module can be used to create automated deployment scripts that perform work asyncrhonously. The cmdlets support waiting for service operations to complete making it useful for automated deployment and operational scripts.

The module is not intended to be a replacement for the CF CLI but does provide a few distinct advantages:

1. Create an entire space definition in a single command from a definition (e.g. manifest)
2. Will wait for commands to complete so it is compatible with CI/CD pipelines for environments on demand.
3. Can tear down the space to support environments on demand save costs for temporary testing.

  - **Technology stack**: Microsoft Powershell. Compatible with PS Core. No dependencies on other libraries or modules.
  - **Key concepts** powershell  (technical, philosophical, or both) important to the user’s understanding.
  - **Status**:  Alpha. See ToDos. [CHANGELOG](CHANGELOG.md).

## Dependencies

* Powershell 5.1 or greater
* Pester for unit tests

## Installation

```
Import-Module cf-api.psm1 -Scope Local
```
## Configuration

No additional configuration is required

## Usage

All functions that call the CF API return PSObjects. These objects can be easily converted to and from JSON using powershell `ConvertTo-Json` and `ConvertFrom-Json`

Functions perform operations against PSObjects returned from other functions.

For example:

```
$org = Get-OrgCredentials -OrgName "myorg" -Username "myusername" -Password "mypassword"
Get-Space -Name "myspacename" | Get-SpaceSummary | ConvertTo-Json
```
### Functions
Use powershell Get-Help to obtain examples for the following supported commands.
```
# Orgs
Get-OrgCredentials
Get-Org

# Space Management
Publish-Space
Unpublish-Space

# Spaces
Get-Space
Get-SpaceSummary
New-Space
Remove-Space
Wait-RemoveSpace
Wait-ServiceOperations

# Roles
Get-SpaceRoles
Set-SpaceRole
Find-SpaceRoleByUsername

# Jobs
Get-Job
Wait-Job

# Services
Get-Service
Get-ServicePlan
New-Service
New-ServiceAsync
Wait-CreateService
Wait-CreateServiceInstance
Get-ServiceInstance
Remove-Service
Get-ServiceBindings
Remove-AllServiceBindings
Remove-ServiceBinding
Remove-ServiceBindings

# User Provided Services
New-UserProvidedService

# Apps
Get-App -Space $space -Name $name
```

### Examples

Publishing a spaces leverages a space definition file. The space definition file is a json file that contains definitions for space name, user roles, service instances and user provided services.

Example of definition file:

```
{
    "name": "my space",
    "roles": {
        "developers": [ "user1", "user2" ], 
        "managers": [ "user1" ],
        "auditors": ["user3" ]
    },
    "services": [
        {
            "name": "my-dynamo-resource",
            "service": "hsdp-dynamodb",
            "plan": "dynamodb-table",
            "params": {
                "PrimaryKey": "Path",
                "SortKey": "SortKey",
                "AttributeType": "S",
                "ReadCapacityUnits": "10",
                "WriteCapacityUnits": "15"
            }
        }
    ],
    "userservices": [
        {
            "name": "cups1",
            "syslog_drain_url": "https://logdrain.com"
            "route_service_url": "https://routeservice.com"
            "params": {
                "key1": "value1",
                "key2": "value2"
            }
        }
    ]
}
````
### Using a json the definition file

```
$org = Get-OrgCredentials -OrgName "myorg" -Username "myusername" -Password "mypassword"
$def = Get-Content -Path space-definition.json" | ConvertFrom-Json
# publish the space
$space = Publish-Space -Org $org -Definition $def

# unpublish the space
Unpublish-Space -Org $org -Definition $def
```
### Notes on publishing into existing spaces
The publishing matches all objects using the name. If the object already exists then it skips creating the object. If the object does not exist then a new object is created.  This is important to consider if previously published objects are renamed.

The module does not support function to migrate space definition changes.


## How to test the software

Pester tests are a WIP. Use ./cf-api.tests.ps1 to execute tests.

## Known issues

None

## Contact / Getting help

mark.lindell@philips.com

## License

Link to LICENSE.md

## Credits and references

1. Inspiration for powershell approach taken from from [JiraPS](https://github.com/AtlassianPS/JiraPS)
2. Terraform is the prefered approach but the leading [Terraform CloudFoundy provider](https://github.com/mevansam/terraform-provider-cf) is not mature enough to use.

# cf-api - A powershell module for CloudFoundry space managment

This powershell module can deploy, manage, and teardown CloudFoundry spaces via a json file definition.  This was implemented using the CloudFoundry APIs as an alternative to the CLI.

The module is far from a complete replacement for the CF CLI but does provide a few distinct advantages:

1. Create an entire space definition in a single command from a definition (e.g. manifest)
2. Will wait for commands to complete so it is compatible with CI/CD pipelines for environments on demand.
3. Can tear down the space to support environments on demand and cost savings.

The module must be imported into powershell using:

```
Import-Module cf-api.psm1 -Scope Local
```


Terraform is the prefered approach but the leading [Terraform CloudFoundy provider](https://github.com/mevansam/terraform-provider-cf) is not mature enough to use.



