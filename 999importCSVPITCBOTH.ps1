
<# Source CSV File 
Authors : Tawanda Dadirai & Blessing Tsenesa
Company : Biomedical Research & Training Institute

IMPORT Clinical PITC Data  : clinicalpitc_7

Function : 
1. Takes raw CSV and processes to a formatted CSV
2. Inserts the data into Local Database Server
3. Inserts same data into Cloud Database
4. Create folder with todays date and backs up the Initial Data Source CSV into 
4. Create folder with todays date and backs up the Formatted CSV into Export Folder

 #>

<#Variable Declaration Section#>

# Working Folders & Files Declaration
$SourceCSVFile = 'C:\DATA\Briefcase\BriefcaseDownloads\Clinical_PITC.csv'
$FormattedCSVFile = 'C:\DATA\Briefcase\Formatted\clinicalpitc_7.csv'
$RawBackupFolder = 'C:\DATA\Briefcase\Backup\Raw\pitc\'
$FormattedBackupFolder = 'C:\DATA\Briefcase\Backup\Formatted\pitc\'
$LogFileFolder = 'C:\DATA\Briefcase\Log\'


#Local Database Connection
$LocalSQLServerInstance = '.\SQLEXPRESS'
$LocalDatabaseName = 'YZUHP'
$LocalDatabaseUser = 'sa'
$LocalDatabasePWD = 'Adm!n123'

#Cloud Database Connection Settings
$CloudSQLServerInstance = 
$CloudDatabaseName =
$CloudDatabaseUser = 
$CloudDatabasePWD =

# Database Table. Has to be identical table in both Databases
$DatabaseTable = 'clinicalpitc_7'


# Lets create a Log file to log the events that will be happening today. Generate log file with current date.
$date = Get-Date -UFormat "%Y%m%d"
$LogFile = $LogFileFolder+'log-'+$date+'-clinical.log'



# Backup folder name
$BackupFolderName = 'bck'+$date


<# END OF VARIABLE DECLARATION. LETS DO SOME WORK #>

<################################# LOGGING FUNCTION ##############################################################>



