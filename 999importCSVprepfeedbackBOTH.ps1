
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
$SourceCSVFile = 'C:\DATA\Briefcase\BriefcaseDownloads\PrEP_Feedback.csv'
$FormattedCSVFile = 'C:\DATA\Briefcase\Formatted\prepfeedback_7.csv'
$RawBackupFolder = 'C:\DATA\Briefcase\Backup\Raw\prep\'
$FormattedBackupFolder = 'C:\DATA\Briefcase\Backup\Formatted\prep\'
$LogFileFolder = 'C:\DATA\Briefcase\Log\'

#Local Database Connection
$LocalSQLServerInstance = '.\SQLEXPRESS'
$LocalDatabaseName = 'YZUHP'
$LocalDatabaseUser = 'sa'
$LocalDatabasePWD = 'Adm!n123'

#Cloud Database Connection Settings
$CloudSQLServerInstance = 'sql5025.site4now.net'
$CloudDatabaseName = 'DB_A1EF79_yzuhp'
$CloudDatabaseUser = 'DB_A1EF79_yzuhp_admin'
$CloudDatabasePWD = 'Adm!n123'

# Database Table. Has to be identical table in both Databases
$DatabaseTable = 'prepfeedback_7'

# Lets create a Log file to log the events that will be happening today. Generate log file with current date.
$date = Get-Date -UFormat "%Y%m%d"
$LogFile = $LogFileFolder+'log-'+$date+'-prepfeedback_7.log'

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
Select  -Property   @{Name="SubmissionDate";Expression={$_."SubmissionDate"}},
                    @{Name="starttime";Expression={$_."starttime"}},
                    @{Name="endtime";Expression={$_."endtime"}},
                    @{Name="deviceid";Expression={$_."deviceid"}},
                    @{Name="subscriberid";Expression={$_."subscriberid"}},
                    @{Name="simid";Expression={$_."simid"}},
                    @{Name="devicephonenum";Expression={$_."devicephonenum"}},
                    @{Name="site";Expression={$_."memberdetails-site"}},
                    @{Name="hhid";Expression={$_."memberdetails-hhid"}},
                    @{Name="line_num";Expression={$_."memberdetails-line_num"}},
                    @{Name="hhkey";Expression={$_."hhkey"}},
                    @{Name="hhmem_key";Expression={$_."hhmem_key"}},
                    @{Name="sessiondate";Expression={$_."session-sessiondate"}},
                    @{Name="sessionnumber";Expression={$_."session-sessionnumber"}},
                    @{Name="age";Expression={$_."age"}},
                    @{Name="hivtransmit";Expression={$_."hivtransmit"}},
                    @{Name="hivtransmitanswer";Expression={$_."truefalse"}},
                    @{Name="Category";Expression={$_."Category"}},
                    @{Name="danaianaishe";Expression={$_."danaianaishe"}},
                    @{Name="answadanaianaishe";Expression={$_."answadanaianaishe"}},
                    @{Name="danaianaishe19above";Expression={$_."danaianaishe19above"}},
                    @{Name="answadanaianaishe19above";Expression={$_."answadanaianaishe19above"}},
                    @{Name="anaishedouglas";Expression={$_."anaishedouglas"}},
                    @{Name="answaanaishedouglas";Expression={$_."answaanaishedouglas"}},
                    @{Name="anaishedouglas19above";Expression={$_."anaishedouglas19above"}},
                    @{Name="answaanaishedouglas19above";Expression={$_."answaanaishedouglas19above"}},
                    @{Name="emanuelanashe";Expression={$_."emanuelanashe"}},
                    @{Name="answaemanuelanashe";Expression={$_."answaemanuelanashe"}},
                    @{Name="emanuelanashe19above";Expression={$_."emanuelanashe19above"}},
                    @{Name="answaemanuelanashe19above";Expression={$_."answaemanuelanashe19above"}},
                    @{Name="runakodouglas";Expression={$_."runakodouglas"}},
                    @{Name="answarunakodouglas";Expression={$_."answarunakodouglas"}},
                    @{Name="anaishevince";Expression={$_."anaishevince"}},
                    @{Name="answaanaishevince";Expression={$_."answaanaishevince"}},
                    @{Name="vinceanaishe19above";Expression={$_."vinceanaishe19above"}},
                    @{Name="answavinceanashe19above";Expression={$_."answavinceanashe19above"}},
                    @{Name="emmanuelvince";Expression={$_."emmanuelvince"}},
                    @{Name="answaemmanuelvince";Expression={$_."answaemmanuelvince"}},
                    @{Name="runakoshohiwa";Expression={$_."runakoshohiwa"}},
                    @{Name="answarunakoshohiwa";Expression={$_."answarunakoshohiwa"}},
                    @{Name="elvinanaishe";Expression={$_."elvinanaishe"}},
                    @{Name="answaelvinanaishe";Expression={$_."answaelvinanaishe"}},
                    @{Name="elvinanaishe19above";Expression={$_."elvinanaishe19above"}},
                    @{Name="answaelvinanaishe19above";Expression={$_."answaelvinanaishe19above"}},
                    @{Name="elvinvince";Expression={$_."elvinvince"}},
                    @{Name="answaelvinvince";Expression={$_."answaelvinvince"}},
                    @{Name="shingaishohiwa";Expression={$_."shingaishohiwa"}},
                    @{Name="answashingaishohiwa";Expression={$_."answashingaishohiwa"}},
                    @{Name="charlesvince";Expression={$_."charlesvince"}},
                    @{Name="answacharlesvince";Expression={$_."answacharlesvince"}},
                    @{Name="tashingashohiwa";Expression={$_."tashingashohiwa"}},
                    @{Name="answatashingashohiwa";Expression={$_."answatashingashohiwa"}},
                    @{Name="abstainanashevince";Expression={$_."abstainanashevince"}},
                    @{Name="answaabstainanashevince";Expression={$_."answaabstainanashevince"}},
                    @{Name="anashevincership";Expression={$_."anashevincership"}},
                    @{Name="answaanashevincership";Expression={$_."answaanashevincership"}},
                    @{Name="sexanashevince";Expression={$_."sexanashevince"}},
                    @{Name="answasexanashevince";Expression={$_."answasexanashevince"}},
                    @{Name="hearprep";Expression={$_."hearprep"}},
                    @{Name="preptaken";Expression={$_."preptaken"}},
                    @{Name="answapreptaken";Expression={$_."answapreptaken"}},
                    @{Name="prepworks";Expression={$_."prepworks"}},
                    @{Name="safemedicine";Expression={$_."safemedicine"}},
                    @{Name="professionaldiscuss";Expression={$_."professionaldiscuss"}},
                    @{Name="prepregularly";Expression={$_."prepregularly"}},
                    @{Name="answaprepregularly";Expression={$_."answaprepregularly"}},
                    @{Name="nursecontact";Expression={$_."nursecontact"}},
                    @{Name="cliniccontact";Expression={$_."cliniccontact"}},
                    @{Name="phone";Expression={$_."finalqstns-phone"}},
                    @{Name="name";Expression={$_."finalqstns-name"}},
                    @{Name="contacttime";Expression={$_."finalqstns-contacttime"}},
                    @{Name="prepuptake";Expression={$_."finalqstns-prepuptake"}},
                    @{Name="preprefnum";Expression={$_."preprefnum-preprefnum"}},
                    @{Name="instanceID";Expression={$_."meta-instanceID"}},
                    @{Name="METAKEY";Expression={$_."KEY"}}   |

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

