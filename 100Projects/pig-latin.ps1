﻿function pig-latin{
param(
    [Parameter(
        Mandatory = $true,
        HelpMessage = "Put in the Word or Sentence which shall be pig-latined")]
    [String]$sentence
)
    $words = $sentence.Split(" ")
    
    Foreach($word in $words){
        If ($word.StartsWith("A") -or`
            
            $output += $word + "way" + " "
        }Else{
            $output += $word.Remove(0,1) + $word[0] + "ay" + " "
        }
    }
    
    return $output
}