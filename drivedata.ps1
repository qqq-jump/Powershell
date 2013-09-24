$computersystem = gwmi -Class win32_computersystem

$table = New-Object System.Data.DataTable $computersystem.name

$column_name = ("Drive","Size","Used","Free","PercentFree")
$column_type = ("String","Decimal","Decimal","Decimal","Int")

$template = New-Object psobject
$template | Add-Member -MemberType NoteProperty -Name "Name" -Value $null
$template | Add-Member -MemberType NoteProperty -Name "Type" -Value $null

$columns = @()

For($i=0;$i -eq ($column_name.Count-1);$i++){
    $column = $template | Where *
    
    $column.Name = $column_name[$i]
    $column.Type = $column_type[$i]

    $columns += $column
}



$col1 = New-Object System.Data.DataColumn Drive,([String])
$col2 = New-Object System.Data.DataColumn Size,([decimal])
$col3 = New-Object System.Data.DataColumn Used,([decimal])
$col4 = New-Object System.Data.DataColumn Free,([decimal])
$col5 = New-Object System.Data.DataColumn PercentFree,([int])

$table.Columns.Add($col1)
$table.Columns.Add($col2)
$table.Columns.Add($col3)
$table.Columns.Add($col4)
$table.Columns.Add($col5)

$drives = Get-WmiObject -Class win32_logicaldisk -ComputerName $computersystem.Name

$drives | Where-Object {$_.DriveType -eq 3} | ForEach{
    $row = $table.NewRow()
    $row.Drive = $_.DeviceID
    $row.Size = "{0:F3}" -f($_.Size/1gb)
    $row.Used = "{0:F3}" -f(($_.Size/1gb)-($_.FreeSpace/1gb))
    $row.Free = "{0:F3}" -f($_.FreeSpace/1gb)
    $row.PercentFree = "{0:F3}" -f($_.FreeSpace/1gb)/($_.Size/1gb)*100
    $table.Rows.Add($row)
}
        
$table.WriteXml("C:\Users\$env:username\Desktop\driveinfo.xml")
$table.WriteXmlSchema("C:\Users\$env:username\Desktop\driveinfo.xsd")