function Write-Log 
{ 
    [CmdletBinding()] 
    Param 
    ( 
        [Parameter(Mandatory=$true, 
                   ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()] 
        [Alias("LogContent")] 
        [string]$Message, 
 
        [Parameter(Mandatory=$false)] 
        [Alias('LogPath')] 
        [string]$Path='$LogFile', 
         
        [Parameter(Mandatory=$false)] 
        [ValidateSet("Error","Warn","Info")] 
        [string]$Level="Info", 
         
        [Parameter(Mandatory=$false)] 
        [switch]$NoClobber 
    ) 
 
    Begin 
    { 
        # Set VerbosePreference to Continue so that verbose messages are displayed. 
        $VerbosePreference = 'Continue' 
    } 
    Process 
    { 
         
        # If the file already exists and NoClobber was specified, do not write to the log. 
        if ((Test-Path $Path) -AND $NoClobber) { 
            Write-Error "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name." 
            Return 
            } 
 
        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path. 
        elseif (!(Test-Path $Path)) { 
            Write-Verbose "Creating $Path." 
            $NewLogFile = New-Item $Path -Force -ItemType File 
            } 
 
        else { 
            # Lets remove the file
            # Remove-Item -Path $Path -Force
            } 
 
        # Format Date for our Log File 
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss" 
 
        # Write message to error, warning, or verbose pipeline and specify $LevelText 
        switch ($Level) { 
            'Error' { 
                Write-Error $Message 
                $LevelText = 'ERROR:' 
                } 
            'Warn' { 
                Write-Warning $Message 
                $LevelText = 'WARNING:' 
                } 
            'Info' { 
                Write-Verbose $Message 
                $LevelText = 'INFO:' 
                } 
            } 
         
        # Write log entry to $Path 
        "$FormattedDate $LevelText $Message" | Out-File -FilePath $Path -Append 
    } 
    End 
    { 
    } 
}

<################################# END OF LOGGING FUNCTION ##############################################################>


clear
$Time=Get-Date
Write-Log "The backup process started at $Time" -Path $LogFile -Level Info






#Lets import the CSV file
Try
 {
 Import-CSV $SourceCSVFile -ErrorAction Stop |

 <# Columns in CSV to import and rename them just like the final Database Tables  #>
Select  -Property  @{Name="SubmissionDate";Expression={$_."SubmissionDate"}},
  				   @{Name="starttime";Expression={$_."starttime"}},
                   @{Name="endtime";Expression={$_."endtime"}},
                   @{Name="deviceid";Expression={$_."deviceid"}} ,
                   @{Name="simid";Expression={$_."simid"}} ,
                   @{Name="devicephonenumber";Expression={$_."devicephonenumber"}},
                   @{Name="now_string";Expression={$_."now_string"}} ,
                   @{Name="interviewer";Expression={$_."interviewer"}},
                   @{Name="interviewer_other";Expression={$_."interviewer_other"}},
                   @{Name="site";Expression={$_."site"}},
                   @{Name="hhid_7";Expression={$_."memberdetails-hhid_7"}},
                   @{Name="line_7";Expression={$_."memberdetails-line_7"}},
                   @{Name="cluster_7";Expression={$_."cluster_7"}},
                   @{Name="hhkey";Expression={$_."hhkey"}},
                   @{Name="hhmem_key_7";Expression={$_."hhmem_key_7"}},
                   @{Name="accept_hts";Expression={$_."accept_hts"}},
                   @{Name="other_reason";Expression={$_."other_reason"}},
                   @{Name="taking_art_7";Expression={$_."taking_art_7"}},
                   @{Name="result_confirmation";Expression={$_."result_confirmation"}},
                    @{Name="datepositivetest";Expression={$_."datepositivetest"}},
                   @{Name="hts_date_7";Expression={$_."AcceptedTest-hts_date_7"}},
                   @{Name="hts_number_7";Expression={$_."AcceptedTest-hts_number_7"}},
                   @{Name="part_surname";Expression={$_."AcceptedTest-partdetails-part_surname"}},
                   @{Name="part_fnames";Expression={$_."AcceptedTest-partdetails-part_fnames"}},
                   @{Name="part_address";Expression={$_."AcceptedTest-partdetails-part_address"}},
                   @{Name="part_contact_number";Expression={$_."AcceptedTest-partdetails-part_contact_number"}},
                   @{Name="gender_7";Expression={$_."AcceptedTest-gender_7"}},
                   @{Name="part_dob";Expression={$_."AcceptedTest-part_dob"}},
                   @{Name="age_7";Expression={$_."AcceptedTest-age_7"}},
                   @{Name="hts_couple";Expression={$_."AcceptedTest-hts_couple"}},
                   @{Name="hts_reason";Expression={$_."AcceptedTest-hts_reason"}},
                   @{Name="hts_test_times";Expression={$_."AcceptedTest-hts_test_times"}},
                   @{Name="consent_completed";Expression={$_."AcceptedTest-consent_completed"}},
                   @{Name="preg_lact";Expression={$_."AcceptedTest-preg_lact"}},
                   @{Name="first_retest";Expression={$_."AcceptedTest-first_retest"}},
                   @{Name="hts1kit";Expression={$_."AcceptedTest-hts1-hts1kit"}},
                   @{Name="hts1kitexpirydate";Expression={$_."AcceptedTest-hts1-hts1kitexpirydate"}},
                   @{Name="hts1kitlotnum";Expression={$_."AcceptedTest-hts1-hts1kitlotnum"}},
                   @{Name="hts1result";Expression={$_."AcceptedTest-hts1-hts1result"}},
                   @{Name="hts2kit";Expression={$_."AcceptedTest-hts2-hts2kit"}},
                   @{Name="hts2kitexpirydate";Expression={$_."AcceptedTest-hts2-hts2kitexpirydate"}},
                   @{Name="hts2kitlotnum";Expression={$_."AcceptedTest-hts2-hts2kitlotnum"}},
                   @{Name="hts2result";Expression={$_."AcceptedTest-hts2-hts2result"}},
                   @{Name="htspar1kit";Expression={$_."AcceptedTest-htspar1-htspar1kit"}},
                   @{Name="htspar1expirydate";Expression={$_."AcceptedTest-htspar1-htspar1expirydate"}},
                   @{Name="htspar1kitlotnum";Expression={$_."AcceptedTest-htspar1-htspar1kitlotnum"}},
                   @{Name="htspar1result";Expression={$_."AcceptedTest-htspar1-htspar1result"}},
                   @{Name="htspar2kit";Expression={$_."AcceptedTest-htspar2-htspar2kit"}},
                   @{Name="htspar2expirydate";Expression={$_."AcceptedTest-htspar2-htspar2expirydate"}},
                   @{Name="htspar2kitlotnum";Expression={$_."AcceptedTest-htspar2-htspar2kitlotnum"}},
                   @{Name="htspar2result";Expression={$_."AcceptedTest-htspar2-htspar2result"}},
                   @{Name="resultdiscord";Expression={$_."AcceptedTest-resultdiscord"}},
                   @{Name="hts3kit";Expression={$_."AcceptedTest-hts3-hts3kit"}},
                   @{Name="hts3kitexpirydate";Expression={$_."AcceptedTest-hts3-hts3kitexpirydate"}},
                   @{Name="hts3kitlotnum";Expression={$_."AcceptedTest-hts3-hts3kitlotnum"}},
                   @{Name="hts3result";Expression={$_."AcceptedTest-hts3-hts3result"}},
                   @{Name="htsfinalresult";Expression={$_."AcceptedTest-htsfinalresult"}},
                   @{Name="htsfinalresultinconclusive";Expression={$_."AcceptedTest-htsfinalresultinconclusive"}},
                   @{Name="rand_dice";Expression={$_."AcceptedTest-rand_dice"}},
                   @{Name="eligible_vmmc";Expression={$_."AcceptedTest-eligible_vmmc"}},
                   @{Name="eligible_prep";Expression={$_."AcceptedTest-eligible_prep"}},
                   @{Name="inconclusive";Expression={$_."AcceptedTest-inconclusive"}},
                   @{Name="inviteart";Expression={$_."AcceptedTest-inviteart"}},
                   @{Name="invitevmmc";Expression={$_."AcceptedTest-invitevmmc"}},
                   @{Name="inviteprep";Expression={$_."AcceptedTest-inviteprep"}},
                   @{Name="appntmt_7";Expression={$_."AcceptedTest-appntmt_7"}},
                   @{Name="refusedpitc";Expression={$_."refusedpitc"}},
                   @{Name="completed";Expression={$_."completed"}},
                   @{Name="meta_instanceID";Expression={$_."meta-instanceID"}},
                   @{Name="knownstatus";Expression={$_."knownstatus"}},
                   @{Name="circumcisedorprep";Expression={$_."AcceptedTest-circumcisedorprep"}},
                   @{Name="circumprepvenue";Expression={$_."AcceptedTest-circumprepvenue"}},
                   @{Name="posttestlink";Expression={$_."AcceptedTest-posttestlink"}},
                   @{Name="posttestlink_other";Expression={$_."AcceptedTest-posttestlink_other"}},
                   
                   @{Name="METAKEY";Expression={$_."KEY"}}|       
                          

<# Now Lets export the data to a more friendly formatted CSV #>
Export-Csv -Path $FormattedCSVFile -NoTypeInformation
$InfoMessage =  "Format Raw CSV file  $SourceCSVFile to $FormattedCSVFile completed."
Write-Log -Message $InfoMessage -Path $LogFile -Level Info

# Now lets import the CSV we have formmated  to the more friendly format. This is the data that will eventually get into the database
$data = import-csv $FormattedCSVFile -ErrorAction Stop
$InfoMessage = "Importing formatted CSV file $FormattedCSVFile." 
Write-Log -Message $InfoMessage -Path $LogFile -Level Info
$InfoMessage = "Starting upload of data to the LOCAL Database" 
Write-Log -Message $InfoMessage -Path $LogFile -Level Info

 }
 Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    
    Write-Log -Message $ErrorMessage -Path $LogFile -Level Error
}
 # END TRY






 <#########################   IMPORT PROCESS INTO THE LOCAL DATABASE ############################################################>


 Try
 {
 # Now lets process the CSV
 
$count = 1 
 
foreach($i in $data){ 
 
$SubmissionDate = $i.SubmissionDate
$starttime = $i.starttime 
$endtime = $i.endtime 
$deviceid = $i.deviceid 
$simid = $i.simid  
$devicephonenumber = $i.devicephonenumber 
$now_string = $i.now_string
$interviewer = $i.interviewer
$interviewer_other = $i.interviewer_other.replace("'","")
$site = $i.site
$hhid_7 = $i.hhid_7
$line_7 = $i.line_7
$cluster_7 = $i.cluster_7
$hhkey = $i.hhkey
$hhmem_key_7 = $i.hhmem_key_7
$accept_hts = $i.accept_hts
$other_reason = $i.other_reason.replace("'","")
$taking_art_7 = $i.taking_art_7
$result_confirmation = $i.result_confirmation
$datepositivetest=$i.datepositivetest
$hts_date_7 = $i.hts_date_7
$hts_number_7 = $i.hts_number_7

$gender_7 = $i.gender_7
$part_dob = $i.part_dob
$age_7 = $i.age_7
$hts_couple = $i.hts_couple
$hts_reason = $i.hts_reason
$hts_test_times = $i.hts_test_times
$consent_completed = $i.consent_completed
$hts1kit = $i.hts1kit
$hts1kitexpirydate = $i.hts1kitexpirydate
$hts1kitlotnum = $i.hts1kitlotnum
$hts1result = $i.hts1result
$hts2kit = $i.hts2kit
$hts2kitexpirydate = $i.hts2kitexpirydate
$hts2kitlotnum = $i.hts2kitlotnum
$hts2result = $i.hts2result
$htspar1kit = $i.htspar1kit
$htspar1expirydate = $i.htspar1expirydate
$htspar1kitlotnum = $i.htspar1kitlotnum
$htspar1result = $i.htspar1result
$htspar2kit = $i.htspar2kit
$htspar2expirydate = $i.htspar2expirydate
$htspar2kitlotnum = $i.htspar2kitlotnum
$htspar2result = $i.htspar2result
$resultdiscord = $i.resultdiscord
$hts3kit = $i.hts3kit
$hts3kitexpirydate = $i.hts3kitexpirydate
$hts3kitlotnum = $i.hts3kitlotnum
$hts3result = $i.hts3result
$htsfinalresult = $i.htsfinalresult
$htsfinalresultinconclusive = $i.htsfinalresultinconclusive
$rand_dice = $i.rand_dice
$eligible_vmmc = $i.eligible_vmmc
$eligible_prep = $i.eligible_prep
$inconclusive = $i.inconclusive
$inviteart = $i.inviteart
$invitevmmc = $i.invitevmmc
$inviteprep = $i.inviteprep
$appntmt_7 = $i.appntmt_7
$refusedpitc = $i.refusedpitc
$completed = $i.completed
$meta_instanceID = $i.meta_instanceID
$METAKEY = $i.METAKEY
$knownstatus = $i.knownstatus
$circumcisedorprep = $i.circumcisedorprep
$circumprepvenue = $i.circumprepvenue.replace("'","")
$first_retest = $i.first_retest
$preg_lact = $i.preg_lact
$posttestlink = $i.posttestlink
$posttestlink_other = $i.posttestlink_other

 
$SQLQuery = "INSERT INTO clinicalpitc_7 (SubmissionDate,starttime ,endtime,deviceid,simid ,devicephonenumber,now_string,interviewer,interviewer_other,site,hhid_7,line_7 ,cluster_7,hhkey,hhmem_key_7,accept_hts
      ,other_reason ,taking_art_7 ,result_confirmation ,hts_date_7,hts_number_7,gender_7,part_dob,age_7
      ,hts_couple,hts_reason,hts_test_times ,consent_completed ,hts1kit,hts1kitexpirydate ,hts1kitlotnum,hts1result,hts2kit,hts2kitexpirydate,hts2kitlotnum,hts2result
      ,htspar1kit,htspar1expirydate ,htspar1kitlotnum ,htspar1result ,htspar2kit ,htspar2expirydate ,htspar2kitlotnum ,htspar2result ,resultdiscord ,hts3kit
      ,hts3kitexpirydate ,hts3kitlotnum ,hts3result ,htsfinalresult ,htsfinalresultinconclusive ,rand_dice, eligible_vmmc, eligible_prep
      ,inconclusive ,inviteart ,invitevmmc,inviteprep ,appntmt_7 ,refusedpitc,completed,meta_instanceID,METAKEY,knownstatus,circumcisedorprep,circumprepvenue,first_retest, preg_lact, posttestlink, posttestlink_other,datepositivetest) 
       
       VALUES ('$SubmissionDate','$starttime','$endtime','$deviceid','$simid','$devicephonenumber','$now_string','$interviewer','$interviewer_other','$site','$hhid_7','$line_7','$cluster_7',
      '$hhkey','$hhmem_key_7','$accept_hts','$other_reason','$taking_art_7','$result_confirmation','$hts_date_7','$hts_number_7','$gender_7','$part_dob','$age_7','$hts_couple','$hts_reason','$hts_test_times','$consent_completed','$hts1kit','$hts1kitexpirydate','$hts1kitlotnum',
      '$hts1result','$hts2kit','$hts2kitexpirydate','$hts2kitlotnum','$hts2result','$htspar1kit','$htspar1expirydate','$htspar1kitlotnum','$htspar1result','$htspar2kit','$htspar2expirydate',
      '$htspar2kitlotnum','$htspar2result','$resultdiscord','$hts3kit','$hts3kitexpirydate','$hts3kitlotnum','$hts3result','$htsfinalresult','$htsfinalresultinconclusive','$rand_dice',
      '$eligible_vmmc','$eligible_prep','$inconclusive','$inviteart','$invitevmmc','$inviteprep','$appntmt_7','$refusedpitc','$completed','$meta_instanceID','$METAKEY','$knownstatus','$circumcisedorprep','$circumprepvenue','$first_retest', '$preg_lact', '$posttestlink', '$posttestlink_other','$datepositivetest')" 
 


 $impcsv = invoke-sqlcmd -Username $LocalDatabaseUser -Password $LocalDatabasePWD -Database $LocalDatabaseName -Query $SQLQuery  -serverinstance $LocalSQLServerInstance  
        $InfoMessage = "Household ID $hhkey successfully uploaded to YZ-UHP Local MSSSQL Server."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 
 $InfoMessage = "Successfully imported $count PITC  Qstns into the YZ-UHP database" 
 Write-Log -Message $InfoMessage -Path $LogFile   -Level Info

}

Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    
    Write-Log -Message "System encountered an error trying to post into the local database. System returned error : $ErrorMessage" -Path $LogFile -Level Error
}



