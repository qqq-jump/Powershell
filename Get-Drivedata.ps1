<#
TODO:
- paralellization support
- import function for MSSQL,MySQL?
- better description
- read comments
#>
Function Get-Drivedata{
<#
.SYNOPSIS
Grabs Drivedata from named Client and returns them in a DataTable.
.DESCRIPTION
Well, what should i write here :|
.EXAMPLE
Get-Drivedata Styx MB 12

Grabs Drive Information from the Client Styx, Data will be stored in MB and till the 12 Character.
#>
param(
    [Parameter(
        Mandatory = $true,
        HelpMessage = "Computername"
    )]
    [String]$Computername,
    [Parameter(
        HelpMessage = "Unit of Byte Conversion"
    )]
    [String]$Unit = "GB", #is there a type for this :/ would look way better.
    [Parameter(
        HelpMessage = "# of Characters to Round to"
    )]
    [Int]$n = 2
)
    $Table = New-Object System.Data.DataTable "DriveData"

    $Columns = "Computername.String",
               "Drive.String",
               "Size.Decimal",
               "Used.Decimal",
               "Free.Decimal",
               "PercentageFree.Double"
    #maybe add in imports from .csv?
    
    For($i = 0;$i -lt $Columns.Count;$i++){

        $Split = $Columns[$i].Split(".")

        $Table.Columns.Add(
            (New-Object System.Data.DataColumn $Split[0],$Split[1])
        )
    }    

    $drives = Get-WmiObject -Class Win32_Logicaldisk -ComputerName $Computername | Where {$_.DriveType -eq 3}
    #wouldn't this be redudant IF the function is executed ON the client and not on the server?

    For($i = 0;$i -lt $drives.Count;$i++){
        $row = $Table.NewRow()
        
        $row.ComputerName = $Computername
        $row.Drive = $drives[$i].DeviceID
        
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

        $Table.Rows.Add($row)

        #is this the best way of doing this? could it be done "prettier" ?
    }

    return $Table
}