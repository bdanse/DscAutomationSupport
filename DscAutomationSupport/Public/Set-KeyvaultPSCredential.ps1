function Set-KeyvaultPSCredential
{
    [CmdletBinding(DefaultParameterSetName='default')]
    param (
        [Parameter(
        Mandatory = $true,
        ValueFromPipeline=$true,
        ParameterSetName='pipeline')]
        [object]$InputObject,

        [Parameter(Mandatory = $true,
        ValueFromPipeline=$true,
        ParameterSetName='default')]
        [string]$Name,

        [Parameter(Mandatory = $true,
        ValueFromPipeline=$true,
        ParameterSetName='default')]
        [string]$UserName,

        [Parameter(Mandatory = $true)]
        [string]$VaultName,

        [Parameter(Mandatory = $false)]
        [bool]$ChangePW = $false
    )

    Begin
    {
        $keyVault = Get-AzureRmKeyVault | Where-Object -Property VaultName -eq $VaultName
        if($null -eq $keyVault)
        {
            throw "Keyvault $vaultName not found."
        }
    }

    Process {

        if($PSCmdlet.ParameterSetName -eq 'pipeline')
        {
            $Name = $InputObject.Name
            $UserName = $InputObject.UserName
        }

        $CurrentSecret = $keyVault | Get-AzureKeyVaultSecret -Name $Name -ErrorAction SilentlyContinue

        $splat = @{
            Name        = $Name
            SecretValue = (New-Password)
            VaultName   = $keyVault.VaultName
            Tag         = @{
                UserName = $UserName
            }
        }

        if($null -eq $CurrentSecret -or $ChangePW -eq $true)
        {
            Set-AzureKeyVaultSecret @Splat
        }
        else
        {
            $CurrentSecret
        }
    }
}
