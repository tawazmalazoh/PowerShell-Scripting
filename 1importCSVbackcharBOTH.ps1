

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
$FormattedCSVFile = 'C:\DATA\Briefcase\Formatted\backchar_7.csv'
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
$DatabaseTable = 'backchar_7'


# Lets create a Log file to log the events that will be happening today. Generate log file with current date.
$date = Get-Date -UFormat "%Y%m%d"
$LogFile = $LogFileFolder+'log-'+$date+'-backchar_7.log'



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
      @{Name="start";Expression={$_."start"}},
      @{Name="endtime";Expression={$_."endtime"}},
      @{Name="deviceid";Expression={$_."deviceid"}},
      @{Name="devicephonenum";Expression={$_."devicephonenum"}},
      @{Name="ennum";Expression={$_."ennum"}},
      @{Name="ennum_other";Expression={$_."ennum_other"}},
      @{Name="site";Expression={$_."site"}},
      @{Name="indvname";Expression={$_."memberdetails-indvname"}},
      @{Name="hhid";Expression={$_."memberdetails-hhid"}},
      @{Name="line_num";Expression={$_."memberdetails-line_num"}},
      @{Name="hhkey";Expression={$_."hhkey"}},
      @{Name="hhmem_key";Expression={$_."hhmem_key"}},
      @{Name="visit_type";Expression={$_."visit_type"}},
      @{Name="interview_timing";Expression={$_."interview_timing"}},
      @{Name="Q201";Expression={$_."Q201"}},
      @{Name="Q101a";Expression={$_."Q101a"}},
      @{Name="Q101";Expression={$_."Q101"}},
      @{Name="Q102";Expression={$_."Q102"}},
      @{Name="Q102other";Expression={$_."Q102other"}},
      @{Name="Q102date";Expression={$_."Q102date"}},
      @{Name="Q103a";Expression={$_."consented-Q103-Q103a"}},
      @{Name="Q103b";Expression={$_."consented-Q103-Q103b"}},
      @{Name="Q103c";Expression={$_."consented-Q103-Q103c"}},
      @{Name="Q103d";Expression={$_."consented-Q103-Q103d"}},
      @{Name="Q202";Expression={$_."consented-Q202"}},
      @{Name="Q203";Expression={$_."consented-Q203"}},
      @{Name="dobage";Expression={$_."consented-dobage"}},
      @{Name="Q204";Expression={$_."consented-Q204"}},
      @{Name="Q205";Expression={$_."consented-Q205"}},
      @{Name="Q206";Expression={$_."consented-Q206"}},
      @{Name="Q207";Expression={$_."consented-Q207"}},
      @{Name="Q207other";Expression={$_."consented-Q207other"}},
      @{Name="Q208";Expression={$_."consented-Q208"}},
      @{Name="Q208primary";Expression={$_."consented-Q208yrs-Q208primary"}},
      @{Name="Q208secondary";Expression={$_."consented-Q208yrs-Q208secondary"}},
      @{Name="Q208tertiary";Expression={$_."consented-Q208yrs-Q208tertiary"}},
      @{Name="Q209";Expression={$_."consented-Q209"}},
      @{Name="Q210a";Expression={$_."consented-Q210-Q210a"}},
      @{Name="Q210b";Expression={$_."consented-Q210-Q210b"}},
      @{Name="Q210c";Expression={$_."consented-Q210-Q210c"}},
      @{Name="Q211a";Expression={$_."consented-Q211-Q211a"}},
      @{Name="Q211b";Expression={$_."consented-Q211-Q211b"}},
      @{Name="Q211c";Expression={$_."consented-Q211-Q211c"}},
      @{Name="Q212";Expression={$_."consented-Q212"}},
      @{Name="Q213";Expression={$_."consented-Q213"}},
      @{Name="Q213other";Expression={$_."consented-Q213other"}},
      @{Name="Q214";Expression={$_."consented-Q214"}},
      @{Name="Q214other";Expression={$_."consented-Q214other"}},
      @{Name="Q215";Expression={$_."consented-Q215"}},
      @{Name="Q216";Expression={$_."consented-Q216"}},
      @{Name="Q217";Expression={$_."consented-Q217"}},
      @{Name="Q218";Expression={$_."consented-Q218"}},
      @{Name="Q219";Expression={$_."consented-Q219"}},
      @{Name="Q220a";Expression={$_."consented-Q220-Q220a"}},
      @{Name="Q220b";Expression={$_."consented-Q220-Q220b"}},
      @{Name="Q220c";Expression={$_."consented-Q220-Q220c"}},
      @{Name="Q220d";Expression={$_."consented-Q220-Q220d"}},
      @{Name="Q221";Expression={$_."consented-Q221"}},
      @{Name="Q222";Expression={$_."consented-skipped-Q222"}},
      @{Name="Q223";Expression={$_."consented-skipped-Q223"}},
      @{Name="Q224";Expression={$_."consented-skipped-Q224"}},
      @{Name="Q225";Expression={$_."consented-skipped-toQ236-Q225"}},
      @{Name="Q225otherwives";Expression={$_."consented-skipped-toQ236-Q225otherwives"}},
      @{Name="Q236a";Expression={$_."consented-existingroup-Q236a"}},
      @{Name="Q236b";Expression={$_."consented-existingroup-Q236b"}},
      @{Name="Q236c";Expression={$_."consented-existingroup-Q236c"}},
      @{Name="Q236d";Expression={$_."consented-existingroup-Q236d"}},
      @{Name="Q236e";Expression={$_."consented-existingroup-Q236e"}},
      @{Name="Q236f";Expression={$_."consented-existingroup-Q236f"}},
      @{Name="Q236g";Expression={$_."consented-existingroup-Q236g"}},
      @{Name="Q236h";Expression={$_."consented-existingroup-Q236h"}},
      @{Name="Q236i";Expression={$_."consented-existingroup-Q236i"}},
      @{Name="Q236j";Expression={$_."consented-existingroup-Q236j"}},
      @{Name="Q236amem";Expression={$_."consented-memgroup-Q236amem"}},
      @{Name="Q236bmem";Expression={$_."consented-memgroup-Q236bmem"}},
      @{Name="Q236cmem";Expression={$_."consented-memgroup-Q236cmem"}},
      @{Name="Q236dmem";Expression={$_."consented-memgroup-Q236dmem"}},
      @{Name="Q236emem";Expression={$_."consented-memgroup-Q236emem"}},
      @{Name="Q236fmem";Expression={$_."consented-memgroup-Q236fmem"}},
      @{Name="Q236gmem";Expression={$_."consented-memgroup-Q236gmem"}},
      @{Name="Q236hmem";Expression={$_."consented-memgroup-Q236hmem"}},
      @{Name="Q236imem";Expression={$_."consented-memgroup-Q236imem"}},
      @{Name="Q236jmem";Expression={$_."consented-memgroup-Q236jmem"}},
      @{Name="Q236arate";Expression={$_."consented-rategroup-Q236arate"}},
      @{Name="Q236brate";Expression={$_."consented-rategroup-Q236brate"}},
      @{Name="Q236crate";Expression={$_."consented-rategroup-Q236crate"}},
      @{Name="Q236drate";Expression={$_."consented-rategroup-Q236drate"}},
      @{Name="Q236erate";Expression={$_."consented-rategroup-Q236erate"}},
      @{Name="Q236frate";Expression={$_."consented-rategroup-Q236frate"}},
      @{Name="Q236grate";Expression={$_."consented-rategroup-Q236grate"}},
      @{Name="Q236hrate";Expression={$_."consented-rategroup-Q236hrate"}},
      @{Name="Q236irate";Expression={$_."consented-rategroup-Q236irate"}},
      @{Name="Q236jrate";Expression={$_."consented-rategroup-Q236jrate"}},
      @{Name="Q237";Expression={$_."consented-Q237"}},
      @{Name="Q238a";Expression={$_."consented-roles-Q238a"}},
      @{Name="Q238b";Expression={$_."consented-roles-Q238b"}},
      @{Name="Q238c";Expression={$_."consented-roles-Q238c"}},
      @{Name="Q238e";Expression={$_."consented-roles-Q238e"}},
      @{Name="Q238f";Expression={$_."consented-roles-Q238f"}},
      @{Name="Q238g";Expression={$_."consented-roles-Q238g"}},
      @{Name="Q238h";Expression={$_."consented-roles-Q238h"}},
      @{Name="Q238i";Expression={$_."consented-roles-Q238i"}},
      @{Name="Q238j";Expression={$_."consented-roles-Q238j"}},
      @{Name="Q238other";Expression={$_."consented-roles-Q238other"}},
      @{Name="Q239a";Expression={$_."consented-rshipwoman-Q239a"}},
      @{Name="Q239b";Expression={$_."consented-rshipwoman-Q239b"}},
      @{Name="Q239c";Expression={$_."consented-rshipwoman-Q239c"}},
      @{Name="Q239d";Expression={$_."consented-rshipwoman-Q239d"}},
      @{Name="Q239e";Expression={$_."consented-rshipwoman-Q239e"}},
      @{Name="Q240a";Expression={$_."consented-rshipman-Q240a"}},
      @{Name="Q240b";Expression={$_."consented-rshipman-Q240b"}},
      @{Name="Q240c";Expression={$_."consented-rshipman-Q240c"}},
      @{Name="Q240d";Expression={$_."consented-rshipman-Q240d"}},
      @{Name="Q240e";Expression={$_."consented-rshipman-Q240e"}},
      @{Name="indvsignaturelink";Expression={$_."consented-consent_form-consentsignature"}},      
      @{Name="METAKEY";Expression={$_."KEY"}}	    |



      
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
$count = 0 
 
