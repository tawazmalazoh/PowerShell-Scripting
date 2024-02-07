
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
$FormattedCSVFile = 'C:\DATA\Briefcase\Formatted\hivaware_7.csv'
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
$DatabaseTable = 'hivaware_7'


# Lets create a Log file to log the events that will be happening today. Generate log file with current date.
$date = Get-Date -UFormat "%Y%m%d"
$LogFile = $LogFileFolder+'log-'+$date+'-hivaware_7.log'



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
      @{Name="Q601";Expression={$_."consented-Q601"}},
      @{Name="Q602a";Expression={$_."consented-Q602-Q602a"}},
      @{Name="Q602b";Expression={$_."consented-Q602-Q602b"}},
      @{Name="Q602c";Expression={$_."consented-Q602-Q602c"}},
      @{Name="Q602d";Expression={$_."consented-Q602-Q602d"}},
      @{Name="Q602e";Expression={$_."consented-Q602-Q602e"}},
      @{Name="Q602f";Expression={$_."consented-Q602-Q602f"}},
      @{Name="Q602g";Expression={$_."consented-Q602-Q602g"}},
      @{Name="Q602h";Expression={$_."consented-Q602-Q602h"}},
      @{Name="Q602other";Expression={$_."consented-Q602-Q602other"}},
      @{Name="Q603a";Expression={$_."consented-Q603-Q603a"}},
      @{Name="Q603b";Expression={$_."consented-Q603-Q603b"}},
      @{Name="Q603c";Expression={$_."consented-Q603-Q603c"}},
      @{Name="Q603d";Expression={$_."consented-Q603-Q603d"}},
      @{Name="Q603e";Expression={$_."consented-Q603-Q603e"}},
      @{Name="Q603f";Expression={$_."consented-Q603-Q603f"}},
      @{Name="Q603other";Expression={$_."consented-Q603-Q603other"}},
      @{Name="Q604a";Expression={$_."consented-Q604-Q604a"}},
      @{Name="Q604b";Expression={$_."consented-Q604-Q604b"}},
      @{Name="Q604c";Expression={$_."consented-Q604-Q604c"}},
      @{Name="Q604d";Expression={$_."consented-Q604-Q604d"}},
      @{Name="Q604e";Expression={$_."consented-Q604-Q604e"}},
      @{Name="Q604f";Expression={$_."consented-Q604-Q604f"}},
      @{Name="Q604g";Expression={$_."consented-Q604-Q604g"}},
      @{Name="Q604other";Expression={$_."consented-Q604-Q604other"}},
      @{Name="Q605";Expression={$_."consented-Q605"}},
      @{Name="Q606";Expression={$_."consented-Q606"}},
      @{Name="Q607";Expression={$_."consented-Q607"}},
      @{Name="Q608";Expression={$_."consented-Q608"}},
      @{Name="Q608other";Expression={$_."consented-Q608other"}},
      @{Name="Q609a";Expression={$_."consented-Q609-Q609a"}},
      @{Name="Q609b";Expression={$_."consented-Q609-Q609b"}},
      @{Name="Q610";Expression={$_."consented-Q610"}},
      @{Name="Q611a";Expression={$_."consented-Q611-Q611a"}},
      @{Name="Q611b";Expression={$_."consented-Q611-Q611b"}},
      @{Name="Q611c";Expression={$_."consented-Q611-Q611c"}},
      @{Name="summation";Expression={$_."consented-summation"}},
      @{Name="Q611aretake";Expression={$_."consented-Q611retake-Q611aretake"}},
      @{Name="Q611bretake";Expression={$_."consented-Q611retake-Q611bretake"}},
      @{Name="Q611cretake";Expression={$_."consented-Q611retake-Q611cretake"}},
      @{Name="Q612a";Expression={$_."consented-Q612-Q612a"}},
      @{Name="Q612b";Expression={$_."consented-Q612-Q612b"}},
      @{Name="Q612c";Expression={$_."consented-Q612-Q612c"}},
      @{Name="Q612d";Expression={$_."consented-Q612-Q612d"}},
      @{Name="Q612e";Expression={$_."consented-Q612-Q612e"}},
      @{Name="Q612f";Expression={$_."consented-Q612-Q612f"}},
      @{Name="Q612g";Expression={$_."consented-Q612-Q612g"}},
      @{Name="Q613";Expression={$_."consented-Q613"}},
      @{Name="Q614";Expression={$_."consented-Q614"}},
      @{Name="Q615";Expression={$_."consented-Q615"}},
      @{Name="Q616";Expression={$_."consented-Q616"}},
      @{Name="Q616other";Expression={$_."consented-Q616other"}},
      @{Name="Q617a";Expression={$_."consented-Q617-Q617a"}},
      @{Name="Q617b";Expression={$_."consented-Q617-Q617b"}},
      @{Name="Q617c";Expression={$_."consented-Q617-Q617c"}},
      @{Name="Q617d";Expression={$_."consented-Q617-Q617d"}},
      @{Name="Q617e";Expression={$_."consented-Q617-Q617e"}},
      @{Name="Q617f";Expression={$_."consented-Q617-Q617f"}},
      @{Name="Q617g";Expression={$_."consented-Q617-Q617g"}},
      @{Name="Q617i";Expression={$_."consented-Q617-Q617i"}},
      @{Name="Q618";Expression={$_."consented-Q618"}},
      @{Name="Q619";Expression={$_."consented-Q619"}},
      @{Name="Q620";Expression={$_."consented-Q620"}},
      @{Name="Q621";Expression={$_."consented-Q621"}},
      @{Name="Q622";Expression={$_."consented-Q622"}},
      @{Name="Q623";Expression={$_."consented-Q623"}},
      @{Name="Q624";Expression={$_."consented-Q624"}},
      @{Name="Q625a";Expression={$_."consented-Q625-Q625a"}},
      @{Name="Q625b";Expression={$_."consented-Q625-Q625b"}},
      @{Name="Q625c";Expression={$_."consented-Q625-Q625c"}},
      @{Name="Q625d";Expression={$_."consented-Q625-Q625d"}},
      @{Name="Q625e";Expression={$_."consented-Q625-Q625e"}},
      @{Name="Q625f";Expression={$_."consented-Q625-Q625f"}},
      @{Name="Q625g";Expression={$_."consented-Q625-Q625g"}},
      @{Name="Q625h";Expression={$_."consented-Q625-Q625h"}},
      @{Name="Q625i";Expression={$_."consented-Q625-Q625i"}},
      @{Name="Q625j";Expression={$_."consented-Q625-Q625j"}},
      @{Name="Q626a";Expression={$_."consented-Q626-Q626a"}},
      @{Name="Q626b";Expression={$_."consented-Q626-Q626b"}},
      @{Name="Q626c";Expression={$_."consented-Q626-Q626c"}},
      @{Name="Q626d";Expression={$_."consented-Q626-Q626d"}},
      @{Name="Q626e";Expression={$_."consented-Q626-Q626e"}},
      @{Name="Q626f";Expression={$_."consented-Q626-Q626f"}},
      @{Name="Q626g";Expression={$_."consented-Q626-Q626g"}},
      @{Name="Q626h";Expression={$_."consented-Q626-Q626h"}},
      @{Name="Q627a";Expression={$_."consented-Q627-Q627a"}},
      @{Name="Q627b";Expression={$_."consented-Q627-Q627b"}},
      @{Name="Q627c";Expression={$_."consented-Q627-Q627c"}},
      @{Name="Q627d";Expression={$_."consented-Q627-Q627d"}},
      @{Name="Q627e";Expression={$_."consented-Q627-Q627e"}},
      @{Name="Q627f";Expression={$_."consented-Q627-Q627f"}},
      @{Name="Q627g";Expression={$_."consented-Q627-Q627g"}},
      @{Name="Q627h";Expression={$_."consented-Q627-Q627h"}},
      @{Name="Q627i";Expression={$_."consented-Q627-Q627i"}},
      @{Name="Q627j";Expression={$_."consented-Q627-Q627j"}},
      @{Name="Q628";Expression={$_."consented-Q628"}},
      @{Name="Q629a";Expression={$_."consented-Q629-Q629a"}},
      @{Name="Q629b";Expression={$_."consented-Q629-Q629b"}},
      @{Name="Q629c";Expression={$_."consented-Q629-Q629c"}},
      @{Name="Q629d";Expression={$_."consented-Q629-Q629d"}},
      @{Name="Q629e";Expression={$_."consented-Q629-Q629e"}},
      @{Name="Q629f";Expression={$_."consented-Q629-Q629f"}},
      @{Name="Q629g";Expression={$_."consented-Q629-Q629g"}},
      @{Name="Q629h";Expression={$_."consented-Q629-Q629h"}},
      @{Name="Q629i";Expression={$_."consented-Q629-Q629i"}},
      @{Name="Q630";Expression={$_."consented-Q630"}},
      @{Name="Q631";Expression={$_."consented-Q631"}},
      @{Name="Q632";Expression={$_."consented-Q632"}},
      @{Name="Q633";Expression={$_."consented-baby-Q633"}},
      @{Name="Q633prompt";Expression={$_."consented-baby-Q633prompt"}},
      @{Name="Q633ack";Expression={$_."consented-Q633ack"}},
      @{Name="Q633acknot";Expression={$_."consented-Q633acknot"}},
      @{Name="Q634";Expression={$_."consented-market-Q634"}},
      @{Name="Q634prompt";Expression={$_."consented-market-Q634prompt"}},
      @{Name="Q634ack";Expression={$_."consented-Q634ack"}},
      @{Name="Q634acknot";Expression={$_."consented-Q634acknot"}},
      @{Name="Q635";Expression={$_."consented-market2weeks-Q635"}},
      @{Name="Q635prompt";Expression={$_."consented-market2weeks-Q635prompt"}},
      @{Name="Q635ack";Expression={$_."consented-Q635ack"}},
      @{Name="Q635acknot";Expression={$_."consented-Q635acknot"}},
      @{Name="Q636";Expression={$_."consented-market2ksagain-Q636"}},
      @{Name="Q636prompt";Expression={$_."consented-market2ksagain-Q636prompt"}},
      @{Name="Q636ack";Expression={$_."consented-Q636ack"}},
      @{Name="Q636acknot";Expression={$_."consented-Q636acknot"}},
      @{Name="Q637";Expression={$_."consented-Q637"}},
      @{Name="Q638";Expression={$_."consented-formarried-Q638"}},
      @{Name="Q639";Expression={$_."consented-formarried-Q639"}},
      @{Name="Q640";Expression={$_."consented-Q640"}},
      @{Name="Q641";Expression={$_."consented-sexwith-Q641"}},
      @{Name="Q642";Expression={$_."consented-sexwith-Q642"}},
      @{Name="Q643";Expression={$_."consented-sexwith-Q643"}},
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
$Q601= $i.Q601
$Q602a= $i.Q602a
$Q602b= $i.Q602b
$Q602c= $i.Q602c
$Q602d= $i.Q602d
$Q602e= $i.Q602e
$Q602f= $i.Q602f
$Q602g= $i.Q602g
$Q602h= $i.Q602h
$Q602other= $i.Q602other.replace("'","")
$Q603a= $i.Q603a
$Q603b= $i.Q603b
$Q603c= $i.Q603c
$Q603d= $i.Q603d
$Q603e= $i.Q603e
$Q603f= $i.Q603f
$Q603other= $i.Q603other.replace("'","")
$Q604a= $i.Q604a
$Q604b= $i.Q604b
$Q604c= $i.Q604c
$Q604d= $i.Q604d
$Q604e= $i.Q604e
$Q604f= $i.Q604f
$Q604g= $i.Q604g
$Q604other= $i.Q604other.replace("'","")
$Q605= $i.Q605
$Q606= $i.Q606
$Q607= $i.Q607
$Q608= $i.Q608
$Q608other= $i.Q608other.replace("'","")
$Q609a= $i.Q609a
$Q609b= $i.Q609b
$Q610= $i.Q610
$Q611a= $i.Q611a
$Q611b= $i.Q611b
$Q611c= $i.Q611c
$summation= $i.summation
$Q611aretake= $i.Q611aretake
$Q611bretake= $i.Q611bretake
$Q611cretake= $i.Q611cretake
$Q612a= $i.Q612a
$Q612b= $i.Q612b