$SubmissionDate= $i.SubmissionDate
$starttime= $i.starttime
$endtime= $i.endtime
$deviceid= $i.deviceid
$subscriberid= $i.subscriberid
$simid= $i.simid
$devicephonenum= $i.devicephonenum
$site= $i.site
$hhid= $i.hhid
$line_num= $i.line_num
$hhkey= $i.hhkey
$hhmem_key= $i.hhmem_key
$sessiondate= $i.sessiondate
$sessionnumber= $i.sessionnumber
$age= $i.age
$hivtransmit= $i.hivtransmit
$hivtransmitanswer= $i.truefalse
$Category= $i.Category
$danaianaishe= $i.danaianaishe
$answadanaianaishe= $i.answadanaianaishe
$danaianaishe19above= $i.danaianaishe19above
$answadanaianaishe19above= $i.answadanaianaishe19above
$anaishedouglas= $i.anaishedouglas
$answaanaishedouglas= $i.answaanaishedouglas
$anaishedouglas19above= $i.anaishedouglas19above
$answaanaishedouglas19above= $i.answaanaishedouglas19above
$emanuelanashe= $i.emanuelanashe
$answaemanuelanashe= $i.answaemanuelanashe
$emanuelanashe19above= $i.emanuelanashe19above
$answaemanuelanashe19above= $i.answaemanuelanashe19above
$runakodouglas= $i.runakodouglas
$answarunakodouglas= $i.answarunakodouglas
$anaishevince= $i.anaishevince
$answaanaishevince= $i.answaanaishevince
$vinceanaishe19above= $i.vinceanaishe19above
$answavinceanashe19above= $i.answavinceanashe19above
$emmanuelvince= $i.emmanuelvince
$answaemmanuelvince= $i.answaemmanuelvince
$runakoshohiwa= $i.runakoshohiwa
$answarunakoshohiwa= $i.answarunakoshohiwa
$elvinanaishe= $i.elvinanaishe
$answaelvinanaishe= $i.answaelvinanaishe
$elvinanaishe19above= $i.elvinanaishe19above
$answaelvinanaishe19above= $i.answaelvinanaishe19above
$elvinvince= $i.elvinvince
$answaelvinvince= $i.answaelvinvince
$shingaishohiwa= $i.shingaishohiwa
$answashingaishohiwa= $i.answashingaishohiwa
$charlesvince= $i.charlesvince
$answacharlesvince= $i.answacharlesvince
$tashingashohiwa= $i.tashingashohiwa
$answatashingashohiwa= $i.answatashingashohiwa
$abstainanashevince= $i.abstainanashevince
$answaabstainanashevince= $i.answaabstainanashevince
$anashevincership= $i.anashevincership
$answaanashevincership= $i.answaanashevincership
$sexanashevince= $i.sexanashevince
$answasexanashevince= $i.answasexanashevince
$hearprep= $i.hearprep
$preptaken= $i.preptaken
$answapreptaken= $i.answapreptaken
$prepworks= $i.prepworks
$safemedicine= $i.safemedicine
$professionaldiscuss= $i.professionaldiscuss
$prepregularly= $i.prepregularly
$answaprepregularly= $i.answaprepregularly
$nursecontact= $i.nursecontact
$cliniccontact= $i.cliniccontact
$phone= $i.phone
$name= $i.name
$contacttime= $i.contacttime
$prepuptake= $i.prepuptake
$preprefnum= $i.preprefnum
$instanceID= $i.instanceID
$METAKEY= $i.METAKEYKEY





