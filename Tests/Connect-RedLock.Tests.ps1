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

    # Create credential object
    $AesKey = New-EncryptionKey
    $GoodPassword = 'goodpass'
    $BadPassword = 'badpass'
    $GoodEncryptedPassword = New-EncryptedString -PlainTextString $GoodPassword -AesKey $AesKey
    $BadEncryptedPassword = New-EncryptedString -PlainTextString $BadPassword -AesKey $AesKey

    $DeviceUsername = 'testuser'
    $GoodDevicePassword = ConvertTo-SecureString $GoodEncryptedPassword -Key $AesKey
    $GoodDeviceCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DeviceUsername, $GoodDevicePassword

    $BadDevicePassword = ConvertTo-SecureString $BadEncryptedPassword -Key $AesKey
    $BadDeviceCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DeviceUsername, $BadDevicePassword

    $GoodToken = "valid token"

    # mock good creds
    Mock Invoke-RestMethod { return @{ token = $GoodToken } } -ParameterFilter { $Body -and $Body.Contains($GoodPassword) }
    Mock Invoke-RestMethod { Throw 'Response status code does not indicate success: 401 (Unauthorized).' } -ParameterFilter { $Body -and $Body.Contains($BadPassword) }

    Describe "Connect-Redlock" {
        It "Should return correct token" {
            Connect-Redlock -Credential $GoodDeviceCredential
            $global:RedLockToken | Should -Be $GoodToken
        }
        It "Should throw with invalid creds" {
            { Connect-Redlock -Credential $BadDeviceCredential } | Should -Throw "Invalid credentials, please provide valid Redlock credentials."
        }
    }
}