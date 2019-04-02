function Update-RedLockToken {
    [CmdletBinding()]

    Param (
    )

    BEGIN {
        $VerbosePrefix = "Connect-RedLock:"
        # should always be the same
        $BaseRedLockUri = 'https://api2.redlock.io/'

        # setup base rest parameters
        $RestParams = @{
            Uri         = ($BaseRedLockUri + 'auth_token/extend')
            Method      = 'Get'
            ContentType = 'application/json'
            Headers     = @{
                'x-redlock-auth' = $Global:RedlockToken
            }
        }
    }

    PROCESS {
    }

    END {
        try {
            $Connect = Invoke-RestMethod @RestParams
            $Global:RedlockToken = $Connect.token
        } catch {
            switch (($_.ErrorDetails.Message | ConvertFrom-Json).message) {
                'invalid_credentials' {
                    $PSCmdlet.ThrowTerminatingError([HelperProcessError]::throwCustomError(1000, $Credential))
                }
                default {
                    $PSCmdlet.ThrowTerminatingError($PSItem)
                }
            }
        }
    }
}