foreach($i in $data){
$SubmissionDate= $i.SubmissionDate
$start= $i.start
$endtime= $i.endtime
$deviceid= $i.deviceid
$devicephonenum= $i.devicephonenum
$ennum= $i.ennum
$ennum_other= $i.ennum_other
$site= $i.site
$indvname=$i.indvname.replace("'","")
$hhid= $i.hhid
$line_num= $i.line_num
$hhkey= $i.hhkey
$hhmem_key= $i.hhmem_key
$visit_type= $i.visit_type
$interview_timing= $i.interview_timing
$Q201= $i.Q201
$Q101a= $i.Q101a
$Q101= $i.Q101
$Q102= $i.Q102
$Q102other= $i.Q102other.replace("'","")
$Q102date= $i.Q102date
$Q103a= $i.Q103a
$Q103b= $i.Q103b
$Q103c= $i.Q103c
$Q103d= $i.Q103d
$Q202= $i.Q202
$Q203= $i.Q203
$dobage= $i.dobage
$Q204= $i.Q204
$Q205= $i.Q205
$Q206= $i.Q206
$Q207= $i.Q207
$Q207other= $i.Q207other.replace("'","")
$Q208= $i.Q208
$Q208primary= $i.Q208primary
$Q208secondary= $i.Q208secondary
$Q208tertiary= $i.Q208tertiary
$Q209= $i.Q209
$Q210a= $i.Q210a
$Q210b= $i.Q210b
$Q210c= $i.Q210c
$Q211a= $i.Q211a
$Q211b= $i.Q211b
$Q211c= $i.Q211c
$Q212= $i.Q212
$Q213= $i.Q213
$Q213other= $i.Q213other.replace("'","")
$Q214= $i.Q214
$Q214other= $i.Q214other.replace("'","")
$Q215= $i.Q215
$Q216= $i.Q216
$Q217= $i.Q217
$Q218= $i.Q218
$Q219= $i.Q219
$Q220a= $i.Q220a
$Q220b= $i.Q220b
$Q220c= $i.Q220c
$Q220d= $i.Q220d
$Q221= $i.Q221
$Q222= $i.Q222
$Q223= $i.Q223
$Q224= $i.Q224
$Q225= $i.Q225
$Q225otherwives= $i.Q225otherwives.replace("'","")
$Q236a= $i.Q236a
$Q236b= $i.Q236b
$Q236c= $i.Q236c
$Q236d= $i.Q236d
$Q236e= $i.Q236e
$Q236f= $i.Q236f
$Q236g= $i.Q236g
$Q236h= $i.Q236h
$Q236i= $i.Q236i
$Q236j= $i.Q236j
$Q236amem= $i.Q236amem
$Q236bmem= $i.Q236bmem
$Q236cmem= $i.Q236cmem
$Q236dmem= $i.Q236dmem
$Q236emem= $i.Q236emem
$Q236fmem= $i.Q236fmem
$Q236gmem= $i.Q236gmem
$Q236hmem= $i.Q236hmem
$Q236imem= $i.Q236imem
$Q236jmem= $i.Q236jmem
$Q236arate= $i.Q236arate
$Q236brate= $i.Q236brate
$Q236crate= $i.Q236crate
$Q236drate= $i.Q236drate
$Q236erate= $i.Q236erate
$Q236frate= $i.Q236frate
$Q236grate= $i.Q236grate
$Q236hrate= $i.Q236hrate
$Q236irate= $i.Q236irate
$Q236jrate= $i.Q236jrate
$Q237= $i.Q237
$Q238a= $i.Q238a
$Q238b= $i.Q238b
$Q238c= $i.Q238c
$Q238e= $i.Q238e
$Q238f= $i.Q238f
$Q238g= $i.Q238g
$Q238h= $i.Q238h
$Q238i= $i.Q238i
$Q238j= $i.Q238j
$Q238other= $i.Q238other.replace("'","")
$Q239a= $i.Q239a
$Q239b= $i.Q239b
$Q239c= $i.Q239c
$Q239d= $i.Q239d
$Q239e= $i.Q239e
$Q240a= $i.Q240a
$Q240b= $i.Q240b
$Q240c= $i.Q240c
$Q240d= $i.Q240d
$Q240e= $i.Q240e
$METAKEY= $i.METAKEY
$indvsignaturelink=$i.indvsignaturelink

$SQLQuery = "INSERT INTO backchar_7 (SubmissionDate,
start,
endtime,
deviceid,
devicephonenum,
ennum,
ennum_other,
site,
hhid,
line_num,
hhkey,
hhmem_key,
visit_type,
interview_timing,
Q201,
Q101a,
Q101,
Q102,
Q102other,
Q102date,
Q103a,
Q103b,
Q103c,
Q103d,
Q202,
Q203,
dobage,
Q204,
Q205,
Q206,
Q207,
Q207other,
Q208,
Q208primary,
Q208secondary,
Q208tertiary,
Q209,
Q210a,
Q210b,
Q210c,
Q211a,
Q211b,
Q211c,
Q212,
Q213,
Q213other,
Q214,
Q214other,
Q215,
Q216,
Q217,
Q218,
Q219,
Q220a,
Q220b,
Q220c,
Q220d,
Q221,
Q222,
Q223,
Q224,
Q225,
Q225otherwives,
Q236a,
Q236b,
Q236c,
Q236d,
Q236e,
Q236f,
Q236g,
Q236h,
Q236i,
Q236j,
Q236amem,
Q236bmem,
Q236cmem,
Q236dmem,
Q236emem,
Q236fmem,
Q236gmem,
Q236hmem,
Q236imem,
Q236jmem,
Q236arate,
Q236brate,
Q236crate,
Q236drate,
Q236erate,
Q236frate,
Q236grate,
Q236hrate,
Q236irate,
Q236jrate,
Q237,
Q238a,
Q238b,
Q238c,
Q238e,
Q238f,
Q238g,
Q238h,
Q238i,
Q238j,
Q238other,
Q239a,
Q239b,
Q239c,
Q239d,
Q239e,
Q240a,
Q240b,
Q240c,
Q240d,
Q240e,METAKEY,signaturelink )    VALUES ('$SubmissionDate',
'$start',
'$endtime',
'$deviceid',
'$devicephonenum',
'$ennum',
'$ennum_other',
'$site',
'$hhid',
'$line_num',
'$hhkey',
'$hhmem_key',
'$visit_type',
'$interview_timing',
'$Q201',
'$Q101a',
'$Q101',
'$Q102',
'$Q102other',
'$Q102date',
'$Q103a',
'$Q103b',
'$Q103c',
'$Q103d',
'$Q202',
'$Q203',
'$dobage',
'$Q204',
'$Q205',
'$Q206',
'$Q207',
'$Q207other',
'$Q208',
'$Q208primary',
'$Q208secondary',
'$Q208tertiary',
'$Q209',
'$Q210a',
'$Q210b',
'$Q210c',
'$Q211a',
'$Q211b',
'$Q211c',
'$Q212',
'$Q213',
'$Q213other',
'$Q214',
'$Q214other',
'$Q215',
'$Q216',
'$Q217',
'$Q218',
'$Q219',
'$Q220a',
'$Q220b',
'$Q220c',
'$Q220d',
'$Q221',
'$Q222',
'$Q223',
'$Q224',
'$Q225',
'$Q225otherwives',
'$Q236a',
'$Q236b',
'$Q236c',
'$Q236d',
'$Q236e',
'$Q236f',
'$Q236g',
'$Q236h',
'$Q236i',
'$Q236j',
'$Q236amem',
'$Q236bmem',
'$Q236cmem',
'$Q236dmem',
'$Q236emem',
'$Q236fmem',
'$Q236gmem',
'$Q236hmem',
'$Q236imem',
'$Q236jmem',
'$Q236arate',
'$Q236brate',
'$Q236crate',
'$Q236drate',
'$Q236erate',
'$Q236frate',
'$Q236grate',
'$Q236hrate',
'$Q236irate',
'$Q236jrate',
'$Q237',
'$Q238a',
'$Q238b',
'$Q238c',
'$Q238e',
'$Q238f',
'$Q238g',
'$Q238h',
'$Q238i',
'$Q238j',
'$Q238other',
'$Q239a',
'$Q239b',
'$Q239c',
'$Q239d',
'$Q239e',
'$Q240a',
'$Q240b',
'$Q240c',
'$Q240d',
'$Q240e','$METAKEY','$indvsignaturelink')"


 $impcsv = invoke-sqlcmd -Username $LocalDatabaseUser -Password $LocalDatabasePWD -Database $LocalDatabaseName -Query $SQLQuery  -serverinstance $LocalSQLServerInstance  
        $InfoMessage = "IVQ memID $hhmem_key successfully uploaded to YZ-UHP Local MSSSQL Server."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 
 $InfoMessage = "Successfully imported $count Backchar  Qstns into the YZ-UHP database" 
 Write-Log -Message $InfoMessage -Path $LogFile   -Level Info

}

Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    
    Write-Log -Message "System encountered an error trying to post into the local database. System returned error : $ErrorMessage" -Path $LogFile -Level Error
}



