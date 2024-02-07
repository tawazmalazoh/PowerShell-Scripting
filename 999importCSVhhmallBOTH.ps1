
<# Source CSV File 
Authors : Tawanda Dadirai & Blessing Tsenesa
Company : Biomedical Research & Training Institute

IMPORT Household Questionnaire Data  : hhident_7

Function : 
1. Takes raw CSV and processes to a formatted CSV
2. Inserts the data into Local Database Server
3. Inserts same data into Cloud Database
4. Create folder with todays date and backs up the Initial Data Source CSV into 
4. Create folder with todays date and backs up the Formatted CSV into Export Folder

 #>

<#Variable Declaration Section#>

# Working Folders & Files Declaration
$SourceCSVFile = 'C:\DATA\Briefcase\BriefcaseDownloads\Household_Questionnaire-hhmember.csv'
$FormattedCSVFile = 'C:\DATA\Briefcase\Formatted\hhmall_7.csv'
$RawBackupFolder = 'C:\DATA\Briefcase\Backup\Raw\hh\'
$FormattedBackupFolder = 'C:\DATA\Briefcase\Backup\Formatted\hh\'
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
$DatabaseTable = 'hhmall_7'


# Lets create a Log file to log the events that will be happening today. Generate log file with current date.
$date = Get-Date -UFormat "%Y%m%d"
$LogFile = $LogFileFolder+'log-'+$date+'-hhmall_7.log'



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
Select  -Property   @{Name="id";Expression={$_."id"}},
      @{Name="hhkey";Expression={$_."mem_hhkey"}},
      @{Name="memberinlist";Expression={$_."memberinlist"}},
      @{Name="overalmem";Expression={$_."overalmem"}},
      @{Name="mem";Expression={$_."mem"}},
      @{Name="linenum";Expression={$_."linenum"}},
      @{Name="name_r7";Expression={$_."name_r7"}},
      @{Name="membersnames_r7";Expression={$_."MBg1s-membersnames_r7"}},
      @{Name="line_r6";Expression={$_."MBg1s-line_r6"}},
      @{Name="line_r7";Expression={$_."MemLINE-line_r7"}},
      @{Name="hhmem_key";Expression={$_."hhmem_key"}},
      @{Name="relateHOH_6";Expression={$_."relateHOH_6"}},
      @{Name="spinHH_6";Expression={$_."spinHH_6"}},
      @{Name="spline_6";Expression={$_."spline_6"}},
      @{Name="age_6";Expression={$_."age_6"}},
      @{Name="gender_6";Expression={$_."gender_6"}},
      @{Name="falive_6";Expression={$_."falive_6"}},
      @{Name="malive_6";Expression={$_."malive_6"}},
      @{Name="mut_6";Expression={$_."mut_6"}},
      @{Name="IDNR";Expression={$_."IDNR"}},
      @{Name="relateHOH_7";Expression={$_."relateHOH_7"}},
      @{Name="spousehh_7";Expression={$_."spousehh_7"}},
      @{Name="spousename_7";Expression={$_."spousename_7"}},
      @{Name="gender_7";Expression={$_."gender_7"}},
      @{Name="age_7";Expression={$_."age_7"}},
      @{Name="falive_7";Expression={$_."parentsurv-father-falive_7"}},
      @{Name="fcheckedbc_7";Expression={$_."parentsurv-father-fcheckedbc_7"}},
      @{Name="yeardied_7";Expression={$_."parentsurv-yeardied_7"}},
      @{Name="malive_7";Expression={$_."parentsurv-mother-malive_7"}},
      @{Name="mcheckedbc_7";Expression={$_."parentsurv-mother-mcheckedbc_7"}},
      @{Name="yearmdied_7";Expression={$_."parentsurv-yearmdied_7"}},
      @{Name="education_7";Expression={$_."education_7"}},
      @{Name="eduyrcompleted_7";Expression={$_."eduyrcompleted_7"}},
      @{Name="personalive_7";Expression={$_."pers-personalive_7"}},
      @{Name="yearpersondied_7";Expression={$_."yearpersondied_7"}},
      @{Name="personststay_7";Expression={$_."personststay_7"}},
      @{Name="lastyrstay_7";Expression={$_."lastyrstay_7"}},
      @{Name="regularstay_7";Expression={$_."regularstay_7"}},
      @{Name="nights_7";Expression={$_."nights_7"}},
      @{Name="lastmonthnights_7";Expression={$_."lastmonthnights_7"}},
      @{Name="eligible_ivq_7";Expression={$_."eligible_ivq_7"}},
      @{Name="hhmember_phone";Expression={$_."hhmember_phone"}},
      @{Name="PARENT_KEY";Expression={$_."PARENT_KEY"}},
      @{Name="METAKEY";Expression={$_."KEY"}} 		    |

                       

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
$id= $i.id
$hhkey= $i.hhkey
$memberinlist= $i.memberinlist
$overalmem= $i.overalmem
$mem= $i.mem
$linenum= $i.linenum
$name_r7= $i.name_r7.replace("'","")
$membersnames_r7= $i.membersnames_r7.replace("'","")
$line_r6= $i.line_r6
$line_r7= $i.line_r7
$hhmem_key= $i.hhmem_key
$relateHOH_6= $i.relateHOH_6
$spinHH_6= $i.spinHH_6
$spline_6= $i.spline_6
$age_6= $i.age_6
$gender_6= $i.gender_6
$falive_6= $i.falive_6
$malive_6= $i.malive_6
$IDNR= $i.IDNR
$mut_6= $i.mut_6
$relateHOH_7= $i.relateHOH_7
$spousehh_7= $i.spousehh_7
$spousename_7= $i.spousename_7.replace("'","")
$gender_7= $i.gender_7
$age_7= $i.age_7
$falive_7= $i.falive_7
$fcheckedbc_7= $i.fcheckedbc_7
$yeardied_7= $i.yeardied_7
$malive_7= $i.malive_7
$mcheckedbc_7= $i.mcheckedbc_7
$yearmdied_7= $i.yearmdied_7
$education_7= $i.education_7
$eduyrcompleted_7= $i.eduyrcompleted_7
$personalive_7= $i.personalive_7
$yearpersondied_7= $i.yearpersondied_7
$personststay_7= $i.personststay_7
$lastyrstay_7= $i.lastyrstay_7
$regularstay_7= $i.regularstay_7
$nights_7= $i.nights_7
$lastmonthnights_7= $i.lastmonthnights_7
$eligible_ivq_7= $i.eligible_ivq_7
$hhmember_phone= $i.hhmember_phone
$PARENT_KEY= $i.PARENT_KEY
$METAKEY = $i.METAKEY



