If($masterlist){clv masterlist}

function test{
param($1,$2)
    $1
    $2
}
$list = $env:COMPUTERNAME,"localhost"
$Unit = "GB"
$n = 2

$masterlist = @()

ForEach($computer in $list){

    Start-Job -ArgumentList $Unit,$n -ScriptBlock {
        $list = $args[0] + $args[1]
        $list
    } | Out-Null
}
Wait-Job * | Out-Null
$data = Receive-job * 
Remove-Job *