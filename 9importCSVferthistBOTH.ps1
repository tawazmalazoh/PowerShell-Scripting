
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
$SourceCSVFile = 'C:\DATA\Briefcase\BriefcaseDownloads\Baseline_INDVQ.csv'
$FormattedCSVFile = 'C:\DATA\Briefcase\Formatted\ferthist_7.csv'
$RawBackupFolder = 'C:\DATA\Briefcase\Backup\Raw\ivq\'
$FormattedBackupFolder = 'C:\DATA\Briefcase\Backup\Formatted\ivq\'
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
$DatabaseTable = 'ferthist_7'


# Lets create a Log file to log the events that will be happening today. Generate log file with current date.
$date = Get-Date -UFormat "%Y%m%d"
$LogFile = $LogFileFolder+'log-'+$date+'-ferthist_7.log'



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
Select  -Property   @{Name="hhkey";Expression={$_."hhkey"}},
      @{Name="hhmem_key";Expression={$_."hhmem_key"}},
      @{Name="Q801";Expression={$_."consented-Q801"}},
      @{Name="Q802";Expression={$_."consented-givebirth-Q802"}},
      @{Name="Q803son";Expression={$_."consented-givebirth-Q803-Q803son"}},
      @{Name="Q803dgter";Expression={$_."consented-givebirth-Q803-Q803dgter"}},
      @{Name="Q804";Expression={$_."consented-givebirth-Q804"}},
      @{Name="Q805son";Expression={$_."consented-givebirth-Q805-Q805son"}},
      @{Name="Q805dgter";Expression={$_."consented-givebirth-Q805-Q805dgter"}},
      @{Name="Q806";Expression={$_."consented-Q806"}},
      @{Name="Q807boys";Expression={$_."consented-Q807-Q807boys"}},
      @{Name="Q807girls";Expression={$_."consented-Q807-Q807girls"}},
      @{Name="total";Expression={$_."consented-total"}},
      @{Name="Q808total";Expression={$_."consented-Q808total"}},
      @{Name="Q809";Expression={$_."consented-Q809"}},
      @{Name="Q810";Expression={$_."consented-womn-Q810"}},
      @{Name="Q811";Expression={$_."consented-womn-Q811"}},
      @{Name="Q901";Expression={$_."consented-womn-Q901"}},
      @{Name="Q902";Expression={$_."consented-womn-Q902"}},
      @{Name="Q903";Expression={$_."consented-womn-Q903"}},
      @{Name="Q904mnths";Expression={$_."consented-womn-pgncyendlivebirth-Q904-Q904mnths"}},
      @{Name="Q904yrs";Expression={$_."consented-womn-pgncyendlivebirth-Q904-Q904yrs"}},
      @{Name="Q905";Expression={$_."consented-womn-pgncyendlivebirth-Q905"}},
      @{Name="Q906";Expression={$_."consented-womn-pgncyendlivebirth-Q906"}},
      @{Name="Q907";Expression={$_."consented-womn-pgncyendlivebirth-ancpreg-Q907"}},
      @{Name="Q908";Expression={$_."consented-womn-pgncyendlivebirth-ancpreg-Q908"}},
      @{Name="Q909";Expression={$_."consented-womn-pgncyendlivebirth-ancpreg-Q909"}},
      @{Name="Q910";Expression={$_."consented-womn-pgncyendlivebirth-ancpreg-Q910"}},
      @{Name="Q911";Expression={$_."consented-womn-pgncyendlivebirth-ancpreg-infect-Q911"}},
      @{Name="Q912";Expression={$_."consented-womn-pgncyendlivebirth-ancpreg-infect-Q912"}},
      @{Name="Q912other";Expression={$_."consented-womn-pgncyendlivebirth-ancpreg-infect-Q912other"}},
      @{Name="Q913";Expression={$_."consented-womn-pgncyendlivebirth-ancpreg-infect-Q913"}},
      @{Name="Q914";Expression={$_."consented-womn-pgncyendlivebirth-ancpreg-infect-Q914"}},
      @{Name="Q914other";Expression={$_."consented-womn-pgncyendlivebirth-ancpreg-infect-Q914other"}},
      @{Name="Q915a";Expression={$_."consented-womn-pgncyendlivebirth-ancpreg-infect-Q915-Q915a"}},
      @{Name="Q915b";Expression={$_."consented-womn-pgncyendlivebirth-ancpreg-infect-Q915-Q915b"}},
      @{Name="Q915c";Expression={$_."consented-womn-pgncyendlivebirth-ancpreg-infect-Q915-Q915c"}},
      @{Name="Q916";Expression={$_."consented-womn-pgncyendlivebirth-ancpreg-infect-Q916"}},
      @{Name="Q917";Expression={$_."consented-womn-pgncyendlivebirth-ancpreg-Q917"}},
      @{Name="Q918";Expression={$_."consented-womn-pgncyendlivebirth-ancpreg-Q918"}},
      @{Name="Q919";Expression={$_."consented-womn-pgncyendlivebirth-ancpreg-Q919"}},
      @{Name="Q920";Expression={$_."consented-womn-pgncyendlivebirth-ancpreg-Q920"}},
      @{Name="Q921";Expression={$_."consented-womn-pgncyendlivebirth-ancpreg-Q921"}},
      @{Name="Q922";Expression={$_."consented-womn-pgncyendlivebirth-ancpreg-Q922"}},
      @{Name="Q923";Expression={$_."consented-womn-pgncyendlivebirth-novmmc-Q923"}},
      @{Name="Q924";Expression={$_."consented-womn-pgncyendlivebirth-novmmc-Q924"}},
      @{Name="Q925";Expression={$_."consented-womn-pgncyendlivebirth-novmmc-Q925"}},
      @{Name="Q926";Expression={$_."consented-womn-pgncyendlivebirth-novmmc-Q926"}},
      @{Name="Q927";Expression={$_."consented-womn-pgncyendlivebirth-Q927"}},
      @{Name="Q928";Expression={$_."consented-womn-pgncyendlivebirth-feed-Q928"}},
      @{Name="Q929a";Expression={$_."consented-womn-pgncyendlivebirth-feed-notbreastfeed-Q929-Q929a"}},
      @{Name="Q929b";Expression={$_."consented-womn-pgncyendlivebirth-feed-notbreastfeed-Q929-Q929b"}},
      @{Name="Q930";Expression={$_."consented-womn-pgncyendlivebirth-feed-notbreastfeed-Q930"}},
      @{Name="Q930other";Expression={$_."consented-womn-pgncyendlivebirth-feed-notbreastfeed-Q930other"}},
      @{Name="Q1001";Expression={$_."consented-Q1001"}},
      @{Name="Q1002a";Expression={$_."consented-usecontra-Q1002-Q1002a"}},
      @{Name="Q1002b";Expression={$_."consented-usecontra-Q1002-Q1002b"}},
      @{Name="Q1002c";Expression={$_."consented-usecontra-Q1002-Q1002c"}},
      @{Name="Q1002d";Expression={$_."consented-usecontra-Q1002-Q1002d"}},
      @{Name="Q1002e";Expression={$_."consented-usecontra-Q1002-Q1002e"}},
      @{Name="Q1002f";Expression={$_."consented-usecontra-Q1002-Q1002f"}},
      @{Name="Q1002g";Expression={$_."consented-usecontra-Q1002-Q1002g"}},
      @{Name="Q1002other";Expression={$_."consented-usecontra-Q1002-Q1002other"}},
      @{Name="Q1003";Expression={$_."consented-usecontra-Q1003"}},
      @{Name="Q1003other";Expression={$_."consented-usecontra-Q914other"}},
      @{Name="Q1004";Expression={$_."consented-Q1004"}},
      @{Name="Q1005cell1";Expression={$_."consented-Q1005-Q1005cell1"}},
      @{Name="Q1005cell2";Expression={$_."consented-Q1005-Q1005cell2"}},
      @{Name="Q1006";Expression={$_."consented-Q1006"}},
      @{Name="barcode";Expression={$_."consented-barcode"}},
      @{Name="codefail";Expression={$_."consented-codefail"}},
      @{Name="dbsreason";Expression={$_."consented-dbsreason"}},
      @{Name="respcomm_research";Expression={$_."consented-Q1007-respcomm_research"}},
      @{Name="respcomm_support";Expression={$_."consented-Q1007-respcomm_support"}},
      @{Name="ennumcomm";Expression={$_."consented-Q1007-ennumcomm"}},
      @{Name="end_1";Expression={$_."end_1"}},
      @{Name="start_date";Expression={$_."start_date"}},
      @{Name="end_date";Expression={$_."end_date"}},
      @{Name="date_match";Expression={$_."date_match"}},
      @{Name="startformatted";Expression={$_."startformatted"}},
      @{Name="endformatted";Expression={$_."endformatted"}},
      @{Name="start_hour";Expression={$_."start_hour"}},
      @{Name="end_hour";Expression={$_."end_hour"}},
      @{Name="start_minutes";Expression={$_."start_minutes"}},
      @{Name="end_minutes";Expression={$_."end_minutes"}},
      @{Name="duration_hours";Expression={$_."duration_hours"}},
      @{Name="duration_minutes";Expression={$_."duration_minutes"}},
      @{Name="durationtext";Expression={$_."durationtext"}},
      @{Name="durationinmin";Expression={$_."durationinmin"}},
      @{Name="interview";Expression={$_."interview"}},
      @{Name="signaturelink";Expression={$_."consented-spaceman_form-spacemansignature"}},      
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

