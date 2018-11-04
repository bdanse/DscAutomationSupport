# DscAutomationSupport
Azure Automation Account support module

## Functions

### Connect-Azure

``` powershell
NAME
    Connect-Azure

SYNTAX
    Connect-Azure [[-connectionName] <string>]  [<CommonParameters>]
```



### New-Password

``` powershell
NAME
    New-Password

SYNTAX
    New-Password [[-length] <int>] [-AsPlainText]  [<CommonParameters>]
```

### Set-KeyvaultPSCredential

``` powershell
NAME
    Get-KeyvaultPSCredential

SYNTAX
    Get-KeyvaultPSCredential [-Name] <string> [[-VaultName] <string>]  [<CommonParameters>]

EXAMPLES

#Single keyvault PSCredential secret

Set-KeyvaultPSCredential -Name 'Name1' -UserName 'domain\user2' -VaultName mykeyvault

#Create multiple keyvault PSCredential secrets based on a hashtable

$hash = @(
    @{
    Name = 'Name1'
    UserName = 'domain\User1'
    },
    @{
        Name = 'Name2'
    UserName = 'domain\User2'
    }
)

$hash | Set-KeyvaultPSCredential -VaultName mykeyvault
```



### Get-KeyvaultPSCredential
Vault is optional within an Azure automation account. If you set a variable named **PSCredentialKeyVault**.

``` powershell
NAME
    Get-KeyvaultPSCredential

SYNTAX
    Get-KeyvaultPSCredential [-Name] <string> [[-VaultName] <string>]  [<CommonParameters>]

EXAMPLES
#Retrieve a keyvault PSCredential object

Get-KeyvaultPSCredential -name Name1 -VaultName mykeyvault
```
