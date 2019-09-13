$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Compare-Hashtable" {
  Context "When both are empty" {
    $Left, $Right = @{}, @{}

    It "should return nothing" {
      Compare-Hashtable $Left $Right | Should BeNullOrEmpty
    }
  }
  
  Context "When both have one identical entry" {
    $Left, $Right = @{ a = "x" }, @{ a = "x" }

    It "should return nothing" {
      Compare-Hashtable $Left $Right | Should BeNullOrEmpty
    }
  }

  Context "When left contains a key with a null value" {
    $Left, $Right = @{ a = $Null }, @{}

    It "should return nothing" {
      [Object[]]$result = Compare-Hashtable $Left $Right

	    $result.Length | Should Be 1
	    $result.side   | Should Be "<="
	    $result.lvalue | Should Be $Null
	    $result.rvalue | Should Be $Null
    }
  }  

  Context "When right contains a key with a null value" {
    $Left, $Right = @{}, @{ a = $Null }

    It "should return nothing" {
      [Object[]]$result = Compare-Hashtable $Left $Right

	    $result.Length | Should Be 1
	    $result.side   | Should Be "=>"
	    $result.lvalue | Should Be $Null
	    $result.rvalue | Should Be $Null
    }
  }  
  
  Context "When both contain various stuff " {
    $Left = @{ a = 1; b = 2; c = 3; f = $Null; g = 6; k = $Null }
    $Right = @{ b = 2; c = 4; e = 5; f = $Null; g = $Null; k = 7 }
    $Result = Compare-Hashtable $Left $Right

    It "should contain 5 differences" {
      $Result.Length | Should Be 5
    }
    It "should return a: 1 <=" {
      ($Result | ? { $_.Key -eq "a" }).Side   | Should Be "<="  
      ($Result | ? { $_.Key -eq "a" }).LValue | Should Be 1  
      ($Result | ? { $_.Key -eq "a" }).RValue | Should Be $Null  
    }
    It "should return c: 3 <= 4" {
      ($Result | ? { $_.Key -eq "c" }).Side   | Should Be "!="  
      ($Result | ? { $_.Key -eq "c" }).LValue | Should Be 3  
      ($Result | ? { $_.Key -eq "c" }).RValue | Should Be 4  
    }
    It "should return e: <= 5" {
      ($Result | ? { $_.Key -eq "e" }).Side   | Should Be "=>"  
      ($Result | ? { $_.Key -eq "e" }).LValue | Should Be $Null  
      ($Result | ? { $_.Key -eq "e" }).RValue | Should Be 5  
    }
    It "should return g: 6 !=" {
      ($Result | ? { $_.Key -eq "g" }).Side   | Should Be "!="  
      ($Result | ? { $_.Key -eq "g" }).LValue | Should Be 6  
      ($Result | ? { $_.Key -eq "g" }).RValue | Should Be $Null  
    }
    It "should return k: != 7" {
      ($Result | ? { $_.Key -eq "k" }).Side   | Should Be "!="  
      ($Result | ? { $_.Key -eq "k" }).LValue | Should Be $Null  
      ($Result | ? { $_.Key -eq "k" }).RValue | Should Be 7  
    }       
  } 
}