$Q612c= $i.Q612c
$Q612d= $i.Q612d

$Q612e= $i.Q612e
$Q612f= $i.Q612f

$Q612g= $i.Q612g
$Q613= $i.Q613

$Q614= $i.Q614
$Q615= $i.Q615

$Q616= $i.Q616
$Q616other= $i.Q616other.replace("'","")
$Q617a= $i.Q617a
$Q617b= $i.Q617b
$Q617c= $i.Q617c
$Q617d= $i.Q617d
$Q617e= $i.Q617e
$Q617f= $i.Q617f
$Q617g= $i.Q617g
$Q617i= $i.Q617i
$Q618= $i.Q618
$Q619= $i.Q619
$Q620= $i.Q620
$Q621= $i.Q621
$Q622= $i.Q622
$Q623= $i.Q623
$Q624= $i.Q624
$Q625a= $i.Q625a
$Q625b= $i.Q625b
$Q625c= $i.Q625c
$Q625d= $i.Q625d
$Q625e= $i.Q625e
$Q625f= $i.Q625f
$Q625g= $i.Q625g
$Q625h= $i.Q625h
$Q625i= $i.Q625i
$Q625j= $i.Q625j
$Q626a= $i.Q626a
$Q626b= $i.Q626b
$Q626c= $i.Q626c
$Q626d= $i.Q626d
$Q626e= $i.Q626e
$Q626f= $i.Q626f
$Q626g= $i.Q626g
$Q626h= $i.Q626h
$Q627a= $i.Q627a
$Q627b= $i.Q627b
$Q627c= $i.Q627c
$Q627d= $i.Q627d
$Q627e= $i.Q627e
$Q627f= $i.Q627f
$Q627g= $i.Q627g
$Q627h= $i.Q627h
$Q627i= $i.Q627i
$Q627j= $i.Q627j
$Q628= $i.Q628
$Q629a= $i.Q629a
$Q629b= $i.Q629b
$Q629c= $i.Q629c
$Q629d= $i.Q629d
$Q629e= $i.Q629e
$Q629f= $i.Q629f
$Q629g= $i.Q629g
$Q629h= $i.Q629h
$Q629i= $i.Q629i
$Q630= $i.Q630
$Q631= $i.Q631
$Q632= $i.Q632
$Q633= $i.Q633
$Q633prompt= $i.Q633prompt
$Q633ack= $i.Q633ack
$Q633acknot= $i.Q633acknot
$Q634= $i.Q634
$Q634prompt= $i.Q634prompt
$Q634ack= $i.Q634ack
$Q634acknot= $i.Q634acknot
$Q635= $i.Q635
$Q635prompt= $i.Q635prompt
$Q635ack= $i.Q635ack
$Q635acknot= $i.Q635acknot
$Q636= $i.Q636
$Q636prompt= $i.Q636prompt
$Q636ack= $i.Q636ack
$Q636acknot= $i.Q636acknot
$Q637= $i.Q637
$Q638= $i.Q638
$Q639= $i.Q639
$Q640= $i.Q640
$Q641= $i.Q641
$Q642= $i.Q642
$Q643= $i.Q643
$METAKEY= $i.METAKEY

