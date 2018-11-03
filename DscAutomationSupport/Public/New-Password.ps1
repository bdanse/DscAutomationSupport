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
