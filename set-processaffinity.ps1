<#
-start multiple processess
-assign process to cpu
#>
function Set-Processaffinity{
param(
    [Parameter(
        Mandatory = $true
    )]
    $procname,
    [Parameter(
        Mandatory = $true
    )]
    $Core

)
    (Get-Process $procname).ProcessorAffinity=$Core
}