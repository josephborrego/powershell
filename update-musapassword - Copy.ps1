function Update-MusaPassword
{
<#
    .SYNOPSIS 

      reset a password to a minimum of 16 characters with at least 1 of the following types:
    Upper Case, Lower Case, Number, Special Character

    .INPUTS

    [System.String]

    .OUTPUTS

    [System.String]
	
	.NOTES
	Title: Update-MusaPassword
	Author: Joseph Andrew Borrego
	Creation Date: 12/13/2018
	Editor: Joseph Andrew Borrego
	Edit Date: 12/13/2018
	

    .EXAMPLE
        Update-MusaPassword -user borregoj 
	    

    .NAME
        Update-MusaPassword
    
    .DESCRIPTION
        Pass in the samaccountname through the user parameter
        Reset AD account password to a randomly generated password
        Prompt user for a password that is eight characters long with one uppercase letter, one lowercase letter, one special character, and one number
  #>

  param
  (
  [parameter(Mandatory=$TRUE, Position=0, ValueFromPipeline=$TRUE)][String] $user
  )

#$theuser = Get-ADUser -Identity $user | select samaccountname
#$samaccount = $theuser.samaccountname
$passlength = Get-random -Minimum 16 -Maximum 30                             # Password has a length that's minimum of 16 characters and a maximum of 30 characters
$pattern = "[" + [regex]::Escape("^~!@#$%^&()-.+=}{\/|;:<>?'*") + "]"        # $pattern is an array used to see if there are any special characters
$check = 0                                                                   # $check is a flag. If the randomly generated password has all conditions met, then the while loop exits


"user is " + $user

while($check -eq 0)
{
    $pass = -join ((33..90) + (97..122) | Get-Random -Count $passlength | % {[char]$_})     #pass has a random amount, $passlength, of ASCII values which are then translated to characters 
    if($pass -match '\d' -and $pass -cmatch “[A-Z]” -and $pass -cmatch “[a-z]” -and $pass -cmatch $pattern){ $check = 1 }
}

#$randomsetpassword = Set-ADAccountPassword -Identity $samaccount -NewPassword $pass –Reset
"Temporary password for user " + $samaccount + " is " +$pass        #displayed so that whomever is resetting the password can give it to the requestor
                                                               
"Create a new password"
"Password must be 8 characters long with one uppercase letter, one lowercase letter, one special character, and one number"
                                                                             
$flag = 0     # $flag is used to verfiy the user generated password has all conditions met before exiting while loop
while($flag -eq 0)
{
    # force the user to create a new password
    $newpass = (Read-Host -Prompt "Provide New Password" -AsSecureString)
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($newpass)
    $UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    if($UnsecurePassword.Length -ge 8 -and $UnsecurePassword -match "[0-9]" -and $UnsecurePassword -cmatch “[A-Z]” -and $UnsecurePassword -cmatch “[a-z]” -and $UnsecurePassword -match $pattern) { $flag = 1 }
    else { "Password must be 8 characters long with one uppercase letter, one lowercase letter, one special character, and one number" }
}
 "user set password is "+ $UnsecurePassword             
 #$set = Set-ADAccountPassword -Identity $samaccount -OldPassword (ConvertTo-SecureString -AsPlainText $pass -Force) -NewPassword (ConvertTo-SecureString -AsPlainText $UnsecurePassword -Force)
}

<#
    Made by Joseph Borrego
    version 1 on 12/13/2018
	
    version 1.1 on 1/2/2019
    - utilized while loops to meet criteria in both random generation and manual entry of password
    - The flags, $check and $flag, are used to make sure the conditions are met before exiting the while loops
    - utilized ASCII values for random password generation
    - The $pattern array contains the special characters that is checked in both loops
    - The user's manual password is revised to be more precise and have certain conditions met

#>