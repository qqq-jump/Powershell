function test{
param($1,$2)
    $1
    $2
}
$list = $env:COMPUTERNAME,"localhost"
$Unit = "GB"
$n = 2

ForEach($computer in $list){

    Start-Job -ArgumentList $Unit,$n -ScriptBlock {
        $args[0]
        $args[1]
    } | Out-Null
}
Wait-Job * | Out-Null
Receive-job * 
Remove-Job *