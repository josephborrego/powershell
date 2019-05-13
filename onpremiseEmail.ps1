function new-emailuser{

param( [parameter(Mandatory=$TRUE, Position=0, ValueFromPipeline=$TRUE)][String[]] $user )

#if $user > 2 parameters   throw an error
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
#$email 
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
        #get to see if the email exists
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

#upn is "borrejx"
#email is "joseph.borrego@murphyusa.com"
#logon name is email
$samname = $userupn

#New-ADUser -Name "$full" -GivenName "$first" -Surname "$last" -SamAccountName "$samname" -UserPrincipalName "$userupn" -Path "OU=Managers,DC=enterprise,DC=com" -AccountPassword(Read-Host -AsSecureString "Input Password") -Enabled $true
$hold = "$full$counter"
$full = $hold

New-ADUser -Name $full -GivenName $first -Surname $last -SamAccountName $samname -UserPrincipalName $userupn #-AccountPassword(Read-Host -AsSecureString "Input Password") -Enabled $true
set-aduser -Identity $userupn -EmailAddress $email
}