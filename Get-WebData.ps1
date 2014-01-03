<#
Todo:
- better check for credentials
#>
Function Get-WebData{
<#
.Synopsis
Grabs raw Content from provided URL

.Description

.Parameter User
Declares the User to use for authentication against the URL
.Parameter Password
Declares the Passwort belonging to User

If you don't want to input the passwort decrypted, leave the value empty, another crypted query will prompt then.

.Parameter AsFile
Creates a file in the current directory which uses the last split (/ symbol) as a name.

.Example
Get-WebData https://raw.github.com/qqq-jump/Powershell/master/Get-WebData.ps1

Gets the raw input for the file from github

.Example
Get-WebData https://raw.github.com/qqq-jump/Powershell/master/Get-WebData.ps1 -AsFile

Grabs the Data from Github and creates a file called Get-WebData.ps1 in the current directory.
.Outputs
[String]
.Notes
Initial info from newslacker.net

.Link
https://github.com/qqq-jump/Powershell
http://blog.newslacker.net/2012/03/powershell-executing-net-web-request.html
http://stackoverflow.com/questions/8919414/powershell-http-post-rest-api-basic-authentication

#>
param(
    [Parameter(
        Mandatory = $true
    )]
    [String]$URL,

    [Parameter(
    )]
    [String]$User,

    [Parameter(
    )]
    [String]$Password,

    [Parameter(
        HelpMessage = 'In miliseconds'
    )]
    [Int32]$Timeout = 600000,

    [Parameter(
    )]
    [Switch]$AsFile
    
)

    Write-Verbose 'Creating WebRequest'
    $req = [Net.WebRequest]::Create($URL)
    $req.Method = 'GET'
    $req.Timeout = $Timeout

    Write-Verbose 'Checking for Credentials...'
    If($User){

        Write-Verbose "User existent ($User)"
        If(!($Password)){

            Write-Verbose 'Password not given, asking User for input'
            [String]$Password = Read-Host -AsSecureString
            $req = New-Object Net.NetworkCredential($User,$Password) #not working right now...-.-
        }
        Else{

            $req = New-Object Net.NetworkCredential($User,$Password)
        }
    }
    Else{

        Write-Verbose 'No User defined'
    }

    Write-Verbose 'Trying to get a response from $URL'
    $result = $req.GetResponse()

    Write-Verbose 'reading response'
    [IO.StreamReader]$stream = $result.GetResponseStream()
    $output = $stream.ReadToEnd()

    If($AsFile){
        
        Write-Verbose 'Creating file based on $URL'
        Set-Content -Path (".\" + $URL.Split('/')[($URL.Split('/').Count)-1]) -Value $output
    }Else{
        
        Write-Verbose 'Returning data'
        return $output
    }
}