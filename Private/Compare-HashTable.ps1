$ErrorActionPreference = "Stop"

function Compare-Hashtable {
<#
.SYNOPSIS
Compare two Hashtable and returns an array of differences.
.DESCRIPTION
The Compare-Hashtable function computes differences between two Hashtables. Results are returned as
an array of objects with the properties: "key" (the name of the key that caused a difference), 
"side" (one of "<=", "!=" or "=>"), "lvalue" an "rvalue" (resp. the left and right value 
associated with the key).
.PARAMETER left 
The left hand side Hashtable to compare.
.PARAMETER right 
The right hand side Hashtable to compare.
.EXAMPLE
Returns a difference for ("3 <="), c (3 "!=" 4) and e ("=>" 5).
Compare-Hashtable @{ a = 1; b = 2; c = 3 } @{ b = 2; c = 4; e = 5}
.EXAMPLE 
Returns a difference for a ("3 <="), c (3 "!=" 4), e ("=>" 5) and g (6 "<=").
$left = @{ a = 1; b = 2; c = 3; f = $Null; g = 6 }
$right = @{ b = 2; c = 4; e = 5; f = $Null; g = $Null }
Compare-Hashtable $left $right
#>	
[CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Hashtable]$Left,

        [Parameter(Mandatory = $true)]
        [Hashtable]$Right		
	)
	
	function New-Result($Key, $LValue, $Side, $RValue) {
		New-Object -Type PSObject -Property @{
					key    = $Key
					lvalue = $LValue
					rvalue = $RValue
					side   = $Side
			}
	}
	[Object[]]$Results = $Left.Keys | % {
		if ($Left.ContainsKey($_) -and !$Right.ContainsKey($_)) {
			New-Result $_ $Left[$_] "<=" $Null
		} else {
			$LValue, $RValue = $Left[$_], $Right[$_]
			if ($LValue -ne $RValue) {
				New-Result $_ $LValue "!=" $RValue
			}
		}
	}
	$Results += $Right.Keys | % {
		if (!$Left.ContainsKey($_) -and $Right.ContainsKey($_)) {
			New-Result $_ $Null "=>" $Right[$_]
		} 
	}
	$Results 
}