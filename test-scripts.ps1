<#
    This script is used to execute the pester tests
#>

$host.ui.RawUI.WindowTitle = 'Pester Test for Scripts'

# Pester
Import-Module Pester -Force

$testsFolder = (get-location).path
Set-Location  $testsFolder

# Run tests for each file
$Tests = Get-ChildItem "$testsFolder\*.tests.ps1"

foreach ($test in $tests)
{
    Invoke-Pester $test.fullname
}