Try
{

<#   ############################## UPLOADING PITC IDENTIFIERS TO LOCAL DATABASE #####################################################>
# Now lets import the CSV we have formmated  to the more friendly format. This is the data that will eventually get into the database
$data = import-csv $FormattedCSVFile -ErrorAction Stop
$InfoMessage = "Starting upload of data to the Cloud Database" 
Write-Log -Message $InfoMessage -Path $LogFile -Level Info

 # Now lets process the CSV


 $count = 0 
 
foreach($i in $data){
 

$starttime = $i.starttime 
$accept_hts = $i.accept_hts
$part_surname = $i.part_surname.replace("'","")
$part_fnames = $i.part_fnames.replace("'","")
$METAKEY = $i.METAKEY
$part_address = $i.part_address.replace("'","")
$part_contact_number = $i.part_contact_number


 
$SQLQuery = "INSERT INTO pitcnames (pitcdate ,consent, part_surname ,part_fnames ,METAKEY,part_address,part_contact_number) 
       
       VALUES ('$starttime','$accept_hts','$part_surname','$part_fnames','$METAKEY','$part_address','$part_contact_number')"        
       
       #LOCAL DATABASE CONNECTION
       $impcsv = invoke-sqlcmd -Username $LocalDatabaseUser -Password $LocalDatabasePWD -Database $LocalDatabaseName -Query $SQLQuery  -serverinstance $LocalSQLServerInstance  
        $InfoMessage = "Household ID $hhkey successfully uploaded to YZ-UHP Local MSSSQL Server."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 


 $InfoMessage = "Successfully imported $count PITC Identifers into the YZ-UHP CLOUD database" 
 Write-Log -Message $InfoMessage -Path $LogFile   -Level Info

 

$InfoMessage = "PITC Data Processing successfully completed"
}



Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    
    Write-Log -Message "Error : Upload to Cloud database failed with the error : $ErrorMessage" -Path $LogFile -Level Error
}



