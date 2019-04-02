function Update-RedLockToken {
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
            Invoke-RestMethod @RestParams
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