<#
    This is a simple pester test plan
#>

$host.ui.RawUI.WindowTitle = 'Pester Testing'


# Pester
Import-Module Pester

$testsFolder = (get-location).path
Set-Location  $testsFolder 

$Tests = Get-ChildItem "$testsFolder\*.tests.ps1"

foreach ($script in $tests)
{
    Context "Test formatting $script" {
      
        It "$($script.name) should exist" {
            $script.fullname | Should Exist
        }
    
        It "$($script.name) should have help block" {
            $script.fullname | Should Contain '<#'
            $script.fullname | Should Contain '#>'
        }

        It "$($script.name) should have a SYNOPSIS section in the help block" {
            $script.fullname | Should Contain '.SYNOPSIS'
        }
    
        It "$($script.name) should have a DESCRIPTION section in the help block" {
            $script.fullname | Should Contain '.DESCRIPTION'
        }

        It "$($script.name) should have a EXAMPLE section in the help block" {
            $script.fullname | Should Contain '.EXAMPLE'
        }

        It "$($script.name) should be an advanced function" {
            $script.fullname | Should Contain 'param'
            #"$here\function-$function.ps1" | Should Contain 'cmdletbinding'
        }

        It "$($script.name) is valid PowerShell code" {
            $psFile = Get-Content -Path $script.fullname -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
            $errors.Count | Should Be 0
        }
    }
}