Try
{

<#   ############################## UPLOADING TO THE CLOUD DATABASE #####################################################>
# Now lets import the CSV we have formmated  to the more friendly format. This is the data that will eventually get into the database
$data = import-csv $FormattedCSVFile -ErrorAction Stop
$InfoMessage = "Starting upload of data to the Cloud Database" 
Write-Log -Message $InfoMessage -Path $LogFile -Level Info

 # Now lets process the CSV


 $count = 1 
 
foreach($i in $data){ 
 
$SubmissionDate = $i.SubmissionDate
$starttime = $i.starttime 
$endtime = $i.endtime 
$deviceid = $i.deviceid 
$simid = $i.simid  
$devicephonenumber = $i.devicephonenumber 
$now_string = $i.now_string
$interviewer = $i.interviewer
$interviewer_other = $i.interviewer_other.replace("'","")
$site = $i.site
$hhid_7 = $i.hhid_7
$line_7 = $i.line_7
$cluster_7 = $i.cluster_7
$hhkey = $i.hhkey
$hhmem_key_7 = $i.hhmem_key_7
$accept_hts = $i.accept_hts
$other_reason = $i.other_reason.replace("'","")
$taking_art_7 = $i.taking_art_7
$result_confirmation = $i.result_confirmation
$datepositivetest=$i.datepositivetest
$hts_date_7 = $i.hts_date_7
$hts_number_7 = $i.hts_number_7
$gender_7 = $i.gender_7
$part_dob = $i.part_dob
$age_7 = $i.age_7
$hts_couple = $i.hts_couple
$hts_reason = $i.hts_reason
$hts_test_times = $i.hts_test_times
$consent_completed = $i.consent_completed
$hts1kit = $i.hts1kit
$hts1kitexpirydate = $i.hts1kitexpirydate
$hts1kitlotnum = $i.hts1kitlotnum
$hts1result = $i.hts1result
$hts2kit = $i.hts2kit
$hts2kitexpirydate = $i.hts2kitexpirydate
$hts2kitlotnum = $i.hts2kitlotnum
$hts2result = $i.hts2result
$htspar1kit = $i.htspar1kit
$htspar1expirydate = $i.htspar1expirydate
$htspar1kitlotnum = $i.htspar1kitlotnum
$htspar1result = $i.htspar1result
$htspar2kit = $i.htspar2kit
$htspar2expirydate = $i.htspar2expirydate
$htspar2kitlotnum = $i.htspar2kitlotnum
$htspar2result = $i.htspar2result
$resultdiscord = $i.resultdiscord
$hts3kit = $i.hts3kit
$hts3kitexpirydate = $i.hts3kitexpirydate
$hts3kitlotnum = $i.hts3kitlotnum
$hts3result = $i.hts3result
$htsfinalresult = $i.htsfinalresult
$htsfinalresultinconclusive = $i.htsfinalresultinconclusive
$rand_dice = $i.rand_dice
$eligible_vmmc = $i.eligible_vmmc
$eligible_prep = $i.eligible_prep
$inconclusive = $i.inconclusive
$inviteart = $i.inviteart
$invitevmmc = $i.invitevmmc
$inviteprep = $i.inviteprep
$appntmt_7 = $i.appntmt_7
$refusedpitc = $i.refusedpitc
$completed = $i.completed
$meta_instanceID = $i.meta_instanceID
$METAKEY = $i.METAKEY
$knownstatus = $i.knownstatus
$circumcisedorprep = $i.circumcisedorprep
$circumprepvenue = $i.circumprepvenue.replace("'","")
$first_retest = $i.first_retest
$preg_lact = $i.preg_lact
$posttestlink = $i.posttestlink
$posttestlink_other = $i.posttestlink_other

 
$SQLQuery = "INSERT INTO clinicalpitc_7 (SubmissionDate,starttime ,endtime,deviceid,simid ,devicephonenumber,now_string,interviewer,interviewer_other,site,hhid_7,line_7 ,cluster_7,hhkey,hhmem_key_7,accept_hts
      ,other_reason ,taking_art_7 ,result_confirmation ,hts_date_7,hts_number_7,gender_7,part_dob,age_7
      ,hts_couple,hts_reason,hts_test_times ,consent_completed ,hts1kit,hts1kitexpirydate ,hts1kitlotnum,hts1result,hts2kit,hts2kitexpirydate,hts2kitlotnum,hts2result
      ,htspar1kit,htspar1expirydate ,htspar1kitlotnum ,htspar1result ,htspar2kit ,htspar2expirydate ,htspar2kitlotnum ,htspar2result ,resultdiscord ,hts3kit
      ,hts3kitexpirydate ,hts3kitlotnum ,hts3result ,htsfinalresult ,htsfinalresultinconclusive ,rand_dice, eligible_vmmc, eligible_prep
      ,inconclusive ,inviteart ,invitevmmc,inviteprep ,appntmt_7 ,refusedpitc,completed,meta_instanceID,METAKEY,knownstatus,circumcisedorprep,circumprepvenue,first_retest, preg_lact, posttestlink, posttestlink_other,datepositivetest) 
       
       VALUES ('$SubmissionDate','$starttime','$endtime','$deviceid','$simid','$devicephonenumber','$now_string','$interviewer','$interviewer_other','$site','$hhid_7','$line_7','$cluster_7',
      '$hhkey','$hhmem_key_7','$accept_hts','$other_reason','$taking_art_7','$result_confirmation','$hts_date_7','$hts_number_7','$gender_7','$part_dob','$age_7','$hts_couple','$hts_reason','$hts_test_times','$consent_completed','$hts1kit','$hts1kitexpirydate','$hts1kitlotnum',
      '$hts1result','$hts2kit','$hts2kitexpirydate','$hts2kitlotnum','$hts2result','$htspar1kit','$htspar1expirydate','$htspar1kitlotnum','$htspar1result','$htspar2kit','$htspar2expirydate',
      '$htspar2kitlotnum','$htspar2result','$resultdiscord','$hts3kit','$hts3kitexpirydate','$hts3kitlotnum','$hts3result','$htsfinalresult','$htsfinalresultinconclusive','$rand_dice',
      '$eligible_vmmc','$eligible_prep','$inconclusive','$inviteart','$invitevmmc','$inviteprep','$appntmt_7','$refusedpitc','$completed','$meta_instanceID','$METAKEY','$knownstatus','$circumcisedorprep',
      '$circumprepvenue','$first_retest', '$preg_lact', '$posttestlink', '$posttestlink_other','$datepositivetest')" 
 

       
       
       
       # Cloud Database Settings
        $impcsv = invoke-sqlcmd -Username $CloudDatabaseUser -Password $CloudDatabasePWD -Database $CloudDatabaseName -Query $SQLQuery  -serverinstance $CloudSQLServerInstance  
        $InfoMessage = "Household ID $hhkey successfully uploaded to Cloud YZ-UHP database on SmarterASP."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 


 $InfoMessage = "Successfully imported $count pitc Qstns into the YZ-UHP CLOUD database" 
 Write-Log -Message $InfoMessage -Path $LogFile   -Level Info

 

$InfoMessage = "Qstns Data upload completed"
}



Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    
    Write-Log -Message "Error : Upload to Cloud database failed with the error : $ErrorMessage" -Path $LogFile -Level Error
}