$SQLQuery = "INSERT INTO hhmall_7 (id,
hhkey,
memberinlist,
overalmem,
mem,
linenum,
name_r7,
membersnames_r7,
line_r6,
line_r7,
hhmem_key,
relateHOH_6,
spinHH_6,
spline_6,
age_6,
gender_6,
falive_6,
malive_6,
IDNR,
mut_6,
relateHOH_7,
spousehh_7,
spousename_7,
gender_7,
age_7,
falive_7,
fcheckedbc_7,
yeardied_7,
malive_7,
mcheckedbc_7,
yearmdied_7,
education_7,
eduyrcompleted_7,
personalive_7,
yearpersondied_7,
personststay_7,
lastyrstay_7,
regularstay_7,
nights_7,
lastmonthnights_7,
eligible_ivq_7,
hhmember_phone,
PARENT_KEY,
METAKEY)   VALUES ('$id',
'$hhkey',
'$memberinlist',
'$overalmem',
'$mem',
'$linenum',
'$name_r7',
'$membersnames_r7',
'$line_r6',
'$line_r7',
'$hhmem_key',
'$relateHOH_6',
'$spinHH_6',
'$spline_6',
'$age_6',
'$gender_6',
'$falive_6',
'$malive_6',
'$IDNR',
'$mut_6',
'$relateHOH_7',
'$spousehh_7',
'$spousename_7',
'$gender_7',
'$age_7',
'$falive_7',
'$fcheckedbc_7',
'$yeardied_7',
'$malive_7',
'$mcheckedbc_7',
'$yearmdied_7',
'$education_7',
'$eduyrcompleted_7',
'$personalive_7',
'$yearpersondied_7',
'$personststay_7',
'$lastyrstay_7',
'$regularstay_7',
'$nights_7',
'$lastmonthnights_7',
'$eligible_ivq_7',
'$hhmember_phone',
'$PARENT_KEY',
'$METAKEY')" 



 $impcsv = invoke-sqlcmd -Username $LocalDatabaseUser -Password $LocalDatabasePWD -Database $LocalDatabaseName -Query $SQLQuery  -serverinstance $LocalSQLServerInstance  
        $InfoMessage = "Household memID $hhmem_key successfully uploaded to YZ-UHP Local MSSSQL Server."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 
 $InfoMessage = "Successfully imported $count HHMALL  Qstns into the YZ-UHP database" 
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

<#   ############################## UPLOADING TO THE CLOUD DATABASE #####################################################>
# Now lets import the CSV we have formmated  to the more friendly format. This is the data that will eventually get into the database
$data = import-csv $FormattedCSVFile -ErrorAction Stop
$InfoMessage = "Starting upload of data to the Cloud Database" 
Write-Log -Message $InfoMessage -Path $LogFile -Level Info

 # Now lets process the CSV
 