# <#########################   IMPORT INTERVIEW IDENTIFIERS INTO THE LOCAL DATABASE ############################################################>

 Try
 {
 # Now lets process the CSV to import identifiers
$count = 0 
 
foreach($i in $data){

$start= $i.start
$indvname=$i.indvname.replace("'","")
$Q101= $i.Q101
$METAKEY= $i.METAKEY

$SQLQuery = "INSERT INTO ivqnames (
ivqdate,
indvname,
consent,
METAKEY )    VALUES (
'$start',
'$indvname',
'$Q101',
'$METAKEY')"


 $impcsv = invoke-sqlcmd -Username $LocalDatabaseUser -Password $LocalDatabasePWD -Database $LocalDatabaseName -Query $SQLQuery  -serverinstance $LocalSQLServerInstance  
        $InfoMessage = "Household memID $hhmem_key successfully uploaded to YZ-UHP Local MSSSQL Server."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 
 $InfoMessage = "Successfully imported $count Participant Identifiers in the Identifiers Table Local YZ-UHP database" 
 Write-Log -Message $InfoMessage -Path $LogFile   -Level Info

}

Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    
    Write-Log -Message "System encountered an error trying to post into the local database. System returned error : $ErrorMessage" -Path $LogFile -Level Error
}
# END OF LOCAL IDENTIFIER PROCESSING



