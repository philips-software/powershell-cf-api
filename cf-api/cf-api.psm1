[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$modules = Get-Module -list
if ($modules.Name -notcontains 'pester') {
    Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser
}

#region LoadFunctions

$PublicFunctions = @( Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1" -Exclude *.Tests.ps1 -ErrorAction SilentlyContinue )
$PrivateFunctions = @( Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1" -Exclude *.Tests.ps1 -ErrorAction SilentlyContinue )

# Dot source the functions
foreach ($file in @($PublicFunctions + $PrivateFunctions)) {
    try {
        . $file.FullName
    }
    catch {
        $exception = ([System.ArgumentException]"Function not found")
        $errorId = "Load.Function"
        $errorCategory = 'ObjectNotFound'
        $errorTarget = $file
        $errorItem = New-Object -TypeName System.Management.Automation.ErrorRecord $exception, $errorId, $errorCategory, $errorTarget
        $errorItem.ErrorDetails = "Failed to import function $($file.BaseName)"
        throw $errorItem
    }
}
Export-ModuleMember -Function $PublicFunctions.BaseName -Alias *

#endregion LoadFunctions