$SQLQuery = "INSERT INTO hivaware_7 (hhkey,
hhmem_key,
Q601,
Q602a,
Q602b,
Q602c,
Q602d,
Q602e,
Q602f,
Q602g,
Q602h,
Q602other,
Q603a,
Q603b,
Q603c,
Q603d,
Q603e,
Q603f,
Q603other,
Q604a,
Q604b,
Q604c,
Q604d,
Q604e,
Q604f,
Q604g,
Q604other,
Q605,
Q606,
Q607,
Q608,
Q608other,
Q609a,
Q609b,
Q610,
Q611a,
Q611b,
Q611c,
summation,
Q611aretake,
Q611bretake,
Q611cretake,
Q612a,Q612b,
Q612c,Q612d,
Q612e,Q612f,
Q612g,Q613,
Q614,Q615,
Q616,
Q616other,
Q617a,
Q617b,
Q617c,
Q617d,
Q617e,
Q617f,
Q617g,
Q617i,
Q618,
Q619,
Q620,
Q621,
Q622,
Q623,
Q624,
Q625a,
Q625b,
Q625c,
Q625d,
Q625e,
Q625f,
Q625g,
Q625h,
Q625i,
Q625j,
Q626a,
Q626b,
Q626c,
Q626d,
Q626e,
Q626f,
Q626g,
Q626h,
Q627a,
Q627b,
Q627c,
Q627d,
Q627e,
Q627f,
Q627g,
Q627h,
Q627i,
Q627j,
Q628,
Q629a,
Q629b,
Q629c,
Q629d,
Q629e,
Q629f,
Q629g,
Q629h,
Q629i,
Q630,
Q631,
Q632,
Q633,
Q633prompt,
Q633ack,
Q633acknot,
Q634,
Q634prompt,
Q634ack,
Q634acknot,
Q635,
Q635prompt,
Q635ack,
Q635acknot,
Q636,
Q636prompt,
Q636ack,
Q636acknot,
Q637,
Q638,
Q639,
Q640,
Q641,
Q642,
Q643,
METAKEY)       VALUES ('$hhkey',
'$hhmem_key',
'$Q601',
'$Q602a',
'$Q602b',
'$Q602c',
'$Q602d',
'$Q602e',
'$Q602f',
'$Q602g',
'$Q602h',
'$Q602other',
'$Q603a',
'$Q603b',
'$Q603c',
'$Q603d',
'$Q603e',
'$Q603f',
'$Q603other',
'$Q604a',
'$Q604b',
'$Q604c',
'$Q604d',
'$Q604e',
'$Q604f',
'$Q604g',
'$Q604other',
'$Q605',
'$Q606',
'$Q607',
'$Q608',
'$Q608other',
'$Q609a',
'$Q609b',
'$Q610',
'$Q611a',
'$Q611b',
'$Q611c',
'$summation',
'$Q611aretake',
'$Q611bretake',
'$Q611cretake',
'$Q612a','$Q612b',
'$Q612c','$Q612d',
'$Q612e','$Q612f',
'$Q612g','$Q613',
'$Q614','$Q615',
'$Q616',
'$Q616other',
'$Q617a',
'$Q617b',
'$Q617c',
'$Q617d',
'$Q617e',
'$Q617f',
'$Q617g',
'$Q617i',
'$Q618',
'$Q619',
'$Q620',
'$Q621',
'$Q622',
'$Q623',
'$Q624',
'$Q625a',
'$Q625b',
'$Q625c',
'$Q625d',
'$Q625e',
'$Q625f',
'$Q625g',
'$Q625h',
'$Q625i',
'$Q625j',
'$Q626a',
'$Q626b',
'$Q626c',
'$Q626d',
'$Q626e',
'$Q626f',
'$Q626g',
'$Q626h',
'$Q627a',
'$Q627b',
'$Q627c',
'$Q627d',
'$Q627e',
'$Q627f',
'$Q627g',
'$Q627h',
'$Q627i',
'$Q627j',
'$Q628',
'$Q629a',
'$Q629b',
'$Q629c',
'$Q629d',
'$Q629e',
'$Q629f',
'$Q629g',
'$Q629h',
'$Q629i',
'$Q630',
'$Q631',
'$Q632',
'$Q633',
'$Q633prompt',
'$Q633ack',
'$Q633acknot',
'$Q634',
'$Q634prompt',
'$Q634ack',
'$Q634acknot',
'$Q635',
'$Q635prompt',
'$Q635ack',
'$Q635acknot',
'$Q636',
'$Q636prompt',
'$Q636ack',
'$Q636acknot',
'$Q637',
'$Q638',
'$Q639',
'$Q640',
'$Q641',
'$Q642',
'$Q643',
'$METAKEY')"


 $impcsv = invoke-sqlcmd -Username $LocalDatabaseUser -Password $LocalDatabasePWD -Database $LocalDatabaseName -Query $SQLQuery  -serverinstance $LocalSQLServerInstance  
        $InfoMessage = "Household memID $hhmem_key successfully uploaded to YZ-UHP Local MSSSQL Server."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 
 $InfoMessage = "Successfully imported $count HIVAWARE  Qstns into the YZ-UHP database" 
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
$Q601= $i.Q601
$Q602a= $i.Q602a
$Q602b= $i.Q602b
$Q602c= $i.Q602c
$Q602d= $i.Q602d
$Q602e= $i.Q602e
$Q602f= $i.Q602f
$Q602g= $i.Q602g
$Q602h= $i.Q602h
$Q602other= $i.Q602other.replace("'","")
$Q603a= $i.Q603a
$Q603b= $i.Q603b
$Q603c= $i.Q603c
$Q603d= $i.Q603d
$Q603e= $i.Q603e
$Q603f= $i.Q603f
$Q603other= $i.Q603other.replace("'","")
$Q604a= $i.Q604a
$Q604b= $i.Q604b
$Q604c= $i.Q604c
$Q604d= $i.Q604d
$Q604e= $i.Q604e
$Q604f= $i.Q604f
$Q604g= $i.Q604g
$Q604other= $i.Q604other.replace("'","")
$Q605= $i.Q605
$Q606= $i.Q606
$Q607= $i.Q607
$Q608= $i.Q608
$Q608other= $i.Q608other.replace("'","")
$Q609a= $i.Q609a
$Q609b= $i.Q609b
$Q610= $i.Q610
$Q611a= $i.Q611a
$Q611b= $i.Q611b
$Q611c= $i.Q611c
$summation= $i.summation
$Q611aretake= $i.Q611aretake
$Q611bretake= $i.Q611bretake
$Q611cretake= $i.Q611cretake
$Q612a= $i.Q612a
$Q612b= $i.Q612b

