#Requires -module CorkScrew

if (-not $ENV:BHProjectPath) {
    Set-BuildEnvironment -Path $PSScriptRoot\..
}
Remove-Module $ENV:BHProjectName -ErrorAction SilentlyContinue
Import-Module (Join-Path $ENV:BHProjectPath $ENV:BHProjectName) -Force


InModuleScope $ENV:BHProjectName {
    $PSVersion = $PSVersionTable.PSVersion.Major
    $ProjectRoot = $ENV:BHProjectPath

    $Verbose = @{}
    if ($ENV:BHBranchName -notlike "master" -or $env:BHCommitMessage -match "!verbose") {
        $Verbose.add("Verbose", $True)
    }

    Describe "Update-RedlockToken" {
        It "Should update token if valid token is present" {
            $global:RedLockToken = 'good token'
            Mock Invoke-RestMethod { return @{ token = 'new token' } }
            Update-RedLockToken
            $global:RedLockToken | Should -Be 'new token'
        }
        It "Should throw if token is expired" {
            Mock Invoke-RestMethod { Throw 'Response status code does not indicate success: 401 (Unauthorized).' }
            { Update-RedLockToken } | Should -Throw "Token has expired, get a new one with Connect-Redlock."
        }
        It "Should throw if connection hasn't been made" {
            $Global:RedLockToken = $null
            { Update-RedLockToken } | Should -Throw "No Token present, get one with Connect-RedLock."
        }
    }
}