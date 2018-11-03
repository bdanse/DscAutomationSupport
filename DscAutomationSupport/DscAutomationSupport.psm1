function Connect-Azure
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$connectionName = "AzureRunAsConnection"
    )

    try
    {
        # Get the connection "AzureRunAsConnection "
        $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName
        Add-AzureRmAccount `
            -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
    }
    catch
    {
        if (!$servicePrincipalConnection)
        {
            $ErrorMessage = "Connection $connectionName not found."
            throw $ErrorMessage
        } else{
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }
}

Function New-Password {
    Param (
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [int]$length = 30,
        [switch]$AsPlainText
    )

    $characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789(){}[]#*!?=+"
    $random = 1 .. $length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs = ""
    $password = [String]$characters[$random]
    if($AsPlainText)
    {
        Return $password
    }
    else
    {
        return ConvertTo-SecureString $password -AsPlainText -Force
    }

}

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

function Set-KeyvaultPSCredential
{
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
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


}

