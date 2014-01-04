Function Validate-Address{
<#
.Synopsis
Checks an IP address or DNS hostname if it's usable.
.Description
Trys to parse the input into a [IPAddress] typename, if that fails the function will check if the entered hostname is resolveable.
The result of the check will be returned as a custom psobject.
.Output
[System.Management.Automation.PSCustomObject]
.Example
Validate-Address 127.0.0.1

Check if the loopback address is actually an ip.

Input                                                                        IP                                                                         
-----                                                                        --                                                                         
127.0.01                                                                     127.0.01
.Example
Validate-Address google.com

Check for google.

Input                                                                        IP                                                                         
-----                                                                        --                                                                         
google.com                                                                   {173.194.113.161, 173.194.113.169...} 
.Example
Validate-Address imnotadomainname

Checks against a fictional name.

Input                                                                        IP
-----                                                                        --
imnotadomainname                                                             False
#>
param(
    [Parameter(
        Mandatory = $true
    )]
    $Address
)
    [IPAddress]$tester = "127.0.0.1"

    $output = New-Object PSObject
    $output | Add-Member -MemberType NoteProperty -Name Input -Value $Address
    $output | Add-Member -MemberType NoteProperty -Name IP -Value $null

    If([IPAddress]::TryParse($Address,[ref]$tester)){
         $output.ip = $Address
    }
    Else{
        try{
            $output.ip = [Net.Dns]::GetHostAddresses($Address).IPAddressToString
        }
        catch [Exception]{
            $output.ip = $false
        }
    }
    return $output
}