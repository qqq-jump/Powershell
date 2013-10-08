<#
TODO:
- Check on Host reachability before executing wmi request
- Check for other problems (host firewall not letting request through, creds wrong, etcetc)
- Use of Credentials
- paralellization support
- import function for MSSQL,MySQL?
- better description
- improve on the catches (maybe a switch?)
- exit codes (or somehting like that)
- more examples
- cleaning up the code
#>
Function Get-Drivedata{
<#
.SYNOPSIS
Grabs Drivedata from named Client and returns them in a DataTable.
.DESCRIPTION
Well, what should i write here :|
.EXAMPLE
Get-Drivedata Styx MB 12

Grabs Drive Information from the Client Styx, Data will be stored in MB till the 12th Character.
#>
param(
    [Parameter(
        Position = 0,
        HelpMessage = "Computername"
    )]
    [String]$Computername = $env:COMPUTERNAME,

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
    $Date = Get-Date -UFormat "%Y-%m-%d"

    For($i = 0;$i -lt $Computername.Count;$i++){

        Start-Job -ArgumentList $Computername[$i],$Unit,$n,$Date -ScriptBlock{
        

            $Table = New-Object System.Data.DataTable "DriveData"

            $Columns = "Computername.String",
                       "Drive.String",
                       "UnitSize.String",
                       "Size.Decimal",
                       "Used.Decimal",
                       "Free.Decimal",
                       "PercentageFree.Double",
                       "Date.String"
    
            For($i = 0;$i -lt $Columns.Count;$i++){
                $Split = $Columns[$i].Split(".")

                $Table.Columns.Add(
                    (New-Object System.Data.DataColumn $Split[0],$Split[1])
                )
            }
                try{
                    $drives = Get-WmiObject `
                        -Class Win32_Logicaldisk `
                        -ComputerName $args[0] `
                        -ErrorAction Stop | Where {$_.DriveType -eq 3}

                    For($i = 0;$i -lt $drives.Count;$i++){
                        $row = $Table.NewRow()
        
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

                        $row.Date = $args[3]
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
    }
}