$hhkey= $i.hhkey
$hhmem_key= $i.hhmem_key
$Q801= $i.Q801
$Q802= $i.Q802
$Q803son= $i.Q803son
$Q803dgter= $i.Q803dgter
$Q804= $i.Q804
$Q805son= $i.Q805son
$Q805dgter= $i.Q805dgter
$Q806= $i.Q806
$Q807boys= $i.Q807boys
$Q807girls= $i.Q807girls
$total= $i.total
$Q808total= $i.Q808total
$Q809= $i.Q809
$Q810= $i.Q810
$Q811= $i.Q811
$Q901= $i.Q901
$Q902= $i.Q902
$Q903= $i.Q903
$Q904mnths= $i.Q904mnths
$Q904yrs= $i.Q904yrs
$Q905= $i.Q905
$Q906= $i.Q906
$Q907= $i.Q907
$Q908= $i.Q908
$Q909= $i.Q909
$Q910= $i.Q910
$Q911= $i.Q911
$Q912= $i.Q912
$Q912other= $i.Q912other.replace("'","")
$Q913= $i.Q913
$Q914= $i.Q914
$Q914other= $i.Q914other.replace("'","")
$Q915a= $i.Q915a
$Q915b= $i.Q915b
$Q915c= $i.Q915c
$Q916= $i.Q916
$Q917= $i.Q917
$Q918= $i.Q918
$Q919= $i.Q919
$Q920= $i.Q920
$Q921= $i.Q921
$Q922= $i.Q922
$Q923= $i.Q923
$Q924= $i.Q924
$Q925= $i.Q925
$Q926= $i.Q926
$Q927= $i.Q927
$Q928= $i.Q928
$Q929a= $i.Q929a
$Q929b= $i.Q929b
$Q930= $i.Q930
$Q930other= $i.Q930other.replace("'","")
$Q1001= $i.Q1001
$Q1002a= $i.Q1002a
$Q1002b= $i.Q1002b
$Q1002c= $i.Q1002c
$Q1002d= $i.Q1002d
$Q1002e= $i.Q1002e
$Q1002f= $i.Q1002f
$Q1002g= $i.Q1002g
$Q1002other= $i.Q1002other.replace("'","")
$Q1003= $i.Q1003
$Q1003other= $i.Q1003other.replace("'","")
$Q1004= $i.Q1004
$Q1005cell1= $i.Q1005cell1
$Q1005cell2= $i.Q1005cell2
$Q1006= $i.Q1006
$barcode= $i.barcode
$codefail= $i.codefail
$dbsreason= $i.dbsreason
$respcomm_research= $i.respcomm_research.replace("'","")
$respcomm_support= $i.respcomm_support.replace("'","")
$ennumcomm= $i.ennumcomm.replace("'","")
$end_1= $i.end_1
$start_date= $i.start_date
$end_date= $i.end_date
$date_match= $i.date_match
$startformatted= $i.startformatted
$endformatted= $i.endformatted
$start_hour= $i.start_hour
$end_hour= $i.end_hour
$start_minutes= $i.start_minutes
$end_minutes= $i.end_minutes
$duration_hours= $i.duration_hours
$duration_minutes= $i.duration_minutes
$durationtext= $i.durationtext
$durationinmin= $i.durationinmin
$interview= $i.interview
$METAKEY= $i.METAKEY
$signaturelink=$i.signaturelink


