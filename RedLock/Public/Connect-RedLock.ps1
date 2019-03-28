function Connect-RedLock {
    [CmdletBinding()]

    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $False, Position = 1)]
        [string]$CustomerName
    )

    BEGIN {
        $VerbosePrefix = "Connect-RedLock:"
        $BaseRedLockUri = 'https://api.redlock.io/'

        $RestParams = @{
            $Uri = ($BaseRedLockUri + 'login')

        }

    }

    PROCESS {
    }

    END {
    }
}