Try
{

<#   ############################## UPLOADING TO THE CLOUD DATABASE #####################################################>
# Now lets import the CSV we have formmated  to the more friendly format. This is the data that will eventually get into the database
$data = import-csv $FormattedCSVFile -ErrorAction Stop
$InfoMessage = "Starting upload of data to the Cloud Database" 
Write-Log -Message $InfoMessage -Path $LogFile -Level Info

 # Now lets process the CSV
 $count = 0 
 
foreach($i in $data){
$SubmissionDate= $i.SubmissionDate
$start= $i.start
$endtime= $i.endtime
$deviceid= $i.deviceid
$devicephonenum= $i.devicephonenum
$ennum= $i.ennum
$ennum_other= $i.ennum_other
$site= $i.site
$indvname=$i.indvname.replace("'","")
$hhid= $i.hhid
$line_num= $i.line_num
$hhkey= $i.hhkey
$hhmem_key= $i.hhmem_key
$visit_type= $i.visit_type
$interview_timing= $i.interview_timing
$Q201= $i.Q201
$Q101a= $i.Q101a
$Q101= $i.Q101
$Q102= $i.Q102
$Q102other= $i.Q102other.replace("'","")
$Q102date= $i.Q102date
$Q103a= $i.Q103a
$Q103b= $i.Q103b
$Q103c= $i.Q103c
$Q103d= $i.Q103d
$Q202= $i.Q202
$Q203= $i.Q203
$dobage= $i.dobage
$Q204= $i.Q204
$Q205= $i.Q205
$Q206= $i.Q206
$Q207= $i.Q207
$Q207other= $i.Q207other.replace("'","")
$Q208= $i.Q208
$Q208primary= $i.Q208primary
$Q208secondary= $i.Q208secondary
$Q208tertiary= $i.Q208tertiary
$Q209= $i.Q209
$Q210a= $i.Q210a
$Q210b= $i.Q210b
$Q210c= $i.Q210c
$Q211a= $i.Q211a
$Q211b= $i.Q211b
$Q211c= $i.Q211c
$Q212= $i.Q212
$Q213= $i.Q213
$Q213other= $i.Q213other.replace("'","")
$Q214= $i.Q214
$Q214other= $i.Q214other.replace("'","")
$Q215= $i.Q215
$Q216= $i.Q216
$Q217= $i.Q217
$Q218= $i.Q218
$Q219= $i.Q219
$Q220a= $i.Q220a
$Q220b= $i.Q220b
$Q220c= $i.Q220c
$Q220d= $i.Q220d
$Q221= $i.Q221
$Q222= $i.Q222
$Q223= $i.Q223
$Q224= $i.Q224
$Q225= $i.Q225
$Q225otherwives= $i.Q225otherwives.replace("'","")
$Q236a= $i.Q236a
$Q236b= $i.Q236b
$Q236c= $i.Q236c
$Q236d= $i.Q236d
$Q236e= $i.Q236e
$Q236f= $i.Q236f
$Q236g= $i.Q236g
$Q236h= $i.Q236h
$Q236i= $i.Q236i
$Q236j= $i.Q236j
$Q236amem= $i.Q236amem
$Q236bmem= $i.Q236bmem
$Q236cmem= $i.Q236cmem
$Q236dmem= $i.Q236dmem
$Q236emem= $i.Q236emem
$Q236fmem= $i.Q236fmem
$Q236gmem= $i.Q236gmem
$Q236hmem= $i.Q236hmem
$Q236imem= $i.Q236imem
$Q236jmem= $i.Q236jmem
$Q236arate= $i.Q236arate
$Q236brate= $i.Q236brate
$Q236crate= $i.Q236crate
$Q236drate= $i.Q236drate
$Q236erate= $i.Q236erate
$Q236frate= $i.Q236frate
$Q236grate= $i.Q236grate
$Q236hrate= $i.Q236hrate
$Q236irate= $i.Q236irate
$Q236jrate= $i.Q236jrate
$Q237= $i.Q237
$Q238a= $i.Q238a
$Q238b= $i.Q238b
$Q238c= $i.Q238c
$Q238e= $i.Q238e
$Q238f= $i.Q238f
$Q238g= $i.Q238g
$Q238h= $i.Q238h
$Q238i= $i.Q238i
$Q238j= $i.Q238j
$Q238other= $i.Q238other.replace("'","")
$Q239a= $i.Q239a
$Q239b= $i.Q239b
$Q239c= $i.Q239c
$Q239d= $i.Q239d
$Q239e= $i.Q239e
$Q240a= $i.Q240a
$Q240b= $i.Q240b
$Q240c= $i.Q240c
$Q240d= $i.Q240d
$Q240e= $i.Q240e
$METAKEY= $i.METAKEY
$indvsignaturelink=$i.indvsignaturelink



$SQLQuery = "INSERT INTO backchar_7 (SubmissionDate,
start,
endtime,
deviceid,
devicephonenum,
ennum,
ennum_other,
site,
hhid,
line_num,
hhkey,
hhmem_key,
visit_type,
interview_timing,
Q201,
Q101a,
Q101,
Q102,
Q102other,
Q102date,
Q103a,
Q103b,
Q103c,
Q103d,
Q202,
Q203,
dobage,
Q204,
Q205,
Q206,
Q207,
Q207other,
Q208,
Q208primary,
Q208secondary,
Q208tertiary,
Q209,
Q210a,
Q210b,
Q210c,
Q211a,
Q211b,
Q211c,
Q212,
Q213,
Q213other,
Q214,
Q214other,
Q215,
Q216,
Q217,
Q218,
Q219,
Q220a,
Q220b,
Q220c,
Q220d,
Q221,
Q222,
Q223,
Q224,
Q225,
Q225otherwives,
Q236a,
Q236b,
Q236c,
Q236d,
Q236e,
Q236f,
Q236g,
Q236h,
Q236i,
Q236j,
Q236amem,
Q236bmem,
Q236cmem,
Q236dmem,
Q236emem,
Q236fmem,
Q236gmem,
Q236hmem,
Q236imem,
Q236jmem,
Q236arate,
Q236brate,
Q236crate,
Q236drate,
Q236erate,
Q236frate,
Q236grate,
Q236hrate,
Q236irate,
Q236jrate,
Q237,
Q238a,
Q238b,
Q238c,
Q238e,
Q238f,
Q238g,
Q238h,
Q238i,
Q238j,
Q238other,
Q239a,
Q239b,
Q239c,
Q239d,
Q239e,
Q240a,
Q240b,
Q240c,
Q240d,
Q240e,METAKEY,signaturelink )    VALUES ('$SubmissionDate',
'$start',
'$endtime',
'$deviceid',
'$devicephonenum',
'$ennum',
'$ennum_other',
'$site',
'$hhid',
'$line_num',
'$hhkey',
'$hhmem_key',
'$visit_type',
'$interview_timing',
'$Q201',
'$Q101a',
'$Q101',
'$Q102',
'$Q102other',
'$Q102date',
'$Q103a',
'$Q103b',
'$Q103c',
'$Q103d',
'$Q202',
'$Q203',
'$dobage',
'$Q204',
'$Q205',
'$Q206',
'$Q207',
'$Q207other',
'$Q208',
'$Q208primary',
'$Q208secondary',
'$Q208tertiary',
'$Q209',
'$Q210a',
'$Q210b',
'$Q210c',
'$Q211a',
'$Q211b',
'$Q211c',
'$Q212',
'$Q213',
'$Q213other',
'$Q214',
'$Q214other',
'$Q215',
'$Q216',
'$Q217',
'$Q218',
'$Q219',
'$Q220a',
'$Q220b',
'$Q220c',
'$Q220d',
'$Q221',
'$Q222',
'$Q223',
'$Q224',
'$Q225',
'$Q225otherwives',
'$Q236a',
'$Q236b',
'$Q236c',
'$Q236d',
'$Q236e',
'$Q236f',
'$Q236g',
'$Q236h',
'$Q236i',
'$Q236j',
'$Q236amem',
'$Q236bmem',
'$Q236cmem',
'$Q236dmem',
'$Q236emem',
'$Q236fmem',
'$Q236gmem',
'$Q236hmem',
'$Q236imem',
'$Q236jmem',
'$Q236arate',
'$Q236brate',
'$Q236crate',
'$Q236drate',
'$Q236erate',
'$Q236frate',
'$Q236grate',
'$Q236hrate',
'$Q236irate',
'$Q236jrate',
'$Q237',
'$Q238a',
'$Q238b',
'$Q238c',
'$Q238e',
'$Q238f',
'$Q238g',
'$Q238h',
'$Q238i',
'$Q238j',
'$Q238other',
'$Q239a',
'$Q239b',
'$Q239c',
'$Q239d',
'$Q239e',
'$Q240a',
'$Q240b',
'$Q240c',
'$Q240d',
'$Q240e','$METAKEY','$indvsignaturelink')"


 
       # Cloud Database Settings
        $impcsv = invoke-sqlcmd -Username $CloudDatabaseUser -Password $CloudDatabasePWD -Database $CloudDatabaseName -Query $SQLQuery  -serverinstance $CloudSQLServerInstance  
        $InfoMessage = "IVQ memID $hhmem_key successfully uploaded to Cloud YZ-UHP database on SmarterASP."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 


 $InfoMessage = "Successfully imported $count Backchar Qstns into the YZ-UHP CLOUD database" 
 Write-Log -Message $InfoMessage -Path $LogFile   -Level Info

 

$InfoMessage = "Qstns Data upload completed"
}

Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    
    Write-Log -Message "Error : Upload to Cloud database failed with the error : $ErrorMessage" -Path $LogFile -Level Error
}


