. .\100Projects\reversestring.ps1

function checkfor-palindrome{
param(
    [Parameter(
        Mandatory = $true,
        HelpMessage = "String to be checked"
    )]
    [String]$String
)
    If($String -eq (reverse-string $String)){
        Write-Output "$string is a palindrome!"
    }Else{
        Write-Output "$string is not a palindrome!"
    }
}