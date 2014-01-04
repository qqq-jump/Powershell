Function Get-MyIP{
    $data = (Get-WebData -URL https://stat.ripe.net/data/whats-my-ip/data.json | ConvertFrom-Json).data

    return $data
}