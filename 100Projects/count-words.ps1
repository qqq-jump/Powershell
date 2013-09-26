<#
got initial set of special characters and converting to regex from
http://rafdelgado.blogspot.de/2012/06/powershell-removing-special-characters.html
#>
function count-words{
param(
    [Parameter(
        Mandatory = $true,
        HelpMessage = "String to be analyzed"
    )]
    [String[]]$String,
    [Parameter(
        HelpMessage = "Number of entries of the top statistics shown"
    )]
    [Int]$Number = 5
)

    $notletters = '!','"','£','$','€','%','&','^','°','*','(',')','@','=','+','¬','`','\','<','>','.',',','?','/',':',';','#','~',"'",'0','1','2','3','4','5','6','7','8','9','-'
    $removepattern = [String]::Join("|",($notletters | %{[Regex]::Escape($_)}))

    $String = $String.ToLower() -replace $removepattern,""

    $NumberOfWords = ($String | Measure-Object -Word).Words

    $template = New-Object psobject
    $template | Add-Member -MemberType NoteProperty -Name "Word" -Value $null
    $template | Add-Member -MemberType NoteProperty -Name "Appearances" -Value $null #can't be count, else the .count method will be inaccessible

    $masterlist = @()

    $Words = $String.Split(" ") | Where Length -ne 0

    ForEach($word in $Words){
        $match = $masterlist | Where Word -eq $word
        
        If(!($match)){
            $list = $template | Select-Object *

            $list.Word = $word
            $list.Appearances = "1"
            $masterlist += $list
        }Else{
            
            $counter = ($match.Appearances).ToInt32($_) #needs to be converted as noteproperties are string only
            $counter++
            $counter = $counter.ToString()
            
            $match.Appearances = $counter
        }
    }
    
    $Message = "There are a total number of $NumberOfWords Words, following is a list of the $Number most used."
    
    Write-Output $Message
    
    $masterlist = $masterlist | Sort-Object Appearances -Descending

    return $masterlist[0..($Number - 1)]
}