

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
$FormattedCSVFile = 'C:\DATA\Briefcase\Formatted\sexrels_7.csv'
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
$DatabaseTable = 'sexrels_7'


# Lets create a Log file to log the events that will be happening today. Generate log file with current date.
$date = Get-Date -UFormat "%Y%m%d"
$LogFile = $LogFileFolder+'log-'+$date+'-sexrels_7.log'



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
      @{Name="Q401";Expression={$_."consented-Q401"}},
      @{Name="Q402";Expression={$_."consented-Q402"}},
      @{Name="Q403";Expression={$_."consented-Q403"}},
      @{Name="Q403other";Expression={$_."consented-Q403other"}},
      @{Name="Q404";Expression={$_."consented-nosex-Q404"}},
      @{Name="Q405";Expression={$_."consented-nosex-Q405"}},
      @{Name="Q405other";Expression={$_."consented-nosex-Q405other"}},
      @{Name="Q406";Expression={$_."consented-nosex-Q406"}},
      @{Name="Q407";Expression={$_."consented-nosex-Q407"}},
      @{Name="Q408new";Expression={$_."consented-nosex-Q408new"}},
      @{Name="Q409";Expression={$_."consented-nosex-Q409"}},
      @{Name="Q410";Expression={$_."consented-nosex-Q410"}},
      @{Name="Q411";Expression={$_."consented-nosex-Q411"}},
      @{Name="Q412";Expression={$_."consented-nosex-Q412"}},
      @{Name="Q413";Expression={$_."consented-nosex-Q413"}},
      @{Name="Q414";Expression={$_."consented-nosex-Q414"}},
      @{Name="Q415";Expression={$_."consented-nosex-Q415"}},
      @{Name="Q416";Expression={$_."consented-nosex-Q416"}},
      @{Name="Q417";Expression={$_."consented-nosex-Q417"}},
      @{Name="sumpartners";Expression={$_."consented-nosex-sumpartners"}},
      @{Name="Q414retake";Expression={$_."consented-nosex-retakeQ414-Q414retake"}},
      @{Name="Q416retake";Expression={$_."consented-nosex-retakeQ414-Q416retake"}},
      @{Name="Q417retake";Expression={$_."consented-nosex-retakeQ414-Q417retake"}},
      @{Name="Q418";Expression={$_."consented-nosex-Q418"}},
      @{Name="Q419";Expression={$_."consented-nosex-Q419"}},
      @{Name="Q420";Expression={$_."consented-nosex-Q420"}},
      @{Name="Q432";Expression={$_."consented-nosex-Q432"}},
      @{Name="Q433";Expression={$_."consented-nosex-Q433"}},
      @{Name="Q434";Expression={$_."consented-nosex-Q434"}},
      @{Name="Q435a";Expression={$_."consented-otherspresent-Q435a"}},
      @{Name="Q435b";Expression={$_."consented-otherspresent-Q435b"}},
      @{Name="Q435c";Expression={$_."consented-otherspresent-Q435c"}},
      @{Name="Q435d";Expression={$_."consented-otherspresent-Q435d"}},
      @{Name="METAKEY";Expression={$_."KEY"}}    |

                              

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
$Q401= $i.Q401
$Q402= $i.Q402
$Q403= $i.Q403
$Q403other= $i.Q403other.replace("'","")
$Q404= $i.Q404
$Q405= $i.Q405
$Q405other= $i.Q405other.replace("'","")
$Q406= $i.Q406
$Q407= $i.Q407
$Q408new= $i.Q408new
$Q409= $i.Q409
$Q410= $i.Q410
$Q411= $i.Q411
$Q412= $i.Q412
$Q413= $i.Q413
$Q414= $i.Q414
$Q415= $i.Q415
$Q416= $i.Q416
$Q417= $i.Q417
$sumpartners= $i.sumpartners
$Q414retake= $i.Q414retake
$Q416retake= $i.Q416retake
$Q417retake= $i.Q417retake
$Q418= $i.Q418
$Q419= $i.Q419
$Q420= $i.Q420
$Q432= $i.Q432
$Q433= $i.Q433
$Q434= $i.Q434
$Q435a= $i.Q435a
$Q435b= $i.Q435b
$Q435c= $i.Q435c
$Q435d= $i.Q435d
$METAKEY= $i.METAKEY


