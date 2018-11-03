function Set-KeyvaultPSCredential
{
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline=$true)]
        [string]$Name,
        [Parameter(Mandatory = $true, ValueFromPipeline=$true)]
        [string]$UserName,
        [Parameter(Mandatory = $true)]
        [string]$VaultName,
        [Parameter(Mandatory = $false)]
        [string]$ChangePW = $false
    )

    #Keyvault that is used for storing secrets
    $keyVault = Get-AzureRmKeyVault | Where-Object -Property VaultName -eq $VaultName
    if($keyVault)
    {
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
            Write-Output "Creating/Updating secret for $($Name) on $($VaultName)."
            Set-AzureKeyVaultSecret @Splat
        }
        else
        {
            Write-Output "No action for $($Name) on $($VaultName)."
            $CurrentSecret
        }
    }
    else
    {
        Write-Error "Keyvault $vaultName not found."
    }
}