$SQLQuery = "INSERT INTO ferthist_7 (hhkey,
hhmem_key,
Q801,
Q802,
Q803son,
Q803dgter,
Q804,
Q805son,
Q805dgter,
Q806,
Q807boys,
Q807girls,
total,
Q808total,
Q809,
Q810,
Q811,
Q901,
Q902,
Q903,
Q904mnths,
Q904yrs,
Q905,
Q906,
Q907,
Q908,
Q909,
Q910,
Q911,
Q912,
Q912other,
Q913,
Q914,
Q914other,
Q915a,
Q915b,
Q915c,
Q916,
Q917,
Q918,
Q919,
Q920,
Q921,
Q922,
Q923,
Q924,
Q925,
Q926,
Q927,
Q928,
Q929a,
Q929b,
Q930,
Q930other,
Q1001,
Q1002a,
Q1002b,
Q1002c,
Q1002d,
Q1002e,
Q1002f,
Q1002g,
Q1002other,
Q1003,
Q1003other,
Q1004,
Q1005cell1,
Q1005cell2,
Q1006,
barcode,
codefail,
dbsreason,
respcomm_research,
respcomm_support,
ennumcomm,
end_1,
start_date,
end_date,
date_match,
startformatted,
endformatted,
start_hour,
end_hour,
start_minutes,
end_minutes,
duration_hours,
duration_minutes,
durationtext,
durationinmin,
interview,
METAKEY,signaturelink)            VALUES ('$hhkey',
'$hhmem_key',
'$Q801',
'$Q802',
'$Q803son',
'$Q803dgter',
'$Q804',
'$Q805son',
'$Q805dgter',
'$Q806',
'$Q807boys',
'$Q807girls',
'$total',
'$Q808total',
'$Q809',
'$Q810',
'$Q811',
'$Q901',
'$Q902',
'$Q903',
'$Q904mnths',
'$Q904yrs',
'$Q905',
'$Q906',
'$Q907',
'$Q908',
'$Q909',
'$Q910',
'$Q911',
'$Q912',
'$Q912other',
'$Q913',
'$Q914',
'$Q914other',
'$Q915a',
'$Q915b',
'$Q915c',
'$Q916',
'$Q917',
'$Q918',
'$Q919',
'$Q920',
'$Q921',
'$Q922',
'$Q923',
'$Q924',
'$Q925',
'$Q926',
'$Q927',
'$Q928',
'$Q929a',
'$Q929b',
'$Q930',
'$Q930other',
'$Q1001',
'$Q1002a',
'$Q1002b',
'$Q1002c',
'$Q1002d',
'$Q1002e',
'$Q1002f',
'$Q1002g',
'$Q1002other',
'$Q1003',
'$Q1003other',
'$Q1004',
'$Q1005cell1',
'$Q1005cell2',
'$Q1006',
'$barcode',
'$codefail',
'$dbsreason',
'$respcomm_research',
'$respcomm_support',
'$ennumcomm',
'$end_1',
'$start_date',
'$end_date',
'$date_match',
'$startformatted',
'$endformatted',
'$start_hour',
'$end_hour',
'$start_minutes',
'$end_minutes',
'$duration_hours',
'$duration_minutes',
'$durationtext',
'$durationinmin',
'$interview',
'$METAKEY',
'$signaturelink')"



 $impcsv = invoke-sqlcmd -Username $LocalDatabaseUser -Password $LocalDatabasePWD -Database $LocalDatabaseName -Query $SQLQuery  -serverinstance $LocalSQLServerInstance  
        $InfoMessage = "Household memID $hhmem_key successfully uploaded to YZ-UHP Local MSSSQL Server."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 
 $InfoMessage = "Successfully imported $count FIRTHIST  Qstns into the YZ-UHP database" 
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

