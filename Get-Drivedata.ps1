<#
TODO:
- Check on Host reachability before executing wmi request
- Check for other problems (host firewall not letting request through, creds wrong, etcetc)
- Use of Credentials
- import function for MSSQL,MySQL?
- better description
- improve on the catches (maybe a switch?)
- exit codes (or somehting like that)
- more examples
- cleaning up the code
- integrate verbose messages / changes to the code
- rework the remoting like describe at the bottom of the page here: http://technet.microsoft.com/en-us/library/hh849718.aspx
#>
Function Get-Drivedata{
<#
.SYNOPSIS
Grabs Drivedata from named Client and returns them in a DataTable.
.DESCRIPTION
Well, what should i write here :|
.EXAMPLE
Get-Drivedata

This just gets the drive Information from the local client, like so:

RunspaceId     : 54d81ca9-8403-4d0a-8d94-df8977665b19
Computername   : STYX
Drive          : C:
UnitSize       : GB
Size           : 59,28
Used           : 46,36
Free           : 12,92
PercentageFree : 21,79
Date           : 2013-10-08
.EXAMPLE
Get-Drivedata Styx MB 12

Grabs Drive Information from the Client Styx, Data will be stored in MB till the 12th Character.
#>
param(
    [Parameter(
        Position = 0,
        HelpMessage = "Computername"
    )]
    [String[]]$Computername = $env:COMPUTERNAME,

    [Parameter(
        Position = 1,
        HelpMessage = "Unit of Byte Conversion"
    )]
    [ValidateSet("KB","MB","GB","TB","PB")]
    [String]$Unit = "GB",

    [Parameter(
        Position = 2,
        HelpMessage = "# of Characters to Round to"
    )]
    [ValidateRange(0,15)]
    [Int]$n = 2
)
    #initializing $masterlist as an array to feed it more easily
    $masterlist = @()

    For($i = 0;$i -lt $Computername.Count;$i++){

        Start-Job -Name ("Get-Drivedata" + $i) -ArgumentList $Computername[$i],$Unit,$n -ScriptBlock{
            #preparing the columns
            $Columns = "Computername.String",
                       "Drive.String",
                       "UnitSize.String",
                       "Size.Decimal",
                       "Used.Decimal",
                       "Free.Decimal",
                       "PercentageFree.Double",
                       "Date.String"
        

            $Table = New-Object System.Data.DataTable "DriveData"
   
            For($i = 0;$i -lt $Columns.Count;$i++){
                $Split = $Columns[$i].Split(".")

                $Table.Columns.Add(
                    (New-Object System.Data.DataColumn $Split[0],$Split[1])
                )
            }

            try{
                #grab client data
                $drives = Get-WmiObject `
                    -Class Win32_Logicaldisk `
                    -ComputerName $args[0] `
                    -ErrorAction Stop | Where {$_.DriveType -eq 3}
                
                #assigning data to rows
                For($i = 0;$i -lt $drives.Count;$i++){
                    $row = $Table.NewRow()
                    
                    $row.Date = Get-Date -UFormat "%Y-%m-%d"        
                    $row.ComputerName = $drives[$i].__SERVER
                    $row.Drive = $drives[$i].DeviceID
                    $row.UnitSize = $args[1]
        
                    $row.Size = [Math]::Round(
                        ($drives[$i].Size / ("1" + $args[1])),$args[2]
                    )

                    $row.Used = [Math]::Round(
                        ($drives[$i].Size / ("1" + $args[1])) - ($drives[$i].FreeSpace / ("1" + $args[1])),$args[2]
                    )

                    $row.Free = [Math]::Round(
                        ($drives[$i].FreeSpace / ("1" + $args[1])),$args[2]
                    )

                    $row.PercentageFree = [Math]::Round(
                        ($drives[$i].FreeSpace / ("1" + $args[1])) / ($drives[$i].Size / ("1" + $args[1])) * 100,$args[2]
                    )

                    #assigning columns to row
                    $Table.Rows.Add($row)
                }
            }
            catch [System.UnauthorizedAccessException]{
                "Credentials didn't have the authority to access required data on " + $args[0]
            }
            catch [System.Management.ManagementException]{
                "Credentials weren't accepted by " + $args[0]
            }
            catch [Exception]{
                If($_.Exception.GetType().Name -eq "COMException"){
                    "Couldn't establish a connection to " + $args[0]
                }
            }
            return $Table
        } | Out-Null
        
        Wait-Job -Name ("Get-Drivedata" + $i) | Out-Null

        $masterlist += Receive-Job -Name ("Get-Drivedata" + $i)

        Remove-Job -Name ("Get-Drivedata" + $i)
    }
    return $masterlist | Select -Property * -ExcludeProperty RunspaceID
}