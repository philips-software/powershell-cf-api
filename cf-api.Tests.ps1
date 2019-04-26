#requires -modules Pester

Invoke-Pester -Script @{ Path = 'Public/*' }