$hhkey= $i.hhkey
$hhmem_key= $i.hhmem_key
$Q801= $i.Q801
$Q802= $i.Q802
$Q803son= $i.Q803son
$Q803dgter= $i.Q803dgter
$Q804= $i.Q804
$Q805son= $i.Q805son
$Q805dgter= $i.Q805dgter
$Q806= $i.Q806
$Q807boys= $i.Q807boys
$Q807girls= $i.Q807girls
$total= $i.total
$Q808total= $i.Q808total
$Q809= $i.Q809
$Q810= $i.Q810
$Q811= $i.Q811
$Q901= $i.Q901
$Q902= $i.Q902
$Q903= $i.Q903
$Q904mnths= $i.Q904mnths
$Q904yrs= $i.Q904yrs
$Q905= $i.Q905
$Q906= $i.Q906
$Q907= $i.Q907
$Q908= $i.Q908
$Q909= $i.Q909
$Q910= $i.Q910
$Q911= $i.Q911
$Q912= $i.Q912
$Q912other= $i.Q912other.replace("'","")
$Q913= $i.Q913
$Q914= $i.Q914
$Q914other= $i.Q914other.replace("'","")
$Q915a= $i.Q915a
$Q915b= $i.Q915b
$Q915c= $i.Q915c
$Q916= $i.Q916
$Q917= $i.Q917
$Q918= $i.Q918
$Q919= $i.Q919
$Q920= $i.Q920
$Q921= $i.Q921
$Q922= $i.Q922
$Q923= $i.Q923
$Q924= $i.Q924
$Q925= $i.Q925
$Q926= $i.Q926
$Q927= $i.Q927
$Q928= $i.Q928
$Q929a= $i.Q929a
$Q929b= $i.Q929b
$Q930= $i.Q930
$Q930other= $i.Q930other.replace("'","")
$Q1001= $i.Q1001
$Q1002a= $i.Q1002a
$Q1002b= $i.Q1002b
$Q1002c= $i.Q1002c
$Q1002d= $i.Q1002d
$Q1002e= $i.Q1002e
$Q1002f= $i.Q1002f
$Q1002g= $i.Q1002g
$Q1002other= $i.Q1002other.replace("'","")
$Q1003= $i.Q1003
$Q1003other= $i.Q1003other.replace("'","")
$Q1004= $i.Q1004
$Q1005cell1= $i.Q1005cell1
$Q1005cell2= $i.Q1005cell2
$Q1006= $i.Q1006
$barcode= $i.barcode
$codefail= $i.codefail
$dbsreason= $i.dbsreason
$respcomm_research= $i.respcomm_research.replace("'","")
$respcomm_support= $i.respcomm_support.replace("'","")
$ennumcomm= $i.ennumcomm.replace("'","")
$end_1= $i.end_1
$start_date= $i.start_date
$end_date= $i.end_date
$date_match= $i.date_match
$startformatted= $i.startformatted
$endformatted= $i.endformatted
$start_hour= $i.start_hour
$end_hour= $i.end_hour
$start_minutes= $i.start_minutes
$end_minutes= $i.end_minutes
$duration_hours= $i.duration_hours
$duration_minutes= $i.duration_minutes
$durationtext= $i.durationtext
$durationinmin= $i.durationinmin
$interview= $i.interview
$METAKEY= $i.METAKEY
$signaturelink=$i.signaturelink