$SQLQuery = "INSERT INTO prepfeedback_7 (
SubmissionDate,
starttime,
endtime,
deviceid,
subscriberid,
simid,
devicephonenum,
site,
hhid,
line_num,
hhkey,
hhmem_key,
sessiondate,
sessionnumber,
age,
hivtransmit,
hivtransmitanswer,
Category,
danaianaishe,
answadanaianaishe,
danaianaishe19above,
answadanaianaishe19above,
anaishedouglas,
answaanaishedouglas,
anaishedouglas19above,
answaanaishedouglas19above,
emanuelanashe,
answaemanuelanashe,
emanuelanashe19above,
answaemanuelanashe19above,
runakodouglas,
answarunakodouglas,
anaishevince,
answaanaishevince,
vinceanaishe19above,
answavinceanashe19above,
emmanuelvince,
answaemmanuelvince,
runakoshohiwa,
answarunakoshohiwa,
elvinanaishe,
answaelvinanaishe,
elvinanaishe19above,
answaelvinanaishe19above,
elvinvince,
answaelvinvince,
shingaishohiwa,
answashingaishohiwa,
charlesvince,
answacharlesvince,
tashingashohiwa,
answatashingashohiwa,
abstainanashevince,
answaabstainanashevince,
anashevincership,
answaanashevincership,
sexanashevince,
answasexanashevince,
hearprep,
preptaken,
answapreptaken,
prepworks,
safemedicine,
professionaldiscuss,
prepregularly,
answaprepregularly,
nursecontact,
cliniccontact,
phone,
name,
contacttime,
prepuptake,
preprefnum,
instanceID,
METAKEY )   VALUES (
'$SubmissionDate',
'$starttime',
'$endtime',
'$deviceid',
'$subscriberid',
'$simid',
'$devicephonenum',
'$site',
'$hhid',
'$line_num',
'$hhkey',
'$hhmem_key',
'$sessiondate',
'$sessionnumber',
'$age',
'$hivtransmit',
'$hivtransmitanswer',
'$Category',
'$danaianaishe',
'$answadanaianaishe',
'$danaianaishe19above',
'$answadanaianaishe19above',
'$anaishedouglas',
'$answaanaishedouglas',
'$anaishedouglas19above',
'$answaanaishedouglas19above',
'$emanuelanashe',
'$answaemanuelanashe',
'$emanuelanashe19above',
'$answaemanuelanashe19above',
'$runakodouglas',
'$answarunakodouglas',
'$anaishevince',
'$answaanaishevince',
'$vinceanaishe19above',
'$answavinceanashe19above',
'$emmanuelvince',
'$answaemmanuelvince',
'$runakoshohiwa',
'$answarunakoshohiwa',
'$elvinanaishe',
'$answaelvinanaishe',
'$elvinanaishe19above',
'$answaelvinanaishe19above',
'$elvinvince',
'$answaelvinvince',
'$shingaishohiwa',
'$answashingaishohiwa',
'$charlesvince',
'$answacharlesvince',
'$tashingashohiwa',
'$answatashingashohiwa',
'$abstainanashevince',
'$answaabstainanashevince',
'$anashevincership',
'$answaanashevincership',
'$sexanashevince',
'$answasexanashevince',
'$hearprep',
'$preptaken',
'$answapreptaken',
'$prepworks',
'$safemedicine',
'$professionaldiscuss',
'$prepregularly',
'$answaprepregularly',
'$nursecontact',
'$cliniccontact',
'$phone',
'$name',
'$contacttime',
'$prepuptake',
'$preprefnum',
'$instanceID',
'$METAKEY' )"


  $impcsv = invoke-sqlcmd -Username $LocalDatabaseUser -Password $LocalDatabasePWD -Database $LocalDatabaseName -Query $SQLQuery  -serverinstance $LocalSQLServerInstance  
        $InfoMessage = "Household memID $hhmem_key successfully uploaded to YZ-UHP Local MSSSQL Server."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 
 $InfoMessage = "Successfully imported $count Psycho Qstns into the YZ-UHP database" 
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