$SQLQuery = "INSERT INTO sexrels_7 (hhkey,
hhmem_key,
Q401,
Q402,
Q403,
Q403other,
Q404,
Q405,
Q405other,
Q406,
Q407,
Q408new,
Q409,
Q410,
Q411,
Q412,
Q413,
Q414,
Q415,
Q416,
Q417,
sumpartners,
Q414retake,
Q416retake,
Q417retake,
Q418,
Q419,
Q420,
Q432,
Q433,
Q434,
Q435a,
Q435b,
Q435c,
Q435d,
METAKEY)   VALUES ( '$hhkey',
'$hhmem_key',
'$Q401',
'$Q402',
'$Q403',
'$Q403other',
'$Q404',
'$Q405',
'$Q405other',
'$Q406',
'$Q407',
'$Q408new',
'$Q409',
'$Q410',
'$Q411',
'$Q412',
'$Q413',
'$Q414',
'$Q415',
'$Q416',
'$Q417',
'$sumpartners',
'$Q414retake',
'$Q416retake',
'$Q417retake',
'$Q418',
'$Q419',
'$Q420',
'$Q432',
'$Q433',
'$Q434',
'$Q435a',
'$Q435b',
'$Q435c',
'$Q435d',
'$METAKEY')"  



 $impcsv = invoke-sqlcmd -Username $LocalDatabaseUser -Password $LocalDatabasePWD -Database $LocalDatabaseName -Query $SQLQuery  -serverinstance $LocalSQLServerInstance  
        $InfoMessage = "Household memID $hhmem_key successfully uploaded to YZ-UHP Local MSSSQL Server."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 
 $InfoMessage = "Successfully imported $count SexRels  Qstns into the YZ-UHP database" 
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
$Q401= $i.Q401
$Q402= $i.Q402
$Q403= $i.Q403
$Q403other= $i.Q403other.replace("'","")
$Q404= $i.Q404
$Q405= $i.Q405
$Q405other= $i.Q405other.replace("'","")
$Q406= $i.Q406
$Q407= $i.Q407
$Q408new = $i.Q408new
$Q409= $i.Q409
$Q410= $i.Q410
$Q411= $i.Q411
$Q412= $i.Q412
$Q413= $i.Q413
$Q414= $i.Q414
$Q415= $i.Q415
$Q416= $i.Q416
$Q417= $i.Q417
$sumpartners= $i.sumpartners
$Q414retake= $i.Q414retake
$Q416retake= $i.Q416retake
$Q417retake= $i.Q417retake
$Q418= $i.Q418
$Q419= $i.Q419
$Q420= $i.Q420
$Q432= $i.Q432
$Q433= $i.Q433
$Q434= $i.Q434
$Q435a= $i.Q435a
$Q435b= $i.Q435b
$Q435c= $i.Q435c
$Q435d= $i.Q435d
$METAKEY= $i.METAKEY


$SQLQuery = "INSERT INTO sexrels_7 (hhkey,
hhmem_key,
Q401,
Q402,
Q403,
Q403other,
Q404,
Q405,
Q405other,
Q406,
Q407,
Q408new,
Q409,
Q410,
Q411,
Q412,
Q413,
Q414,
Q415,
Q416,
Q417,
sumpartners,
Q414retake,
Q416retake,
Q417retake,
Q418,
Q419,
Q420,
Q432,
Q433,
Q434,
Q435a,
Q435b,
Q435c,
Q435d,
METAKEY)   VALUES ( '$hhkey',
'$hhmem_key',
'$Q401',
'$Q402',
'$Q403',
'$Q403other',
'$Q404',
'$Q405',
'$Q405other',
'$Q406',
'$Q407',
'$Q408new',
'$Q409',
'$Q410',
'$Q411',
'$Q412',
'$Q413',
'$Q414',
'$Q415',
'$Q416',
'$Q417',
'$sumpartners',
'$Q414retake',
'$Q416retake',
'$Q417retake',
'$Q418',
'$Q419',
'$Q420',
'$Q432',
'$Q433',
'$Q434',
'$Q435a',
'$Q435b',
'$Q435c',
'$Q435d',
'$METAKEY')"

 # Cloud Database Settings
        $impcsv = invoke-sqlcmd -Username $CloudDatabaseUser -Password $CloudDatabasePWD -Database $CloudDatabaseName -Query $SQLQuery  -serverinstance $CloudSQLServerInstance  
        $InfoMessage = "Household memID $hhmem_key successfully uploaded to Cloud YZ-UHP database on SmarterASP."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 


 $InfoMessage = "Successfully imported $count SexRels Qstns into the YZ-UHP CLOUD database" 
 Write-Log -Message $InfoMessage -Path $LogFile   -Level Info

 

$InfoMessage = "Qstns Data upload completed"
}



Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    
    Write-Log -Message "Error : Upload to Cloud database failed with the error : $ErrorMessage" -Path $LogFile -Level Error
}








