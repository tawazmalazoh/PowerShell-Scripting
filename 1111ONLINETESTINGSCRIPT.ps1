
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
$FormattedCSVFile = 'C:\DATA\Briefcase\Formatted\testing_7.csv'
$RawBackupFolder = 'C:\DATA\Briefcase\Backup\Raw\ivq\'
$FormattedBackupFolder = 'C:\DATA\Briefcase\Backup\Formatted\ivq\'
$LogFileFolder = 'C:\DATA\Briefcase\Log\'

#Local Database Connection
$LocalSQLServerInstance = '.\SQLEXPRESS'
$LocalDatabaseName = 'YZUHP'
$LocalDatabaseUser = 'sa'
$LocalDatabasePWD = 'Adm!n123'

#Cloud Database Connection Settings
#Cloud Database Connection Settings
$CloudSQLServerInstance = 
$CloudDatabaseName =
$CloudDatabaseUser = 
$CloudDatabasePWD =

# Database Table. Has to be identical table in both Databases
$DatabaseTable = 'testing_7'

# Lets create a Log file to log the events that will be happening today. Generate log file with current date.
$date = Get-Date -UFormat "%Y%m%d"
$LogFile = $LogFileFolder+'log-'+$date+'-testing_7.log'

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
      @{Name="Q301";Expression={$_."consented-bothered-Q301"}},
      @{Name="Q302";Expression={$_."consented-bothered-Q302"}},
      @{Name="Q303";Expression={$_."consented-bothered-Q303"}},
      @{Name="Q304";Expression={$_."consented-bothered-Q304"}},
      @{Name="Q305";Expression={$_."consented-bothered-Q305"}},
      @{Name="Q306";Expression={$_."consented-bothered-Q306"}},
      @{Name="Q307";Expression={$_."consented-bothered-Q307"}},
      @{Name="Q308";Expression={$_."consented-bothered-Q308"}},
      @{Name="Q309";Expression={$_."consented-bothered-Q309"}},
      @{Name="Q310";Expression={$_."consented-Q310"}},
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
$Q301= $i.Q301
$Q302= $i.Q302
$Q303= $i.Q303
$Q304= $i.Q304
$Q305= $i.Q305
$Q306= $i.Q306
$Q307= $i.Q307
$Q308= $i.Q308
$Q309= $i.Q309
$Q310= $i.Q310
$METAKEY= $i.METAKEY

$SQLQuery = "INSERT INTO testing_7 (hhkey,
hhmem_key,
Q301,
Q302,
Q303,
Q304,
Q305,
Q306,
Q307,
Q308,
Q309,
Q310,
METAKEY)   VALUES ('$hhkey',
'$hhmem_key',
'$Q301',
'$Q302',
'$Q303',
'$Q304',
'$Q305',
'$Q306',
'$Q307',
'$Q308',
'$Q309',
'$Q310',
'$METAKEY')"


  $impcsv = invoke-sqlcmd -Username $LocalDatabaseUser -Password $LocalDatabasePWD -Database $LocalDatabaseName -Query $SQLQuery  -serverinstance $LocalSQLServerInstance  
        $InfoMessage = "Household memID $hhmem_key successfully uploaded to YZ-UHP Local MSSSQL Server."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 
 $InfoMessage = "Successfully imported $count testing_7 Qstns into the YZ-UHP database" 
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
$Q301= $i.Q301
$Q302= $i.Q302
$Q303= $i.Q303
$Q304= $i.Q304
$Q305= $i.Q305
$Q306= $i.Q306
$Q307= $i.Q307
$Q308= $i.Q308
$Q309= $i.Q309
$Q310= $i.Q310
$METAKEY= $i.METAKEY

$SQLQuery = "INSERT INTO testing_7 (hhkey,
hhmem_key,
Q301,
Q302,
Q303,
Q304,
Q305,
Q306,
Q307,
Q308,
Q309,
Q310,
METAKEY)   VALUES ('$hhkey',
'$hhmem_key',
'$Q301',
'$Q302',
'$Q303',
'$Q304',
'$Q305',
'$Q306',
'$Q307',
'$Q308',
'$Q309',
'$Q310',
'$METAKEY')"

  # Cloud Database Settings
        $impcsv = invoke-sqlcmd -Username $CloudDatabaseUser -Password $CloudDatabasePWD -Database $CloudDatabaseName -Query $SQLQuery  -serverinstance $CloudSQLServerInstance  
        $InfoMessage = "Household memID $hhmem_key successfully uploaded to Cloud YZ-UHP database on SmarterASP."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 

 $InfoMessage = "Successfully imported $count testing_7 Qstns into the YZ-UHP CLOUD database" 
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
 





