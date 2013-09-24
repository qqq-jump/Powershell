function pi-n{
param(
    [Parameter(
        Mandatory = $true,
        HelpMessage = "Till what Nth Number pi will be generated")]
    [int]$n
)
    $pi = [math]::Round([math]::Pi,$n)

    return $pi
}

function get-pi{
param(
    [Parameter(
        Mandatory = $true,
        HelpMessage = "Till what Nth Number pi will be generated")]
    [int]$n
)
 #GET TO DO MORE THEN ONLY 15 DIGITS YOU LAZY ASSHOLE
}