Try
{

<#   ############################## UPLOADING PITC IDENTIFIERS TO CLOUD DATABASE #####################################################>
# Now lets import the CSV we have formmated  to the more friendly format. This is the data that will eventually get into the database
$data = import-csv $FormattedCSVFile -ErrorAction Stop
$InfoMessage = "Starting upload of data to the Cloud Database" 
Write-Log -Message $InfoMessage -Path $LogFile -Level Info

 # Now lets process the CSV


 $count = 0 
 
foreach($i in $data){
 

$starttime = $i.starttime 
$accept_hts = $i.accept_hts
$part_surname = $i.part_surname.replace("'","")
$part_fnames = $i.part_fnames.replace("'","")
$METAKEY = $i.METAKEY
$part_address = $i.part_address.replace("'","")
$part_contact_number = $i.part_contact_number
 
 
$SQLQuery = "INSERT INTO pitcnames (pitcdate ,consent, part_surname ,part_fnames ,METAKEY,part_address,part_contact_number) 
       
       VALUES ('$starttime','$accept_hts','$part_surname','$part_fnames','$METAKEY','$part_address','$part_contact_number')"        
       
       
       # Cloud Database Settings
        $impcsv = invoke-sqlcmd -Username $CloudDatabaseUser -Password $CloudDatabasePWD -Database $CloudDatabaseName -Query $SQLQuery  -serverinstance $CloudSQLServerInstance  
        $InfoMessage = "$METAKEY successfully processed to Cloud YZ-UHP database on SmarterASP."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 


 $InfoMessage = "Successfully imported $count PITC Identifers into the YZ-UHP CLOUD database" 
 Write-Log -Message $InfoMessage -Path $LogFile   -Level Info

 

$InfoMessage = "PITC Data Processing successfully completed"
}



Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    
    Write-Log -Message "Error : Upload to Cloud database failed with the error : $ErrorMessage" -Path $LogFile -Level Error
}





