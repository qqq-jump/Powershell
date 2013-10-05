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
        Mandatory = $true,
        HelpMessage = "Computername"
    )]
    [String[]]$Computername,

    [Parameter(
        HelpMessage = "Unit of Byte Conversion"
    )]
    [ValidateSet("KB","MB","GB","TB","PB")]
    [String]$Unit = "GB",

    [Parameter(
        HelpMessage = "# of Characters to Round to"
    )]
    [ValidateRange(0,15)]
    [Int]$n = 2
)
    $Date = Get-Date -UFormat "%Y-%m-%d"

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

    Foreach($Computer in $Computername){
        try{
            $drives = Get-WmiObject `
                -Class Win32_Logicaldisk `                -ComputerName $Computer `                -ErrorAction Stop | Where {$_.DriveType -eq 3}

            For($i = 0;$i -lt $drives.Count;$i++){
                $row = $Table.NewRow()
        
                $row.ComputerName = $Computer
                $row.Drive = $drives[$i].DeviceID
                $row.UnitSize = $Unit
        
                $row.Size = [Math]::Round(
                    ($drives[$i].Size / "1$Unit"),$n
                )

                $row.Used = [Math]::Round(
                    ($drives[$i].Size / "1$Unit") - ($drives[$i].FreeSpace / "1$Unit"),$n
                )

                $row.Free = [Math]::Round(
                    ($drives[$i].FreeSpace / "1$Unit"),$n
                )

                $row.PercentageFree = [Math]::Round(
                    ($drives[$i].FreeSpace / "1$Unit") / ($drives[$i].Size / "1$Unit") * 100,$n
                )

                $row.Date = $Date
                $Table.Rows.Add($row)
            }
        }
        catch [System.UnauthorizedAccessException]{
            "Credentials didn't have the authority to access required data on $Computer"
        }
        catch [System.Management.ManagementException]{
            "Credentials weren't accepted by $Computer"
        }
        catch [Exception]{
            If($_.Exception.GetType().Name -eq "COMException"){
                "Couldn't establish a connection to $Computer"
            }
        }
    }
    return $Table
}