$SubmissionDate= $i.SubmissionDate
$starttime= $i.starttime
$endtime= $i.endtime
$deviceid= $i.deviceid
$subscriberid= $i.subscriberid
$simid= $i.simid
$devicephonenum= $i.devicephonenum
$site= $i.site
$hhid= $i.hhid
$line_num= $i.line_num
$hhkey= $i.hhkey
$hhmem_key= $i.hhmem_key
$sessiondate= $i.sessiondate
$sessionnumber= $i.sessionnumber
$age= $i.age
$hivtransmit= $i.hivtransmit
$hivtransmitanswer= $i.truefalse
$Category= $i.Category
$danaianaishe= $i.danaianaishe
$answadanaianaishe= $i.answadanaianaishe
$danaianaishe19above= $i.danaianaishe19above
$answadanaianaishe19above= $i.answadanaianaishe19above
$anaishedouglas= $i.anaishedouglas
$answaanaishedouglas= $i.answaanaishedouglas
$anaishedouglas19above= $i.anaishedouglas19above
$answaanaishedouglas19above= $i.answaanaishedouglas19above
$emanuelanashe= $i.emanuelanashe
$answaemanuelanashe= $i.answaemanuelanashe
$emanuelanashe19above= $i.emanuelanashe19above
$answaemanuelanashe19above= $i.answaemanuelanashe19above
$runakodouglas= $i.runakodouglas
$answarunakodouglas= $i.answarunakodouglas
$anaishevince= $i.anaishevince
$answaanaishevince= $i.answaanaishevince
$vinceanaishe19above= $i.vinceanaishe19above
$answavinceanashe19above= $i.answavinceanashe19above
$emmanuelvince= $i.emmanuelvince
$answaemmanuelvince= $i.answaemmanuelvince
$runakoshohiwa= $i.runakoshohiwa
$answarunakoshohiwa= $i.answarunakoshohiwa
$elvinanaishe= $i.elvinanaishe
$answaelvinanaishe= $i.answaelvinanaishe
$elvinanaishe19above= $i.elvinanaishe19above
$answaelvinanaishe19above= $i.answaelvinanaishe19above
$elvinvince= $i.elvinvince
$answaelvinvince= $i.answaelvinvince
$shingaishohiwa= $i.shingaishohiwa
$answashingaishohiwa= $i.answashingaishohiwa
$charlesvince= $i.charlesvince
$answacharlesvince= $i.answacharlesvince
$tashingashohiwa= $i.tashingashohiwa
$answatashingashohiwa= $i.answatashingashohiwa
$abstainanashevince= $i.abstainanashevince
$answaabstainanashevince= $i.answaabstainanashevince
$anashevincership= $i.anashevincership
$answaanashevincership= $i.answaanashevincership
$sexanashevince= $i.sexanashevince
$answasexanashevince= $i.answasexanashevince
$hearprep= $i.hearprep
$preptaken= $i.preptaken
$answapreptaken= $i.answapreptaken
$prepworks= $i.prepworks
$safemedicine= $i.safemedicine
$professionaldiscuss= $i.professionaldiscuss
$prepregularly= $i.prepregularly
$answaprepregularly= $i.answaprepregularly
$nursecontact= $i.nursecontact
$cliniccontact= $i.cliniccontact
$phone= $i.phone
$name= $i.name
$contacttime= $i.contacttime
$prepuptake= $i.prepuptake
$preprefnum= $i.preprefnum
$instanceID= $i.instanceID
$METAKEY= $i.METAKEYKEY