Finally
{   
    <# LETS DO SOME MAINTENANCE ON THE FILES #>

     # Lets backup the raw files. 
     $RawBackupFolderPath = $RawBackupFolder+$BackupFolderName

     # If the RAW BACKUP FOLDER already exists then do not attempt to create another one. 
     if (!(Test-Path $RawBackupFolderPath)) { 
        Write-Verbose "Creating $RawBackupFolderPath." 
        New-Item -ItemType directory -Path $RawBackupFolderPath 
     }

     move-item -path $SourceCSVFile -destination $RawBackupFolderPath
     $InfoMessage = "Backed up ODK Aggregate raw CSV file $SourceCSVFile to backup folder $RawBackupFolderPath " 
     Write-Log -Message $InfoMessage -Path $LogFile -Level Info
     # Lets Backup the formatted files
     $FormattedBackupFolderPath = $FormattedBackupFolder+$BackupFolderName
     if (!(Test-Path $FormattedBackupFolderPath)) { 
       Write-Verbose "Creating $FormattedBackupFolderPath." 
       New-Item -ItemType directory -Path $FormattedBackupFolderPath 
     }

     move-item -path $FormattedCSVFile -destination $FormattedBackupFolderPath
     $InfoMessage = "Backed up formatted CSV file $FormattedCSVFile to backup folder $FormattedBackupFolderPath " 
     Write-Log -Message $InfoMessage -Path $LogFile -Level Info
     $Time=Get-Date
     Write-Log "The process ended at $Time" -Path $LogFile -Level Info
    
    #Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential (Get-Credential) -Attachments $Attachment DeliveryNotificationOption OnSuccess
}
