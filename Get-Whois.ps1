<#
TODO:
- Work on the Description, Examples, etc.
- Add a admin-c and tech-c lookup (currently not implemented? request to ripe sent)
- nslookup through  Validate-Address should go against ripe db in this case....
- remove curly brackets from 'authority'
- Error handling
- CLEANUP
#>

Function Get-Whois{
<#
.Synopsis
A Whois lookup through the RIPE Database API.
.Description
-
.Example
Get-Whois -Address 193.99.144.77

Looks up the Information for Heise.de:

Authority       : {ripe}
Queried Address : 193.99.144.77
Subnet          : 193.99.144.0/24
Description     : Heise Zeitschriften Verlag GmbH & Co. KG, Hannover
Country         : DE

#>
param(
    [Parameter(
    )]
    $Address = (Get-MyIP).ip

)
    If((Validate-Address $Address).IP){
        $Address = (Validate-Address $Address).IP
    }
    Else{
        Write-Output "$Address is not a valid IP Address or Hostname."
        break
    }
    
    $apiurl = "https://stat.ripe.net/data/whois/data.json?resource=" + $Address

    $data = (Get-WebData -URL $apiurl | ConvertFrom-Json).data

    $keys = $data.records.key
    $values = $data.records.value

    
    #filter through records
    For($i = 0;$i -lt $values.Count;$i++){
        
        If($keys[$i] -eq 'inetnum'){
            $subnet = $values[$i]
        }
        If($keys[$i] -eq 'descr'){
            If(!($description)){
                $description = $values[$i]
            }
            Else{
                $description += ", " + $values[$i]
            }
        }
        If($keys[$i] -eq 'country'){
            $country = $values[$i]
        }
    }



    #assign filtered data
    $output = New-Object psobject
    
    $output | Add-Member -MemberType NoteProperty -Name 'Authority' -Value $data.authorities
    $output | Add-Member -MemberType NoteProperty -Name 'Queried Address' -Value $data.resource
    $output | Add-Member -MemberType NoteProperty -Name 'Subnet' -Value $subnet
    $output | Add-Member -MemberType NoteProperty -Name 'Description' -Value $description
    $output | Add-Member -MemberType NoteProperty -Name 'Country' -Value $country


    return $output
}