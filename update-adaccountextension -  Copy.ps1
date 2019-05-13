function Update-ADAccountExtension
{
<#  

    .SYNOPSIS 

      extend the account expiration date, three months by default, or specified amount.

    .INPUTS

    [System.String]

    .OUTPUTS

    [System.String]
	
	.NOTES
	Title: Update-ADAccountExtension
	Author: Joseph Andrew Borrego
	Creation Date: 12/12/2018
	Editor: Joseph Andrew Borrego
	Edit Date: 1/3/2019
	

    .EXAMPLE

    Update-ADAccountExtension -user adam 
	    # will automatically add 3 months if user does not specify the -add parameter
        # first case

    .EXAMPLE

    Update-ADAccountExtension -user adam, bob, clay
        # will automatically add 3 months to adam, bob, clay
        # second case

    .EXAMPLE
    Update-ADAccountExtension -user adam, bob, clay -add 1, 2, 3
        # adam = 1 months added    bob = 2 months added     carl = 3 months added
        # third case
	
    .NAME
        Update-ADAccountExtension
    
    .DESCRIPTION
        this function will take a user(s), samAccountName, and add an amount, in months, to extend their AD account expiration.
        if the add parameter is empty then set that person(s) AD account expiration is extended three months
        The function also extends a user(s) AD account expiration with an amount specified by the -add parameter.
  #>

  param
  (
  [parameter(Mandatory=$TRUE, Position=0, ValueFromPipeline=$TRUE)][String[]] $user,
  [parameter()][int[]] $add  # makes sure that all values in the -add array are numbers
  )
 
$check = 0                   # $check is a flag to check if any of the three cases were successful       
$date = get-date

#if the -add parameter is empty    
if($add.length -eq 0)        
{
    $addedtime = $date.AddMonths(3)   # default of 3 months is kept if you have multiple inputs without numbers

    # the first case for one user in the -user parameter       
    if($user.Length -eq 1)
    {
        [String]$getuser = $user
	    $theuser = get-aduser -Identity $getuser | select samaccountname
        $samaccount = $theuser.samaccountname           
	    $setadexpiration = Set-ADAccountExpiration -identity $samaccount -DateTime $addedtime
        $check = 1
    }

    # the second case if multiple people are in the -user parameter
    if($user.Length -gt 1)   
    {   
        for($i = 0; $i -lt $user.Length; $i++)           
	    {
            $getuser = [String]$user[$i]                # get one samaccount at a time of the multiple inputs
    	    $theuser = get-aduser -Identity $getuser | select samaccountname
            $samaccount = $theuser.samaccountname     
    	    $setadexpiration = Set-ADAccountExpiration -Identity $samaccount -DateTime $addedtime
        }
        $check = 1
    }
}

#third case, custom number of samaccount(s) and month(s)    
if($user.Length -eq $add.Length)  # verifies months will add up with the corresponding samAccountName
{
    for($i = 0; $i -lt $user.Length; $i++)
    {
        $getuser = [String]$user[$i]
		$theuser = get-aduser -Identity $getuser | select samaccountname
        $samaccount = $theuser.samaccountname
		$addedtime = $date.AddMonths($add[$i])
		$setadexpiration = Set-ADAccountExpiration -Identity $samaccount -DateTime $addedtime
    }
    $check = 1
}

# the case for if the parameters, -user & -add, are not equal to each other and the $check flag has not been adjusted  
if(($user.Length) -ne ($add.Length) -and $check -eq 0) { Write-Error "User input and add input do not match, try again" }  
   
} 

<#
    Made by Joseph Borrego
    version 1 on 12/21/2018
	
    version 1.1 on 1/3/2019
    - utilized for loops, because the users are in sequential order
    - added $check for the case that the user input is wrong
    - made the case for multiple people with blank #add
    - made sure that the default of 3 months is kept if you have multiple inputs without numbers
    - verified that the months will add up with the corresponding samAccountName
#>