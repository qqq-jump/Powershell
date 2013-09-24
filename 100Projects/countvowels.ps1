function count-vowels{
param(
    [Parameter(
        Mandatory = $true,
        HelpMessage = "Enter String of Text")]
    [String]$String
)

    For($i = 0;$i -lt $String.Length;$i ++){
        
        If(            ($String[$i] -like "a") -or`            ($String[$i] -like "e") -or`            ($String[$i] -like "i") -or`            ($String[$i] -like "o") -or`            ($String[$i] -like "u")
        ){
            $counter ++
        }
    }
    return $counter
}