$Q612c= $i.Q612c
$Q612d= $i.Q612d

$Q612e= $i.Q612e
$Q612f= $i.Q612f

$Q612g= $i.Q612g
$Q613= $i.Q613

$Q614= $i.Q614
$Q615= $i.Q615

$Q616= $i.Q616
$Q616other= $i.Q616other.replace("'","")
$Q617a= $i.Q617a
$Q617b= $i.Q617b
$Q617c= $i.Q617c
$Q617d= $i.Q617d
$Q617e= $i.Q617e
$Q617f= $i.Q617f
$Q617g= $i.Q617g
$Q617i= $i.Q617i
$Q618= $i.Q618
$Q619= $i.Q619
$Q620= $i.Q620
$Q621= $i.Q621
$Q622= $i.Q622
$Q623= $i.Q623
$Q624= $i.Q624
$Q625a= $i.Q625a
$Q625b= $i.Q625b
$Q625c= $i.Q625c
$Q625d= $i.Q625d
$Q625e= $i.Q625e
$Q625f= $i.Q625f
$Q625g= $i.Q625g
$Q625h= $i.Q625h
$Q625i= $i.Q625i
$Q625j= $i.Q625j
$Q626a= $i.Q626a
$Q626b= $i.Q626b
$Q626c= $i.Q626c
$Q626d= $i.Q626d
$Q626e= $i.Q626e
$Q626f= $i.Q626f
$Q626g= $i.Q626g
$Q626h= $i.Q626h
$Q627a= $i.Q627a
$Q627b= $i.Q627b
$Q627c= $i.Q627c
$Q627d= $i.Q627d
$Q627e= $i.Q627e
$Q627f= $i.Q627f
$Q627g= $i.Q627g
$Q627h= $i.Q627h
$Q627i= $i.Q627i
$Q627j= $i.Q627j
$Q628= $i.Q628
$Q629a= $i.Q629a
$Q629b= $i.Q629b
$Q629c= $i.Q629c
$Q629d= $i.Q629d
$Q629e= $i.Q629e
$Q629f= $i.Q629f
$Q629g= $i.Q629g
$Q629h= $i.Q629h
$Q629i= $i.Q629i
$Q630= $i.Q630
$Q631= $i.Q631
$Q632= $i.Q632
$Q633= $i.Q633
$Q633prompt= $i.Q633prompt
$Q633ack= $i.Q633ack
$Q633acknot= $i.Q633acknot
$Q634= $i.Q634
$Q634prompt= $i.Q634prompt
$Q634ack= $i.Q634ack
$Q634acknot= $i.Q634acknot
$Q635= $i.Q635
$Q635prompt= $i.Q635prompt
$Q635ack= $i.Q635ack
$Q635acknot= $i.Q635acknot
$Q636= $i.Q636
$Q636prompt= $i.Q636prompt
$Q636ack= $i.Q636ack
$Q636acknot= $i.Q636acknot
$Q637= $i.Q637
$Q638= $i.Q638
$Q639= $i.Q639
$Q640= $i.Q640
$Q641= $i.Q641
$Q642= $i.Q642
$Q643= $i.Q643
$METAKEY= $i.METAKEY