$count = 1 
 
foreach($i in $data){ 
$id= $i.id
$hhkey= $i.hhkey
$memberinlist= $i.memberinlist
$overalmem= $i.overalmem
$mem= $i.mem
$linenum= $i.linenum
$name_r7= $i.name_r7.replace("'","")
$membersnames_r7= $i.membersnames_r7.replace("'","")
$line_r6= $i.line_r6
$line_r7= $i.line_r7
$hhmem_key= $i.hhmem_key
$relateHOH_6= $i.relateHOH_6
$spinHH_6= $i.spinHH_6
$spline_6= $i.spline_6
$age_6= $i.age_6
$gender_6= $i.gender_6
$falive_6= $i.falive_6
$malive_6= $i.malive_6
$IDNR= $i.IDNR
$mut_6= $i.mut_6
$relateHOH_7= $i.relateHOH_7
$spousehh_7= $i.spousehh_7
$spousename_7= $i.spousename_7.replace("'","")
$gender_7= $i.gender_7
$age_7= $i.age_7
$falive_7= $i.falive_7
$fcheckedbc_7= $i.fcheckedbc_7
$yeardied_7= $i.yeardied_7
$malive_7= $i.malive_7
$mcheckedbc_7= $i.mcheckedbc_7
$yearmdied_7= $i.yearmdied_7
$education_7= $i.education_7
$eduyrcompleted_7= $i.eduyrcompleted_7
$personalive_7= $i.personalive_7
$yearpersondied_7= $i.yearpersondied_7
$personststay_7= $i.personststay_7
$lastyrstay_7= $i.lastyrstay_7
$regularstay_7= $i.regularstay_7
$nights_7= $i.nights_7
$lastmonthnights_7= $i.lastmonthnights_7
$eligible_ivq_7= $i.eligible_ivq_7
$hhmember_phone= $i.hhmember_phone
$PARENT_KEY= $i.PARENT_KEY
$METAKEY = $i.METAKEY



$SQLQuery = "INSERT INTO hhmall_7 (id,
hhkey,
memberinlist,
overalmem,
mem,
linenum,
name_r7,
membersnames_r7,
line_r6,
line_r7,
hhmem_key,
relateHOH_6,
spinHH_6,
spline_6,
age_6,
gender_6,
falive_6,
malive_6,
IDNR,
mut_6,
relateHOH_7,
spousehh_7,
spousename_7,
gender_7,
age_7,
falive_7,
fcheckedbc_7,
yeardied_7,
malive_7,
mcheckedbc_7,
yearmdied_7,
education_7,
eduyrcompleted_7,
personalive_7,
yearpersondied_7,
personststay_7,
lastyrstay_7,
regularstay_7,
nights_7,
lastmonthnights_7,
eligible_ivq_7,
hhmember_phone,
PARENT_KEY,
METAKEY)   VALUES ('$id',
'$hhkey',
'$memberinlist',
'$overalmem',
'$mem',
'$linenum',
'$name_r7',
'$membersnames_r7',
'$line_r6',
'$line_r7',
'$hhmem_key',
'$relateHOH_6',
'$spinHH_6',
'$spline_6',
'$age_6',
'$gender_6',
'$falive_6',
'$malive_6',
'$IDNR',
'$mut_6',
'$relateHOH_7',
'$spousehh_7',
'$spousename_7',
'$gender_7',
'$age_7',
'$falive_7',
'$fcheckedbc_7',
'$yeardied_7',
'$malive_7',
'$mcheckedbc_7',
'$yearmdied_7',
'$education_7',
'$eduyrcompleted_7',
'$personalive_7',
'$yearpersondied_7',
'$personststay_7',
'$lastyrstay_7',
'$regularstay_7',
'$nights_7',
'$lastmonthnights_7',
'$eligible_ivq_7',
'$hhmember_phone',
'$PARENT_KEY',
'$METAKEY')" 

 
       # Cloud Database Settings
        $impcsv = invoke-sqlcmd -Username $CloudDatabaseUser -Password $CloudDatabasePWD -Database $CloudDatabaseName -Query $SQLQuery  -serverinstance $CloudSQLServerInstance  
        $InfoMessage = "Household memID $hhmem_key successfully uploaded to Cloud YZ-UHP database on SmarterASP."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 


 $InfoMessage = "Successfully imported $count HHMALL Qstns into the YZ-UHP CLOUD database" 
 Write-Log -Message $InfoMessage -Path $LogFile   -Level Info

 

$InfoMessage = "Qstns Data upload completed"
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
    
    #Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential (Get-Credential) -Attachments $Attachment –DeliveryNotificationOption OnSuccess
}
