<#
.Synopsis
   This function gets a Org object using credentials
.DESCRIPTION
   Retrieve the Org object object using the passed credentials
.PARAMETER Name
    This parameter is used to identify the org name to retrieve
.PARAMETER Username
    This parameter is used to identify the username to authenticate
.PARAMETER Password
    This parameter is used to identify the username's password to authenticate
.PARAMETER CloudFoundryAPI
    This parameter the CloudFoundry URL to use.
.EXAMPLE
   $org = Get-OrgCredentials "Wellcentive" "bjones" "SD*&@#@kdfj$"
#>
function Get-OrgCredentials {

    [CmdletBinding()]
    [OutputType([psobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '', Justification='needed to collect')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification='needed to collect')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUsernameAndPasswordParams', '', Justification='needed to collect')]
    param(
        [Parameter( Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias("Name")]
        [String]
        $OrgName,

        [Parameter( Position = 1, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Username,

        [Parameter( Position = 2, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Password,

        [Parameter( Position = 3, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $CloudFoundryAPI
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
        Get-Token -Username $Username -Password $Password -CloudFoundryAPI $CloudFoundryAPI | Set-Headers
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        Write-Output (Get-Org $orgName)
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }

}
