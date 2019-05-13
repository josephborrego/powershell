#for davids program that goes through character sets


$characterSets = "UN"
$num = Get-random -Minimum 10 -Maximum 20
$length = $characterSets.Length
$string = ""
$tempnum = 1

#The point of this is to create a password based upon what values are in $characterSets
#the $tempnum is a counter used to go through the $charactersets array.

# (e.g.) $charactersets = [UNL]        $num = 10       $length = 3
#$check = U    $tempnum =0     $num=1      $string adds a random uppercase letter       
#$check = N    $tempnum =1     $num=2      $string adds a random number    
#$check = L    $tempnum =2     $num=3      $string adds a random lowercase letter
#then reset the $tempnum variable to 0 because $tempnum = $length-1 = 2
                     
#$check = U    $tempnum =0     $num=4      $string adds a random uppercase letter       
#$check = N    $tempnum =1     $num=5      $string adds a random number    
#$check = L    $tempnum =2     $num=6      $string adds a random lowercase letter
#repeat until $i -lt $num 

for($i=0; $i -lt $num; $i++)
{ 
    if($length -eq 1 -or $tempnum -eq $length -1) {$tempnum = 0}
    else {$tempnum++}
    $check = [char]$characterSets[$tempnum]

    if($check -match "U"){ $string += (65..90) | Get-Random -Count 1 | % {[char]$_} }
    if($check -match "N"){ $string += (48..57) | Get-Random -Count 1 | % {[char]$_} }
    if($check -match "L"){ $string += (97..122) | Get-Random -Count 1 | % {[char]$_} }
    if($check -match "S"){ $string += (33..47) + (58..64) + (91..96) | Get-Random -Count 1 | % {[char]$_} }	

}

$string