$SQLQuery = "INSERT INTO ferthist_7 (hhkey,
hhmem_key,
Q801,
Q802,
Q803son,
Q803dgter,
Q804,
Q805son,
Q805dgter,
Q806,
Q807boys,
Q807girls,
total,
Q808total,
Q809,
Q810,
Q811,
Q901,
Q902,
Q903,
Q904mnths,
Q904yrs,
Q905,
Q906,
Q907,
Q908,
Q909,
Q910,
Q911,
Q912,
Q912other,
Q913,
Q914,
Q914other,
Q915a,
Q915b,
Q915c,
Q916,
Q917,
Q918,
Q919,
Q920,
Q921,
Q922,
Q923,
Q924,
Q925,
Q926,
Q927,
Q928,
Q929a,
Q929b,
Q930,
Q930other,
Q1001,
Q1002a,
Q1002b,
Q1002c,
Q1002d,
Q1002e,
Q1002f,
Q1002g,
Q1002other,
Q1003,
Q1003other,
Q1004,
Q1005cell1,
Q1005cell2,
Q1006,
barcode,
codefail,
dbsreason,
respcomm_research,
respcomm_support,
ennumcomm,
end_1,
start_date,
end_date,
date_match,
startformatted,
endformatted,
start_hour,
end_hour,
start_minutes,
end_minutes,
duration_hours,
duration_minutes,
durationtext,
durationinmin,
interview,
METAKEY,signaturelink)            VALUES ('$hhkey',
'$hhmem_key',
'$Q801',
'$Q802',
'$Q803son',
'$Q803dgter',
'$Q804',
'$Q805son',
'$Q805dgter',
'$Q806',
'$Q807boys',
'$Q807girls',
'$total',
'$Q808total',
'$Q809',
'$Q810',
'$Q811',
'$Q901',
'$Q902',
'$Q903',
'$Q904mnths',
'$Q904yrs',
'$Q905',
'$Q906',
'$Q907',
'$Q908',
'$Q909',
'$Q910',
'$Q911',
'$Q912',
'$Q912other',
'$Q913',
'$Q914',
'$Q914other',
'$Q915a',
'$Q915b',
'$Q915c',
'$Q916',
'$Q917',
'$Q918',
'$Q919',
'$Q920',
'$Q921',
'$Q922',
'$Q923',
'$Q924',
'$Q925',
'$Q926',
'$Q927',
'$Q928',
'$Q929a',
'$Q929b',
'$Q930',
'$Q930other',
'$Q1001',
'$Q1002a',
'$Q1002b',
'$Q1002c',
'$Q1002d',
'$Q1002e',
'$Q1002f',
'$Q1002g',
'$Q1002other',
'$Q1003',
'$Q1003other',
'$Q1004',
'$Q1005cell1',
'$Q1005cell2',
'$Q1006',
'$barcode',
'$codefail',
'$dbsreason',
'$respcomm_research',
'$respcomm_support',
'$ennumcomm',
'$end_1',
'$start_date',
'$end_date',
'$date_match',
'$startformatted',
'$endformatted',
'$start_hour',
'$end_hour',
'$start_minutes',
'$end_minutes',
'$duration_hours',
'$duration_minutes',
'$durationtext',
'$durationinmin',
'$interview',
'$METAKEY','$signaturelink')"



       # Cloud Database Settings
        $impcsv = invoke-sqlcmd -Username $CloudDatabaseUser -Password $CloudDatabasePWD -Database $CloudDatabaseName -Query $SQLQuery  -serverinstance $CloudSQLServerInstance  
        $InfoMessage = "Household memID $hhmem_key successfully uploaded to Cloud YZ-UHP database on SmarterASP."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 


 $InfoMessage = "Successfully imported $count FirtHist Qstns into the YZ-UHP CLOUD database" 
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