$SQLQuery = "INSERT INTO prepfeedback_7 (
SubmissionDate,
starttime,
endtime,
deviceid,
subscriberid,
simid,
devicephonenum,
site,
hhid,
line_num,
hhkey,
hhmem_key,
sessiondate,
sessionnumber,
age,
hivtransmit,
hivtransmitanswer,
Category,
danaianaishe,
answadanaianaishe,
danaianaishe19above,
answadanaianaishe19above,
anaishedouglas,
answaanaishedouglas,
anaishedouglas19above,
answaanaishedouglas19above,
emanuelanashe,
answaemanuelanashe,
emanuelanashe19above,
answaemanuelanashe19above,
runakodouglas,
answarunakodouglas,
anaishevince,
answaanaishevince,
vinceanaishe19above,
answavinceanashe19above,
emmanuelvince,
answaemmanuelvince,
runakoshohiwa,
answarunakoshohiwa,
elvinanaishe,
answaelvinanaishe,
elvinanaishe19above,
answaelvinanaishe19above,
elvinvince,
answaelvinvince,
shingaishohiwa,
answashingaishohiwa,
charlesvince,
answacharlesvince,
tashingashohiwa,
answatashingashohiwa,
abstainanashevince,
answaabstainanashevince,
anashevincership,
answaanashevincership,
sexanashevince,
answasexanashevince,
hearprep,
preptaken,
answapreptaken,
prepworks,
safemedicine,
professionaldiscuss,
prepregularly,
answaprepregularly,
nursecontact,
cliniccontact,
phone,
name,
contacttime,
prepuptake,
preprefnum,
instanceID,
METAKEY )   VALUES (
'$SubmissionDate',
'$starttime',
'$endtime',
'$deviceid',
'$subscriberid',
'$simid',
'$devicephonenum',
'$site',
'$hhid',
'$line_num',
'$hhkey',
'$hhmem_key',
'$sessiondate',
'$sessionnumber',
'$age',
'$hivtransmit',
'$hivtransmitanswer',
'$Category',
'$danaianaishe',
'$answadanaianaishe',
'$danaianaishe19above',
'$answadanaianaishe19above',
'$anaishedouglas',
'$answaanaishedouglas',
'$anaishedouglas19above',
'$answaanaishedouglas19above',
'$emanuelanashe',
'$answaemanuelanashe',
'$emanuelanashe19above',
'$answaemanuelanashe19above',
'$runakodouglas',
'$answarunakodouglas',
'$anaishevince',
'$answaanaishevince',
'$vinceanaishe19above',
'$answavinceanashe19above',
'$emmanuelvince',
'$answaemmanuelvince',
'$runakoshohiwa',
'$answarunakoshohiwa',
'$elvinanaishe',
'$answaelvinanaishe',
'$elvinanaishe19above',
'$answaelvinanaishe19above',
'$elvinvince',
'$answaelvinvince',
'$shingaishohiwa',
'$answashingaishohiwa',
'$charlesvince',
'$answacharlesvince',
'$tashingashohiwa',
'$answatashingashohiwa',
'$abstainanashevince',
'$answaabstainanashevince',
'$anashevincership',
'$answaanashevincership',
'$sexanashevince',
'$answasexanashevince',
'$hearprep',
'$preptaken',
'$answapreptaken',
'$prepworks',
'$safemedicine',
'$professionaldiscuss',
'$prepregularly',
'$answaprepregularly',
'$nursecontact',
'$cliniccontact',
'$phone',
'$name',
'$contacttime',
'$prepuptake',
'$preprefnum',
'$instanceID',
'$METAKEY' )"

  # Cloud Database Settings
        $impcsv = invoke-sqlcmd -Username $CloudDatabaseUser -Password $CloudDatabasePWD -Database $CloudDatabaseName -Query $SQLQuery  -serverinstance $CloudSQLServerInstance  
        $InfoMessage = "Household memID $hhmem_key successfully uploaded to Cloud YZ-UHP database on SmarterASP."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 

 $InfoMessage = "Successfully imported $count prep feedback Qstns into the YZ-UHP CLOUD database" 
 Write-Log -Message $InfoMessage -Path $LogFile   -Level Info

 

$InfoMessage = "Qstns Data upload completed"
}


Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    
    Write-Log -Message "Error : Upload to Cloud database failed with the error : $ErrorMessage" -Path $LogFile -Level Error
}



# END OF SCRIPT
 
 


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





