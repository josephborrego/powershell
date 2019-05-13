function new-emailuser{

param( [parameter(Mandatory=$TRUE, Position=0, ValueFromPipeline=$TRUE)][String[]] $user )

#if user > 2 parameters   throw an error
$first = $user[0];
$last = $user[1];
$full ="$first $last"
$lastfour = $last[0..4] 
$lasstfour = -join $lastfour

#---------------------------- create upn ----------------------------
$userupn = $lasstfour + $first[0] + "x"

#get to see if original upn exists
try 
{
    $upncheck = get-aduser -f {UserPrincipalName -eq $userupn}
    $upnhold = $upncheck.UserPrincipalName
    if($upnhold -eq $null){   $up = 0   }
    else{ $up = 1 }
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityResolutionException] { $upnexists = $false }

#if upn exists then create one that doesn't exist
#borrej1, borrej2... 
if($up -eq 1)
{
# CHANGE THIS ONCE IN PRODUCTION to 999 ************************************************************
    for($i = 1; $i -lt 999; $i++)
    {
    $counter = $i
    $holdupn = $lastfour + $first[0] + $i
    $checkhold = -join $holdupn
    $holdupn = $checkhold
    #get to see if the upn exists
        try
        {
            $upncheckfor = get-aduser -f {UserPrincipalName -eq $holdupn}
            $thecheck = $upncheckfor.UserPrincipalName
            $upncheckfor = $thecheck
            if($upncheckfor -eq $null){   $upniteration = 0   }
            else{ $upniteration = 1 }
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityResolutionException] { }           
        #set $exitupn eq 1 if username doesn't work
        if($upniteration -eq 0) 
        {  
            $userupn = $holdupn
            break 
        }
    }
} 
#---------------------------- upn ----------------------------




#---------------------------- create email ----------------------------
$email = "$first.$last@murphyusa.com"
try 
{
    $emailcheck = get-aduser -f {EmailAddress -eq $email} -Properties EmailAddress
    $tempcheck = $emailcheck.EmailAddress
    $emailcheck = $tempcheck

    if($emailcheck -eq $null){   $ex = 0   }
    else{ $ex = 1 }
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityResolutionException] {  $emailexist = $false  }

#if email already exists then create one like
# joseph.borrego1, joseph.borrego2, ...
if($ex -eq 1)
{
    for($j = 1; $j -lt 999; $j++)
    {
    $tempemail = "$first.$last" + "$j" + "@murphyusa.com"
        #see if this email variation exists
        try
        {
            $checkit = get-aduser -f {EmailAddress -eq $tempemail} -Properties EmailAddress
            $tempcheck = $checkit.EmailAddress
            $checkit = $tempcheck

            if($checkit -eq $null) { $exitemail = 1 }
            else { $exitemail = 0  }
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityResolutionException] {  }  
        if($exitemail -eq 1) 
        {
            $version = $j  
            $email = "$first.$last$j@murphyusa.com"
            break 
        }
    }
}
#---------------------------- email ----------------------------

# upn is "borrejx"
# email is "joseph.borrego@murphyusa.com"
# logon name is email
$samname = $userupn

#New-ADUser -Name "$full" -GivenName "$first" -Surname "$last" -SamAccountName "$samname" -UserPrincipalName "$userupn" -Path "OU=Managers,DC=enterprise,DC=com" -AccountPassword(Read-Host -AsSecureString "Input Password") -Enabled $true
$hold = "$full$counter"
$full = $hold

New-ADUser -Name $full -GivenName $first -Surname $last -SamAccountName $samname -UserPrincipalName $userupn #-AccountPassword(Read-Host -AsSecureString "Input Password") -Enabled $true
set-aduser -Identity $userupn -EmailAddress $email


#part 2
New-Item -Path "E:\Scripts\Email"  -Name "MigrationEmails.txt" -ItemType "file" -Value "$userupn"

#part 3
# existing user, but a new email tied to that account
New-MailUser -Name $full -alias $samname -ExternalEmailAddress $email

                         #part 4
Invoke-Command "" -FilePath "E:\Scripts\Mail\Migrate-ADUsers.ps1"

#part 5
#this part waits 30 minutes
$seconds = 1800
$doneDT = (Get-Date).AddSeconds($seconds)
while($doneDT -gt (Get-Date)) 
{
    $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
    $percent = ($seconds - $secondsLeft) / $seconds * 100
    Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining $secondsLeft -PercentComplete $percent
    [System.Threading.Thread]::Sleep(500)
}
Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining 0 -Completed


#-----------------------------------------------------------------
# off premise?????????
# part 6
# Verify the Username is the correct email address:  Firstname.Lastname@murphyusa.com.
# login to office 365 to resume program

$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

# Verify the Username is the correct email address:  Firstname.Lastname@murphyusa.com.
# Remove-PSSession $Session




#part 7
$murphylicenses = @("ENTERPRISEPACKWITHOUTPROPLUS","FORMS_PLAN_E3","Deskless","FLOW_O365_P3","POWERAPPS_O365_P3","TEAMS1","PROJECTWORKMANAGEMENT","INTUNE_O365","SHAREPOINTWAC","SHAREPOINTENTERPRISE","RMS_S_ENTERPRISE","EXCHANGEENTERPRISE")
for($i = 0; $i -lt $yo.Length; $i++)
{
    $a = $murphylicenses[$i]
    $a
}

# license the user with a microsoft license
# Office365 Enterprise E3 without Proplus Licenses
$userUPN="$userupn"
$planName="<license plan name from the list of license plans>"
$License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
$License.SkuId = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value $planName -EQ).SkuID
$LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
$LicensesToAssign.AddLicenses = $License
Set-AzureADUserLicense -ObjectId $userupn -AssignedLicenses $LicensesToAssign




# part 8
# Verify the email address listed for the mailbox is in the format First.Last@murphyusa.com.

$creds = Get-Credential
$sesh = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://musamail5/powershell -Authentication kerberos -Credential $creds
Import-PSSession $sesh

# Verify the email address listed for the mailbox is in the format First.Last@murphyusa.com.
$verify = get-aduser -f {EmailAddress -eq $email} -Properties EmailAddress
$verify
Remove-PSSession $sesh

#-----------------------------------------------------------------


#first go to exchange online
#connectionuri is outlook.office...
# get exchange-guid
#then run onpremise
#login
#enable -archive, get then set remote mailbox

$Shell = $Host.UI.RawUI
$Shell.WindowTitle="Exchange On-Prem"

$creds = Get-Credential
$exch = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://musamail5/powershell -Authentication kerberos -Credential $creds
Import-PSSession $exch
Enable-RemoteMailbox -identity "$useremail" -Archive 
Remove-PSSession $exch

$var = get-mailbox $useremail
$guid = $var.ExchangeGuid

set-remotemailbox "$useremail" -ExchangeGuid $guid

}