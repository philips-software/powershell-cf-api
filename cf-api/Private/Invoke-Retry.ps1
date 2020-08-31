<#
.SYNOPSIS
Retries a powershell command n-times.
.DESCRIPTION
The cmdlet is capable of retrying a PowerShell command passed as a [ScriptBlock] according to the user defined number of retries and timeout (In Seconds)
.PARAMETER TimeoutInSecs
Timeout in secods for each retry.
.PARAMETER RetryCount
Number of times to retry the command. Default value is '3'
.PARAMETER ScriptBlock
PoweShell command as a ScriptBlock that will be executed and retried in case of Errors. Make sure the script block throws an error when it fails, otherwise the cmdlet won't run the retry logic.
.PARAMETER SuccessMessage
Message displayed when the command was executed successfuly.
.PARAMETER FailureMessage
Message displayed when the command was failed to execute.
.EXAMPLE
 Invoke-Retry -ScriptBlock {Test-Connection 'test.com'} -Verbose
VERBOSE: [1/3] Failed to Complete the task. Retrying in 30 seconds...
VERBOSE: [2/3] Failed to Complete the task. Retrying in 30 seconds...
VERBOSE: [3/3] Failed to Complete the task. Retrying in 30 seconds...
VERBOSE: Failed to Complete the task! Total retry attempts: 3
VERBOSE: [Error Message] Testing connection to computer 'test.com' failed: Error due to lack of resources
Try test connection to the website that doesn't exists, which will throw host not found error. Any error is caught by the Invoke-Retry cmdlet and it will retry to execute test connection 3 more times. By default 3 retry attempts are made at every 30 seconds and you have to explicitly define the 'Verbose' switch to see the retry logic in action.
.EXAMPLE
 Invoke-Retry -ScriptBlock {Get-Service bits | Stop-Service} -TimeoutInSecs 2 -RetryCount 5 -Verbose
VERBOSE: [1/5] Failed to Complete the task. Retrying in 2 seconds...
VERBOSE: [2/5] Failed to Complete the task. Retrying in 2 seconds...
VERBOSE: [3/5] Failed to Complete the task. Retrying in 2 seconds...
VERBOSE: [4/5] Failed to Complete the task. Retrying in 2 seconds...
VERBOSE: [5/5] Failed to Complete the task. Retrying in 2 seconds...
VERBOSE: Failed to Complete the task! Total retry attempts: 5
VERBOSE: [Error Message] Service 'Background Intelligent Transfer Service (bits)' cannot be stopped due to the following error: Cannot open bits service on computer '.'.
We can customize the number of retry attempts and timeout times using the parameters: '-RetryCount' and '-TimeoutInSecs' respectively.
.EXAMPLE
 Invoke-Retry -ScriptBlock {Write-Error -Message 'something went wrong!'} -TimeoutInSecs 2 -Verbose
VERBOSE: [1/3] Failed to Complete the task. Retrying in 2 seconds...
VERBOSE: [2/3] Failed to Complete the task. Retrying in 2 seconds...
VERBOSE: [3/3] Failed to Complete the task. Retrying in 2 seconds...
VERBOSE: Failed to Complete the task! Total retry attempts: 3
VERBOSE: [Error Message] something went wrong!
In some scenarios you would want the retry logic when something fails or you don't get a desired output. In such cases to implement the retry logic, make sure to throw and error in you script block that would be executed
.EXAMPLE
Invoke-Retry -ScriptBlock {
    if(2 -eq 2){
        throw('Exception occured!')
    }
} -TimeoutInSecs 2 -Verbose
VERBOSE: [1/3] Failed to execute the command. Retrying in 2 seconds...
VERBOSE: [2/3] Failed to execute the command. Retrying in 2 seconds...
VERBOSE: [3/3] Failed to execute the command. Retrying in 2 seconds...
VERBOSE: Failed to execute the command! Total retry attempts: 3
VERBOSE: [Error Message] Exception occured!
You can even define some conditional statements and throw errors to trigger the retry statments in your program.
.EXAMPLE
{Test-Connection 'prateeks.cim'},{Write-Host 'hello'} ,{1/0} | Invoke-Retry -TimeoutInSecs 2 -Verbose
VERBOSE: [1/3] Failed to execute the command. Retrying in 2 seconds...
VERBOSE: [2/3] Failed to execute the command. Retrying in 2 seconds...
VERBOSE: [3/3] Failed to execute the command. Retrying in 2 seconds...
VERBOSE: Failed to execute the command! Total retry attempts: 3
VERBOSE: [Error Message] Testing connection to computer 'prateeks.cim' failed: No such host is known
hello
VERBOSE: Command executed successfuly!
VERBOSE: [1/3] Failed to execute the command. Retrying in 2 seconds...
VERBOSE: [2/3] Failed to execute the command. Retrying in 2 seconds...
VERBOSE: [3/3] Failed to execute the command. Retrying in 2 seconds...
VERBOSE: Failed to execute the command! Total retry attempts: 3
VERBOSE: [Error Message] Attempted to divide by zero.
Capable of handling scriptblock's as input through the pipeline.
.NOTES
General notes
#>

function Invoke-Retry {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [scriptblock] $ScriptBlock,
        [int] $RetryCount = 10,
        [int] $TimeoutInSecs = 3,
        [string] $SuccessMessage = "Command executed successfuly!",
        [string] $FailureMessage = "Failed to execute the command"
        )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {

        $Attempt = 1
        $Flag = $true

        do {
            try {
                $PreviousPreference = $ErrorActionPreference
                $ErrorActionPreference = 'Stop'
                Invoke-Command -ScriptBlock $ScriptBlock -OutVariable Result
                $ErrorActionPreference = $PreviousPreference

                # flow control will execute the next line only if the command in the scriptblock executed without any errors
                # if an error is thrown, flow control will go to the 'catch' block
                Write-Verbose "$SuccessMessage `n"
                $Flag = $false
            }
            catch {
                if ($Attempt -gt $RetryCount) {
                    Write-Verbose "$FailureMessage! Total retry attempts: $RetryCount"
                    Write-Verbose "[Error Message] $($_.exception.message) `n"
                    $Flag = $false
                }
                else {
                    Write-Verbose $_.Exception.Message
                    Write-Verbose "[$Attempt/$RetryCount] $FailureMessage. Retrying in $TimeoutInSecs seconds..."
                    Start-Sleep -Seconds $TimeoutInSecs
                    $Attempt = $Attempt + 1
                }
            }
        }
        While ($Flag)

    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }


}