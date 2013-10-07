function test{
param($1,$2)
    $1
    $2
}
$list = $env:COMPUTERNAME
$Unit = "GB"
$n = 2

ForEach($computer in $list){

    Start-Job -ArgumentList $Unit,$n -ScriptBlock ${function:test} | Out-Null
}
Wait-Job * | Out-Null
Receive-job * 
Remove-Job *