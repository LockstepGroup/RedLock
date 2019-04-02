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
        # should always be the same
        $BaseRedLockUri = 'https://api2.redlock.io/'

        # setup base rest parameters
        $RestParams = @{
            Uri         = ($BaseRedLockUri + 'login')
            Method      = 'Post'
            Body        = @{
                username = $Credential.UserName
                password = $Credential.GetNetworkCredential().Password
            }
            ContentType = 'application/json'
        }

        # add customername if specified
        if ($CustomerName) {
            $RestParams.Body.customerName = $CustomerName
        }

        # convert body to json string
        $RestParams.Body = $RestParams.Body | ConvertTo-Json
    }

    PROCESS {
    }

    END {
        try {
            $Connect = Invoke-RestMethod @RestParams
            $Global:RedLockToken = $Connect.token
        } catch {
            switch -Regex ($_.Exception.Message) {
                '401\ \(Unauthorized\)' {
                    $PSCmdlet.ThrowTerminatingError([HelperProcessError]::throwCustomError(1000, $Credential))
                }
                default {
                    $PSCmdlet.ThrowTerminatingError($PSItem)
                }
            }
        }
    }
}