$SQLQuery = "INSERT INTO hivaware_7 (hhkey,
hhmem_key,
Q601,
Q602a,
Q602b,
Q602c,
Q602d,
Q602e,
Q602f,
Q602g,
Q602h,
Q602other,
Q603a,
Q603b,
Q603c,
Q603d,
Q603e,
Q603f,
Q603other,
Q604a,
Q604b,
Q604c,
Q604d,
Q604e,
Q604f,
Q604g,
Q604other,
Q605,
Q606,
Q607,
Q608,
Q608other,
Q609a,
Q609b,
Q610,
Q611a,
Q611b,
Q611c,
summation,
Q611aretake,
Q611bretake,
Q611cretake,
Q612a,Q612b,
Q612c,Q612d,
Q612e,Q612f,
Q612g,Q613,
Q614,Q615,
Q616,
Q616other,
Q617a,
Q617b,
Q617c,
Q617d,
Q617e,
Q617f,
Q617g,
Q617i,
Q618,
Q619,
Q620,
Q621,
Q622,
Q623,
Q624,
Q625a,
Q625b,
Q625c,
Q625d,
Q625e,
Q625f,
Q625g,
Q625h,
Q625i,
Q625j,
Q626a,
Q626b,
Q626c,
Q626d,
Q626e,
Q626f,
Q626g,
Q626h,
Q627a,
Q627b,
Q627c,
Q627d,
Q627e,
Q627f,
Q627g,
Q627h,
Q627i,
Q627j,
Q628,
Q629a,
Q629b,
Q629c,
Q629d,
Q629e,
Q629f,
Q629g,
Q629h,
Q629i,
Q630,
Q631,
Q632,
Q633,
Q633prompt,
Q633ack,
Q633acknot,
Q634,
Q634prompt,
Q634ack,
Q634acknot,
Q635,
Q635prompt,
Q635ack,
Q635acknot,
Q636,
Q636prompt,
Q636ack,
Q636acknot,
Q637,
Q638,
Q639,
Q640,
Q641,
Q642,
Q643,
METAKEY)       VALUES ('$hhkey',
'$hhmem_key',
'$Q601',
'$Q602a',
'$Q602b',
'$Q602c',
'$Q602d',
'$Q602e',
'$Q602f',
'$Q602g',
'$Q602h',
'$Q602other',
'$Q603a',
'$Q603b',
'$Q603c',
'$Q603d',
'$Q603e',
'$Q603f',
'$Q603other',
'$Q604a',
'$Q604b',
'$Q604c',
'$Q604d',
'$Q604e',
'$Q604f',
'$Q604g',
'$Q604other',
'$Q605',
'$Q606',
'$Q607',
'$Q608',
'$Q608other',
'$Q609a',
'$Q609b',
'$Q610',
'$Q611a',
'$Q611b',
'$Q611c',
'$summation',
'$Q611aretake',
'$Q611bretake',
'$Q611cretake',
'$Q612a','$Q612b',
'$Q612c','$Q612d',
'$Q612e','$Q612f',
'$Q612g','$Q613',
'$Q614','$Q615',
'$Q616',
'$Q616other',
'$Q617a',
'$Q617b',
'$Q617c',
'$Q617d',
'$Q617e',
'$Q617f',
'$Q617g',
'$Q617i',
'$Q618',
'$Q619',
'$Q620',
'$Q621',
'$Q622',
'$Q623',
'$Q624',
'$Q625a',
'$Q625b',
'$Q625c',
'$Q625d',
'$Q625e',
'$Q625f',
'$Q625g',
'$Q625h',
'$Q625i',
'$Q625j',
'$Q626a',
'$Q626b',
'$Q626c',
'$Q626d',
'$Q626e',
'$Q626f',
'$Q626g',
'$Q626h',
'$Q627a',
'$Q627b',
'$Q627c',
'$Q627d',
'$Q627e',
'$Q627f',
'$Q627g',
'$Q627h',
'$Q627i',
'$Q627j',
'$Q628',
'$Q629a',
'$Q629b',
'$Q629c',
'$Q629d',
'$Q629e',
'$Q629f',
'$Q629g',
'$Q629h',
'$Q629i',
'$Q630',
'$Q631',
'$Q632',
'$Q633',
'$Q633prompt',
'$Q633ack',
'$Q633acknot',
'$Q634',
'$Q634prompt',
'$Q634ack',
'$Q634acknot',
'$Q635',
'$Q635prompt',
'$Q635ack',
'$Q635acknot',
'$Q636',
'$Q636prompt',
'$Q636ack',
'$Q636acknot',
'$Q637',
'$Q638',
'$Q639',
'$Q640',
'$Q641',
'$Q642',
'$Q643',
'$METAKEY')"




       # Cloud Database Settings
        $impcsv = invoke-sqlcmd -Username $CloudDatabaseUser -Password $CloudDatabasePWD -Database $CloudDatabaseName -Query $SQLQuery  -serverinstance $CloudSQLServerInstance  
        $InfoMessage = "Household memID $hhmem_key successfully uploaded to Cloud YZ-UHP database on SmarterASP."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 


 $InfoMessage = "Successfully imported $count HIVAWARE Qstns into the YZ-UHP CLOUD database" 
 Write-Log -Message $InfoMessage -Path $LogFile   -Level Info

 

$InfoMessage = "Qstns Data upload completed"
}



Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    
    Write-Log -Message "Error : Upload to Cloud database failed with the error : $ErrorMessage" -Path $LogFile -Level Error
}


