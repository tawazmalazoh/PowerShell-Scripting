
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
$SourceCSVFile = 'C:\DATA\Briefcase\BriefcaseDownloads\Household_Questionnaire-EligibleMembers.csv'
$FormattedCSVFile = 'C:\DATA\Briefcase\Formatted\hhelig_7.csv'
$RawBackupFolder = 'C:\DATA\Briefcase\Backup\Raw\hh\'
$FormattedBackupFolder = 'C:\DATA\Briefcase\Backup\Formatted\hh\'
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
$DatabaseTable = 'hhelig_7'


# Lets create a Log file to log the events that will be happening today. Generate log file with current date.
$date = Get-Date -UFormat "%Y%m%d"
$LogFile = $LogFileFolder+'log-'+$date+'-hhelig_7.log'



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

Select  -Property   @{Name="PartID";Expression={$_."PartID"}},
@{Name="hhmem_key";Expression={$_."PartKey"}},
@{Name="PartName";Expression={$_."PartName"}},
@{Name="PartGender";Expression={$_."PartGender"}},
@{Name="PartAge";Expression={$_."PartAge"}},
@{Name="PartPhone";Expression={$_."PartPhone"}},
@{Name="EligibilityOutcome";Expression={$_."EligibilityOutcome"}},
@{Name="EligibilityGroup";Expression={$_."EligibilityGroup"}},
@{Name="line_num";Expression={$_."PartLineNumber"}},
@{Name="appntmt_7";Expression={$_."hhmember_ivq_appntmt_7"}},
@{Name="PARENT_KEY";Expression={$_."PARENT_KEY"}},
@{Name="METAKEY";Expression={$_."KEY"}} |

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
$PartID= $i.PartID 
$hhmem_key= $i.hhmem_key 
$PartName= $i.PartName.replace("'","")
$PartGender= $i.PartGender 
$PartAge= $i.PartAge 
$PartPhone= $i.PartPhone 
$EligibilityOutcome= $i.EligibilityOutcome 
$EligibilityGroup= $i.EligibilityGroup 
$line_num= $i.line_num 
$appntmt_7= $i.appntmt_7 
$PARENT_KEY= $i.PARENT_KEY 
$METAKEY= $i.METAKEY 

$SQLQuery = "INSERT INTO hhelig_7 (PartID ,
 hhmem_key ,
 PartName ,
 PartGender ,
 PartAge , 
 PartPhone ,
 EligibilityOutcome ,
 EligibilityGroup ,
 line_num , 
 appntmt_7 ,
 PARENT_KEY ,
 METAKEY)   VALUES ( '$PartID',
 '$hhmem_key',
 '$PartName',
 '$PartGender',
 '$PartAge', 
 '$PartPhone',
 '$EligibilityOutcome',
 '$EligibilityGroup',
 '$line_num', 
 '$appntmt_7',
 '$PARENT_KEY',
 '$METAKEY')"



 $impcsv = invoke-sqlcmd -Username $LocalDatabaseUser -Password $LocalDatabasePWD -Database $LocalDatabaseName -Query $SQLQuery  -serverinstance $LocalSQLServerInstance  
        $InfoMessage = "Household memID $hhmem_key successfully uploaded to YZ-UHP Local MSSSQL Server."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 
 $InfoMessage = "Successfully imported $count HHElig  Qstns into the YZ-UHP database" 
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
$PartID= $i.PartID 
$hhmem_key= $i.hhmem_key 
$PartName= $i.PartName.replace("'","")
$PartGender= $i.PartGender 
$PartAge= $i.PartAge 
$PartPhone= $i.PartPhone 
$EligibilityOutcome= $i.EligibilityOutcome 
$EligibilityGroup= $i.EligibilityGroup 
$line_num= $i.line_num 
$appntmt_7= $i.appntmt_7 
$PARENT_KEY= $i.PARENT_KEY 
$METAKEY= $i.METAKEY 

$SQLQuery = "INSERT INTO hhelig_7 (PartID ,
 hhmem_key ,
 PartName ,
 PartGender ,
 PartAge , 
 PartPhone ,
 EligibilityOutcome ,
 EligibilityGroup ,
 line_num , 
 appntmt_7 ,
 PARENT_KEY ,
 METAKEY)   VALUES ( '$PartID',
 '$hhmem_key',
 '$PartName',
 '$PartGender',
 '$PartAge', 
 '$PartPhone',
 '$EligibilityOutcome',
 '$EligibilityGroup',
 '$line_num', 
 '$appntmt_7',
 '$PARENT_KEY',
 '$METAKEY')"


 
       # Cloud Database Settings
        $impcsv = invoke-sqlcmd -Username $CloudDatabaseUser -Password $CloudDatabasePWD -Database $CloudDatabaseName -Query $SQLQuery  -serverinstance $CloudSQLServerInstance  
        $InfoMessage = "Household memID $hhmem_key successfully uploaded to Cloud YZ-UHP database on SmarterASP."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 


 $InfoMessage = "Successfully imported $count HHElig Qstns into the YZ-UHP CLOUD database" 
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

