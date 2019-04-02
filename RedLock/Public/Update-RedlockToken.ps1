function Update-RedLockToken {
    [CmdletBinding()]

    Param (
    )

    BEGIN {
        $VerbosePrefix = "Update-RedLockToken:"

        if ($null -eq $Global:RedLockToken) {
            try {
                throw
            } catch {
                $PSCmdlet.ThrowTerminatingError([HelperProcessError]::throwCustomError(1002, ""))
            }
        }
        # should always be the same
        $BaseRedLockUri = 'https://api2.redlock.io/'

        # setup base rest parameters
        $RestParams = @{
            Uri         = ($BaseRedLockUri + 'auth_token/extend')
            Method      = 'Get'
            ContentType = 'application/json'
            Headers     = @{
                'x-redlock-auth' = $Global:RedLockToken
            }
        }
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
                    $PSCmdlet.ThrowTerminatingError([HelperProcessError]::throwCustomError(1001, $Global:RedLockToken))
                }
                default {
                    $PSCmdlet.ThrowTerminatingError($PSItem)
                }
            }
        }
    }
}