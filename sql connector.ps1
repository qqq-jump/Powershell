Function SQL-Query{
param(
    [Parameter(
        Position = 0,
        Mandatory = $true,
        HelpMessage = "SQL Server")]
    $Server,
    [Parameter(
        Position = 1,
        Mandatory = $true,
        HelpMessage = "Database")]
    $Database,
    [Parameter(
        Position = 2,
        Mandatory = $true,
        HelpMessage = "SQL Query")]
    $Query
)
    $Connection = New-Object System.Data.SQLClient.SQLConnection
    $Connection.ConnectionString = "Server = $Server; Database = $Database; Integrated Security = True"

    $Command = New-Object System.Data.SQLClient.SQLCommand
    $Command.CommandText = $Query
    $Command.Connection = $Connection

    $Adapter = New-Object System.Data.SQLClient.SQLDataAdapter
    $Adapter.SelectCommand = $Command

    $Dataset = New-Object System.Data.Dataset

    $Adapter.Fill($Dataset)

    $Connection.Close()
    
    return $Dataset
}