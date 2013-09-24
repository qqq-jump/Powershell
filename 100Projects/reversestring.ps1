function reverse-string{
param(
    [Parameter(
        Mandatory = $true,
        HelpMessage = "String to be reversed")]
    [String]$String
)
    For($i = 1;$i -le $String.Length;$i++){
        $result += $string[$String.Length - $i]
    }
    return $result
}