# <#########################   IMPORT INTERVIEW IDENTIFIERS INTO THE CLOUD DATABASE ############################################################>

 Try
 {
 # Now lets process the CSV to import identifiers
$count = 0 
 
foreach($i in $data){

$start= $i.start
$indvname=$i.indvname.replace("'","")
$Q101= $i.Q101
$METAKEY= $i.METAKEY

$SQLQuery = "INSERT INTO ivqnames (
ivqdate,
indvname,
consent,
METAKEY )    VALUES (
'$start',
'$indvname',
'$Q101',
'$METAKEY')"


 
       # Cloud Database Settings
        $impcsv = invoke-sqlcmd -Username $CloudDatabaseUser -Password $CloudDatabasePWD -Database $CloudDatabaseName -Query $SQLQuery  -serverinstance $CloudSQLServerInstance  
        $InfoMessage = "$METAKEY processed successfully to Cloud YZ-UHP database on SmarterASP."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 
 $InfoMessage = "Successfully imported $count Participant Identifiers in the Identifiers Table Cloud YZ-UHP database" 
 Write-Log -Message $InfoMessage -Path $LogFile   -Level Info

}

Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    
    Write-Log -Message "System encountered an error trying to post into the local database. System returned error : $ErrorMessage" -Path $LogFile -Level Error
}
# END OF LOCAL IDENTIFIER PROCESSING



