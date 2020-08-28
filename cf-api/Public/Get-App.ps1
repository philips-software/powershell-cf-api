<#
.Synopsis
   Gets a CloudFoundry App object
.DESCRIPTION
   The Get-App cmdlet gets the App object from the CloudFoundry API
.PARAMETER Space
    This parameter is a space object
.PARAMETER Name
    This parameter is the name of the space
.EXAMPLE
   $org = Get-OrgCredentials "TheOrgName" "myusername" "mypassword"
   get-space "spacename" | get-app -Name "appname" | ConvertTo-Json
#>
function Get-App {

    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Space,

        [Parameter( Position = 1, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        Write-Output (Invoke-GetRequest "/v2/apps?q=name%3A$($Name)&q=space_guid%3A$($Space.metadata.guid)").resources[0]
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}