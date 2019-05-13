function Update-ADGroupUser
{
<#  

    .SYNOPSIS 

      ADD and/or REMOVE users from active directory groups.

    .DESCRIPTION
        
        This function will take the user input, as a samAccountName and will either add the account to a list of groups, remove listed
        account from a list of groups, or both. This function will receive a pipeline from Get-ADUser or any other function that will
        output an account.

    .INPUTS

    [System.String]

    .OUTPUTS

    [System.String]


    .EXAMPLE

    PS> Update-ADGroupUser -user User1 -add Group1

    ----------------------------------------------

    User1 has been added to CN=Group1,OU=<OU>,DC=domain,dc=local.
	
    .EXAMPLE

    PS> Update-ADGroupUser -user User1 -remove Group1,Group2

    --------------------------------------------------------

    User1 has been removed to CN=Group1,OU=<OU>,DC=domain,dc=local.
    User1 has been removed to CN=Group2,OU=<OU>,DC=domain,dc=local.

	.NOTES
	Title: Update-ADGroupUser
	Author: Joseph Andrew Borrego
	Creation Date: 11/26/2018
	Editor: Shaun L. Jennings
	Edit Date: 12/5/2018
    Version: 3.1.1
	

  #>

    Param(
    #add the get-help section, and make all parameters be able to
    #accept value from pipeline

    [parameter(
        Position=0,
        Mandatory=$true,
        ValueFromPipeline=$True)]
    [String] $User,
    [parameter()][String[]]$Add,
    [parameter()][String[]]$Remove 
    ) 

    # Create a variable and store the user input of the user being configured. - SLJ
    $UserVar = $User

    # Check to see if the user given is a real Murphy USA employee. - SLJ
    Try
    {
        $TheUser = Get-ADUser -identity $UserVar
        $UserVar = $theuser.samAccountName # Converts the object into the samAccountName for use during the rest of the function. - SLJ
    }
    catch
    {
        $ErrorMsg = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Error "Could not find AD group member $TheUser because $ErrorMsg"
    }

    # Add a user ($UserVar) into the listed groups from $Add when the function is called. - SLJ
    foreach($group in $Add)
    {
        Try
        {
            $NewGroup = Get-ADGroup $Group -ErrorAction Stop 
            Add-ADGroupMember -Identity $NewGroup -Members $UserVar -Confirm:$false #adds person to AD group
            Write-Host "$UserVar has been added to $NewGroup." -ForegroundColor Green
        }
        catch 
        {
            $ErrorMsg = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Error "Could not add AD group member $UserVar to $NewGroup because $ErrorMsg"
        }
    }

    # Remove a user ($UserVar) into the listed groups from $Add when the function is called. - SLJ
    foreach($group in $Remove)
    {
        Try
        {
            $OldGroup = get-adgroup $group -ErrorAction Stop 
            Remove-AdGroupMember -Identity $OldGroup -Members $UserVar -Confirm:$false #remove user from the group
            Write-Host "$UserVar has been removed from $OldGroup." -ForegroundColor Green
        }
        catch 
        {
            $ErrorMsg = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Error "Could not remove AD group member $UserVar from $OldGroup because $ErrorMsg" 
        }
    } #end of for-each for group in remove
} #end of function

<#
    Made by Joseph Borrego
    version 3 on 11/28/2018
	
	version 3.1.0 get-adus
	updated get-help part
		added NOTES section
		INPUT to [system.string]
		updated .EXAMPLE
			put in what the output should be
	changed "to" to "from" where the write-error is at on both foreach loop

    Version 3.1.1
    Q.A. of Code - SLJ
    - Added variables to new and remove functions to hide the Get-ADUser output.
    - Changed description to be concise and readable for everyday admins.
    - Cleaned up help file to reflect the changes done.
    - Passed the $user input into a variable to be used in the script.
    - Added outputs of success results for each add and remove within the foreach loops.
    - Added color outputs for better readability of success.
    - Removed confirmation of execution of the Add and Remove from group.

#>