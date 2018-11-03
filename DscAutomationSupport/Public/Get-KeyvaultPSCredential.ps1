function Get-KeyvaultPSCredential
{
    [CmdletBinding()]
    [OutputType([PSCredential])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(Mandatory = $false)]
        [string]$VaultName

    )

    if(-not $PSBoundParameters.ContainsKey('VaultName'))
    {
        $VaultName = Get-AutomationVariable -Name KeyVaultPSCredential

    }

    #Keyvault that is used for storing secrets
    $keyVault = Get-AzureRmKeyVault | Where-Object -Property VaultName -eq $VaultName

    if($keyVault)
    {
        $CurrentSecret = $keyVault | Get-AzureKeyVaultSecret -Name $Name -ErrorAction SilentlyContinue
        if($CurrentSecret)
        {
            if($CurrentSecret.Tags.Contains('UserName'))
            {
                $PSCredential = New-Object System.Management.Automation.PSCredential($CurrentSecret.Tags['UserName'], $CurrentSecret.SecretValue)
            }

        }

        if($PSCredential -and ($PSCredential.GetType() -eq [PSCredential]))
        {
            return $PSCredential
        }
    }

}
