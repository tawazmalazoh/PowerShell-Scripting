
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
$FormattedCSVFile = 'C:\DATA\Briefcase\Formatted\hivprev_7.csv'
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
$DatabaseTable = 'hivprev_7'


# Lets create a Log file to log the events that will be happening today. Generate log file with current date.
$date = Get-Date -UFormat "%Y%m%d"
$LogFile = $LogFileFolder+'log-'+$date+'-hivprev_7.log'



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
      @{Name="Q501";Expression={$_."consented-Q501"}},
      @{Name="Q502a";Expression={$_."consented-Q502-Q502a"}},
      @{Name="Q502b";Expression={$_."consented-Q502-Q502b"}},
      @{Name="Q502c";Expression={$_."consented-Q502-Q502c"}},
      @{Name="Q502d";Expression={$_."consented-Q502-Q502d"}},
      @{Name="Q502e";Expression={$_."consented-Q502-Q502e"}},
      @{Name="Q502f";Expression={$_."consented-Q502-Q502f"}},
      @{Name="Q502g";Expression={$_."consented-Q502-Q502g"}},
      @{Name="Q502h";Expression={$_."consented-Q502-Q502h"}},
      @{Name="Q502i";Expression={$_."consented-Q502-Q502i"}},
      @{Name="Q502other";Expression={$_."consented-Q502-Q502other"}},
      @{Name="Q503vmmc";Expression={$_."consented-vmmcprobed-Q503vmmc"}},
      @{Name="Q503othervmmc";Expression={$_."consented-vmmcprobed-Q503othervmmc"}},
      @{Name="Q504vmmc";Expression={$_."consented-vmmcprobed-Q504vmmc"}},
      @{Name="Q504othervmmc";Expression={$_."consented-vmmcprobed-Q504othervmmc"}},
      @{Name="Q503prep";Expression={$_."consented-prepprobed-Q503prep"}},
      @{Name="Q503otherprep";Expression={$_."consented-prepprobed-Q503otherprep"}},
      @{Name="Q504prep";Expression={$_."consented-prepprobed-Q504prep"}},
      @{Name="Q504otherprep";Expression={$_."consented-prepprobed-Q504otherprep"}},
      @{Name="Q503mcondom";Expression={$_."consented-mcondomprobed-Q503mcondom"}},
      @{Name="Q503othermcondom";Expression={$_."consented-mcondomprobed-Q503othermcondom"}},
      @{Name="Q504mcondom";Expression={$_."consented-mcondomprobed-Q504mcondom"}},
      @{Name="Q504othermcondom";Expression={$_."consented-mcondomprobed-Q504othermcondom"}},
      @{Name="Q503fcondom";Expression={$_."consented-fcondomprobed-Q503fcondom"}},
      @{Name="Q503otherfcondom";Expression={$_."consented-fcondomprobed-Q503otherfcondom"}},
      @{Name="Q504fcondom";Expression={$_."consented-fcondomprobed-Q504fcondom"}},
      @{Name="Q504otherfcondom";Expression={$_."consented-fcondomprobed-Q504otherfcondom"}},
      @{Name="Q503sp";Expression={$_."consented-spprobed-Q503sp"}},
      @{Name="Q503othersp";Expression={$_."consented-spprobed-Q503othersp"}},
      @{Name="Q504sp";Expression={$_."consented-spprobed-Q504sp"}},
      @{Name="Q504othersp";Expression={$_."consented-spprobed-Q504othersp"}},
      @{Name="Q503hivtc";Expression={$_."consented-hivtcprobed-Q503hivtc"}},
      @{Name="Q503otherhivtc";Expression={$_."consented-hivtcprobed-Q503otherhivtc"}},
      @{Name="Q504hivtc";Expression={$_."consented-hivtcprobed-Q504hivtc"}},
      @{Name="Q504otherhivtc";Expression={$_."consented-hivtcprobed-Q504otherhivtc"}},
      @{Name="Q505a";Expression={$_."consented-Q505-Q505a"}},
      @{Name="Q505b";Expression={$_."consented-Q505-Q505b"}},
      @{Name="Q505c";Expression={$_."consented-Q505-Q505c"}},
      @{Name="Q505d";Expression={$_."consented-Q505-Q505d"}},
      @{Name="Q505e";Expression={$_."consented-Q505-Q505e"}},
      @{Name="Q505f";Expression={$_."consented-Q505-Q505f"}},
      @{Name="Q505g";Expression={$_."consented-Q505-Q505g"}},
      @{Name="Q506a";Expression={$_."consented-Q506-Q506a"}},
      @{Name="Q506b";Expression={$_."consented-Q506-Q506b"}},
      @{Name="Q506c";Expression={$_."consented-Q506-Q506c"}},
      @{Name="Q506d";Expression={$_."consented-Q506-Q506d"}},
      @{Name="Q506e";Expression={$_."consented-Q506-Q506e"}},
      @{Name="Q506f";Expression={$_."consented-Q506-Q506f"}},
      @{Name="Q506g";Expression={$_."consented-Q506-Q506g"}},
      @{Name="Q507";Expression={$_."consented-Q507"}},
      @{Name="Q507other";Expression={$_."consented-Q507other"}},
      @{Name="Q508vmmc";Expression={$_."consented-Q508vmmc"}},
      @{Name="Q508prep";Expression={$_."consented-Q508prep"}},
      @{Name="Q508mcondom";Expression={$_."consented-Q508mcondom"}},
      @{Name="Q508fcondom";Expression={$_."consented-Q508fcondom"}},
      @{Name="Q508hivtc";Expression={$_."consented-Q508hivtc"}},
      @{Name="Q509";Expression={$_."consented-formenvmmc-Q509"}},
      @{Name="Q510";Expression={$_."consented-formenvmmc-Q510"}},
      @{Name="Q511";Expression={$_."consented-formenvmmc-xrele-Q511"}},
      @{Name="Q512";Expression={$_."consented-formenvmmc-xrele-validforfull-Q512"}},
      @{Name="Q514";Expression={$_."consented-formenvmmc-xrele-validforfull-Q514"}},
      @{Name="Q515a";Expression={$_."consented-formenvmmc-xrele-validforfull-greater10yrs-Q515-Q515a"}},
      @{Name="Q515b";Expression={$_."consented-formenvmmc-xrele-validforfull-greater10yrs-Q515-Q515b"}},
      @{Name="Q515c";Expression={$_."consented-formenvmmc-xrele-validforfull-greater10yrs-Q515-Q515c"}},
      @{Name="Q515d";Expression={$_."consented-formenvmmc-xrele-validforfull-greater10yrs-Q515-Q515d"}},
      @{Name="Q516";Expression={$_."consented-formenvmmc-xrele-validforfull-greater10yrs-procedure-Q516"}},
      @{Name="Q516b";Expression={$_."consented-formenvmmc-xrele-validforfull-greater10yrs-procedure-Q516b"}},
      @{Name="Q517a";Expression={$_."consented-formenvmmc-xrele-validforfull-greater10yrs-Q517-Q517a"}},
      @{Name="Q517b";Expression={$_."consented-formenvmmc-xrele-validforfull-greater10yrs-Q517-Q517b"}},
      @{Name="Q517c";Expression={$_."consented-formenvmmc-xrele-validforfull-greater10yrs-Q517-Q517c"}},
      @{Name="Q517d";Expression={$_."consented-formenvmmc-xrele-validforfull-greater10yrs-Q517-Q517d"}},
      @{Name="Q517e";Expression={$_."consented-formenvmmc-xrele-validforfull-greater10yrs-Q517-Q517e"}},
      @{Name="Q518a";Expression={$_."consented-formenvmmc-xrele-validforfull-greater10yrs-Q518-Q518a"}},
      @{Name="Q518b";Expression={$_."consented-formenvmmc-xrele-validforfull-greater10yrs-Q518-Q518b"}},
      @{Name="Q518c";Expression={$_."consented-formenvmmc-xrele-validforfull-greater10yrs-Q518c"}},
      @{Name="Q519a";Expression={$_."consented-formenvmmc-xrele-partialcircum-Q519-Q519a"}},
      @{Name="Q519b";Expression={$_."consented-formenvmmc-xrele-partialcircum-Q519-Q519b"}},
      @{Name="Q519c";Expression={$_."consented-formenvmmc-xrele-partialcircum-Q519-Q519c"}},
      @{Name="Q519d";Expression={$_."consented-formenvmmc-xrele-partialcircum-Q519-Q519d"}},
      @{Name="Q520";Expression={$_."consented-formenvmmc-xrele-partialcircum-Q520"}},
      @{Name="Q521";Expression={$_."consented-formenvmmc-xrele-partialcircum-Q521"}},
      @{Name="Q522";Expression={$_."consented-formenvmmc-xrele-partialcircum-Q522"}},
      @{Name="Q523";Expression={$_."consented-formenvmmc-xrele-partialcircum-Q523"}},
      @{Name="Q524a";Expression={$_."consented-formenvmmc-xrele-partialcircum-Q524-Q524a"}},
      @{Name="Q524b";Expression={$_."consented-formenvmmc-xrele-partialcircum-Q524-Q524b"}},
      @{Name="Q524c";Expression={$_."consented-formenvmmc-xrele-partialcircum-Q524-Q524c"}},
      @{Name="Q524d";Expression={$_."consented-formenvmmc-xrele-partialcircum-Q524-Q524d"}},
      @{Name="Q524e";Expression={$_."consented-formenvmmc-xrele-partialcircum-Q524-Q524e"}},
      @{Name="Q524f";Expression={$_."consented-formenvmmc-xrele-partialcircum-Q524-Q524f"}},
      @{Name="Q524g";Expression={$_."consented-formenvmmc-xrele-partialcircum-Q524-Q524g"}},
      @{Name="Q524other";Expression={$_."consented-formenvmmc-xrele-partialcircum-Q524-Q524other"}},
      @{Name="Q525";Expression={$_."consented-formenvmmc-xrele-partialcircum-notpos-Q525"}},
      @{Name="Q526";Expression={$_."consented-formenvmmc-xrele-partialcircum-notpos-Q526"}},
      @{Name="Q527";Expression={$_."consented-formenvmmc-xrele-partialcircum-notpos-Q527"}},
      @{Name="Q528";Expression={$_."consented-formenvmmc-xrele-partialcircum-notpos-Q528"}},
      @{Name="Q529a";Expression={$_."consented-formenvmmc-xrele-factvmmc-Q529-Q529a"}},
      @{Name="Q529b";Expression={$_."consented-formenvmmc-xrele-factvmmc-Q529-Q529b"}},
      @{Name="Q529c";Expression={$_."consented-formenvmmc-xrele-factvmmc-Q529-Q529c"}},
      @{Name="Q529d";Expression={$_."consented-formenvmmc-xrele-factvmmc-Q529-Q529d"}},
      @{Name="Q529e";Expression={$_."consented-formenvmmc-xrele-factvmmc-Q529-Q529e"}},
      @{Name="Q529f";Expression={$_."consented-formenvmmc-xrele-factvmmc-Q529-Q529f"}},
      @{Name="Q529g";Expression={$_."consented-formenvmmc-xrele-factvmmc-Q529-Q529g"}},
      @{Name="Q529h";Expression={$_."consented-formenvmmc-xrele-factvmmc-Q529-Q529h"}},
      @{Name="Q529i";Expression={$_."consented-formenvmmc-xrele-factvmmc-Q529-Q529i"}},
      @{Name="Q529j";Expression={$_."consented-formenvmmc-xrele-factvmmc-Q529-Q529j"}},
      @{Name="Q529k";Expression={$_."consented-formenvmmc-xrele-factvmmc-Q529-Q529k"}},
      @{Name="Q529l";Expression={$_."consented-formenvmmc-xrele-factvmmc-Q529-Q529l"}},
      @{Name="Q529m";Expression={$_."consented-formenvmmc-xrele-factvmmc-Q529-Q529m"}},
      @{Name="Q529n";Expression={$_."consented-formenvmmc-xrele-factvmmc-Q529-Q529n"}},
      @{Name="Q529othermthd";Expression={$_."consented-formenvmmc-xrele-factvmmc-Q529-Q529othermthd"}},
      @{Name="Q529other";Expression={$_."consented-formenvmmc-xrele-factvmmc-Q529-Q529other"}},
      @{Name="Q530a";Expression={$_."consented-formenvmmc-xrele-factvmmc-Q530-Q530a"}},
      @{Name="Q530b";Expression={$_."consented-formenvmmc-xrele-factvmmc-Q530-Q530b"}},
      @{Name="Q530c";Expression={$_."consented-formenvmmc-xrele-factvmmc-Q530-Q530c"}},
      @{Name="Q530d";Expression={$_."consented-formenvmmc-xrele-factvmmc-Q530-Q530d"}},
      @{Name="Q530e";Expression={$_."consented-formenvmmc-xrele-factvmmc-Q530-Q530e"}},
      @{Name="Q530f";Expression={$_."consented-formenvmmc-xrele-factvmmc-Q530-Q530f"}},
      @{Name="Q531";Expression={$_."consented-formenvmmc-xrele-Q531"}},
      @{Name="Q532";Expression={$_."consented-formenvmmc-xrele-Q532"}},
      @{Name="Q533";Expression={$_."consented-Q533"}},
      @{Name="Q534teenager";Expression={$_."consented-Q534-Q534teenager"}},
      @{Name="Q534youngman";Expression={$_."consented-Q534-Q534youngman"}},
      @{Name="Q535";Expression={$_."consented-Q535"}},
      @{Name="Q536";Expression={$_."consented-Q536"}},
      @{Name="Q537";Expression={$_."consented-knowprep-Q537"}},
      @{Name="Q538";Expression={$_."consented-knowprep-Q538"}},
      @{Name="Q539";Expression={$_."consented-knowprep-notofferedprep-Q539"}},
      @{Name="Q539Q545";Expression={$_."consented-knowprep-notofferedprep-Q539Q545"}},
      @{Name="Q539Q545a";Expression={$_."consented-knowprep-notofferedprep-Q539Q545a"}},
      @{Name="Q539Q545b";Expression={$_."consented-knowprep-notofferedprep-Q539Q545b"}},
      @{Name="Q540";Expression={$_."consented-knowprep-notofferedprep-prepnow-Q540"}},
      @{Name="Q541a";Expression={$_."consented-knowprep-notofferedprep-prepnow-Q541-Q541a"}},
      @{Name="Q541b";Expression={$_."consented-knowprep-notofferedprep-prepnow-Q541-Q541b"}},
      @{Name="Q541c";Expression={$_."consented-knowprep-notofferedprep-prepnow-Q541-Q541c"}},
      @{Name="Q541other";Expression={$_."consented-knowprep-notofferedprep-prepnow-Q541-Q541other"}},
      @{Name="Q542";Expression={$_."consented-knowprep-notofferedprep-prepnow-Q542"}},
      @{Name="Q543";Expression={$_."consented-knowprep-notofferedprep-prepnow-prepeveryday-Q543"}},
      @{Name="Q544";Expression={$_."consented-knowprep-notofferedprep-prepnow-prepeveryday-Q544"}},
      @{Name="Q545";Expression={$_."consented-knowprep-notofferedprep-prepnow-Q545"}},
      @{Name="Q545a";Expression={$_."consented-knowprep-notofferedprep-prepnow-Q545a"}},
      @{Name="Q545b";Expression={$_."consented-knowprep-notofferedprep-prepnow-Q545b"}},
      @{Name="Q546";Expression={$_."consented-knowprep-notofferedprep-sexually-Q546"}},
      @{Name="Q547a";Expression={$_."consented-knowprep-notofferedprep-sexually-Q547-Q547a"}},
      @{Name="Q547b";Expression={$_."consented-knowprep-notofferedprep-sexually-Q547-Q547b"}},
      @{Name="Q547c";Expression={$_."consented-knowprep-notofferedprep-sexually-Q547c"}},
      @{Name="Q548a";Expression={$_."consented-knowprep-Q548-Q548a"}},
      @{Name="Q548b";Expression={$_."consented-knowprep-Q548-Q548b"}},
      @{Name="Q548c";Expression={$_."consented-knowprep-Q548-Q548c"}},
      @{Name="Q548d";Expression={$_."consented-knowprep-Q548-Q548d"}},
      @{Name="Q548e";Expression={$_."consented-knowprep-Q548-Q548e"}},
      @{Name="Q548f";Expression={$_."consented-knowprep-Q548-Q548f"}},
      @{Name="Q548g";Expression={$_."consented-knowprep-Q548-Q548g"}},
      @{Name="Q549";Expression={$_."consented-knowprep-Q549"}},
      @{Name="Q550";Expression={$_."consented-knowprep-Q550"}},
      @{Name="Q551";Expression={$_."consented-knowprep-Q551"}},
      @{Name="Q552";Expression={$_."consented-knowprep-Q552"}},
      @{Name="Q553";Expression={$_."consented-knowprep-Q553"}},
      @{Name="Q554a";Expression={$_."consented-knowprep-Q554-Q554a"}},
      @{Name="Q554b";Expression={$_."consented-knowprep-Q554-Q554b"}},
      @{Name="Q554c";Expression={$_."consented-knowprep-Q554-Q554c"}},
      @{Name="Q554d";Expression={$_."consented-knowprep-Q554-Q554d"}},
      @{Name="Q554e";Expression={$_."consented-knowprep-Q554-Q554e"}},
      @{Name="Q554f";Expression={$_."consented-knowprep-Q554-Q554f"}},
      @{Name="Q554g";Expression={$_."consented-knowprep-Q554-Q554g"}},
      @{Name="Q554h";Expression={$_."consented-knowprep-Q554-Q554h"}},
      @{Name="Q554i";Expression={$_."consented-knowprep-Q554-Q554i"}},
      @{Name="Q554other";Expression={$_."consented-knowprep-Q554-Q554other"}},
      @{Name="Q555";Expression={$_."consented-knowprep-Q555"}},
      @{Name="Q556";Expression={$_."consented-knowprep-Q556"}},
      @{Name="Q557";Expression={$_."consented-knowprep-Q557"}},
      @{Name="Q558";Expression={$_."consented-knowprep-Q558"}},
      @{Name="Q559a";Expression={$_."consented-knowprep-Q559-Q559a"}},
      @{Name="Q559b";Expression={$_."consented-knowprep-Q559-Q559b"}},
      @{Name="Q559c";Expression={$_."consented-knowprep-Q559-Q559c"}},
      @{Name="Q559d";Expression={$_."consented-knowprep-Q559-Q559d"}},
      @{Name="Q559e";Expression={$_."consented-knowprep-Q559-Q559e"}},
      @{Name="Q559f";Expression={$_."consented-knowprep-Q559-Q559f"}},
      @{Name="Q559g";Expression={$_."consented-knowprep-Q559-Q559g"}},
      @{Name="Q559h";Expression={$_."consented-knowprep-Q559-Q559h"}},
      @{Name="Q559j";Expression={$_."consented-knowprep-Q559-Q559j"}},
      @{Name="Q559i";Expression={$_."consented-knowprep-Q559-Q559i"}},
      @{Name="Q559other";Expression={$_."consented-knowprep-Q559-Q559other"}},
      @{Name="Q560a";Expression={$_."consented-knowprep-Q560-Q560a"}},
      @{Name="Q560b";Expression={$_."consented-knowprep-Q560-Q560b"}},
      @{Name="Q560c";Expression={$_."consented-knowprep-Q560-Q560c"}},
      @{Name="Q560d";Expression={$_."consented-knowprep-Q560-Q560d"}},
      @{Name="Q560e";Expression={$_."consented-knowprep-Q560-Q560e"}},
      @{Name="Q560f";Expression={$_."consented-knowprep-Q560-Q560f"}},
      @{Name="Q560other";Expression={$_."consented-knowprep-Q560-Q560other"}},
      @{Name="Q561";Expression={$_."consented-knowprep-Q561"}},
      @{Name="Q562";Expression={$_."consented-knowprep-Q562"}},
      @{Name="Q563";Expression={$_."consented-knowprep-Q563"}},
      @{Name="Q564teenager";Expression={$_."consented-knowprep-Q564-Q564teenager"}},
      @{Name="Q564youngman";Expression={$_."consented-knowprep-Q564-Q564youngman"}},
      @{Name="Q565a";Expression={$_."consented-knowprep-Q565-Q565a"}},
      @{Name="Q565b";Expression={$_."consented-knowprep-Q565-Q565b"}},
      @{Name="Q566";Expression={$_."consented-Q566"}},
      @{Name="Q567";Expression={$_."consented-Q567"}},
      @{Name="Q568";Expression={$_."consented-Q568"}},
      @{Name="Q568otherprev";Expression={$_."consented-Q568otherprev"}},
      @{Name="Q568other";Expression={$_."consented-Q568other"}},
      @{Name="Q569";Expression={$_."consented-Q569"}},
      @{Name="Q570";Expression={$_."consented-Q570"}},
      @{Name="Q570other";Expression={$_."consented-Q570other"}},
      @{Name="Q571";Expression={$_."consented-Q571"}},
      @{Name="Q572a";Expression={$_."consented-Q572-Q572a"}},
      @{Name="Q572b";Expression={$_."consented-Q572-Q572b"}},
      @{Name="Q572c";Expression={$_."consented-Q572-Q572c"}},
      @{Name="Q572d";Expression={$_."consented-Q572-Q572d"}},
      @{Name="Q572e";Expression={$_."consented-Q572-Q572e"}},
      @{Name="Q572f";Expression={$_."consented-Q572-Q572f"}},
      @{Name="Q573";Expression={$_."consented-Q573"}},
      @{Name="Q574";Expression={$_."consented-Q574"}},
      @{Name="Q575";Expression={$_."consented-Q575"}},
      @{Name="Q576";Expression={$_."consented-Q576"}},
      @{Name="Q577";Expression={$_."consented-Q577"}},
      @{Name="Q578";Expression={$_."consented-Q578"}},
      @{Name="Q579";Expression={$_."consented-Q579"}},
      @{Name="Q580";Expression={$_."consented-Q580"}},
      @{Name="Q581";Expression={$_."consented-Q581"}},
      @{Name="Q582a";Expression={$_."consented-Q582-Q582a"}},
      @{Name="Q582b";Expression={$_."consented-Q582-Q582b"}},
      @{Name="Q582c";Expression={$_."consented-Q582-Q582c"}},
      @{Name="Q582d";Expression={$_."consented-Q582-Q582d"}},
      @{Name="Q582e";Expression={$_."consented-Q582-Q582e"}},
      @{Name="Q582f";Expression={$_."consented-Q582-Q582f"}},
      @{Name="Q582other";Expression={$_."consented-Q582-Q582other"}},
      @{Name="Q583a";Expression={$_."consented-Q583-Q583a"}},
      @{Name="Q583b";Expression={$_."consented-Q583-Q583b"}},
      @{Name="Q583c";Expression={$_."consented-Q583-Q583c"}},
      @{Name="Q583d";Expression={$_."consented-Q583-Q583d"}},
      @{Name="Q583e";Expression={$_."consented-Q583-Q583e"}},
      @{Name="Q583other";Expression={$_."consented-Q583-Q583other"}},
      @{Name="Q584";Expression={$_."consented-Q584"}},
      @{Name="Q585";Expression={$_."consented-regularpat-Q585"}},
      @{Name="Q586";Expression={$_."consented-regularpat-Q586"}},
      @{Name="Q587";Expression={$_."consented-Q587"}},
      @{Name="Q588";Expression={$_."consented-Q588"}},
      @{Name="Q589";Expression={$_."consented-Q589"}},
      @{Name="Q590a";Expression={$_."consented-Q590-Q590a"}},
      @{Name="Q590b";Expression={$_."consented-Q590-Q590b"}},
      @{Name="Q590c";Expression={$_."consented-Q590-Q590c"}},
      @{Name="Q590d";Expression={$_."consented-Q590-Q590d"}},
      @{Name="Q590e";Expression={$_."consented-Q590-Q590e"}},
      @{Name="Q590f";Expression={$_."consented-Q590-Q590f"}},
      @{Name="Q590g";Expression={$_."consented-Q590-Q590g"}},
      @{Name="Q590h";Expression={$_."consented-Q590-Q590h"}},
      @{Name="Q590i";Expression={$_."consented-Q590-Q590i"}},
      @{Name="Q590otherpvn";Expression={$_."consented-Q590-Q590otherpvn"}},
      @{Name="Q590other";Expression={$_."consented-Q590-Q590other"}},
      @{Name="Q591a";Expression={$_."consented-Q591-Q591a"}},
      @{Name="Q591b";Expression={$_."consented-Q591-Q591b"}},
      @{Name="Q591c";Expression={$_."consented-Q591-Q591c"}},
      @{Name="Q591d";Expression={$_."consented-Q591-Q591d"}},
      @{Name="Q591e";Expression={$_."consented-Q591-Q591e"}},
      @{Name="Q591f";Expression={$_."consented-Q591-Q591f"}},
      @{Name="Q591g";Expression={$_."consented-Q591-Q591g"}},
      @{Name="Q591other";Expression={$_."consented-Q591-Q591other"}},
      @{Name="Q592";Expression={$_."consented-Q592"}},
      @{Name="Q593";Expression={$_."consented-Q593"}},
      @{Name="Q594";Expression={$_."consented-Q594"}},
      @{Name="Q595a";Expression={$_."consented-Q595-Q595a"}},
      @{Name="Q595b";Expression={$_."consented-Q595-Q595b"}},
      @{Name="Q595c";Expression={$_."consented-Q595-Q595c"}},
      @{Name="Q595d";Expression={$_."consented-Q595-Q595d"}},
      @{Name="Q595e";Expression={$_."consented-Q595-Q595e"}},
      @{Name="Q595other";Expression={$_."consented-Q595-Q595other"}},
      @{Name="Q596a";Expression={$_."consented-Q596-Q596a"}},
      @{Name="Q596b";Expression={$_."consented-Q596-Q596b"}},
      @{Name="Q597";Expression={$_."consented-Q597"}},
      @{Name="Q598";Expression={$_."consented-knowfemcondoms-Q598"}},
      @{Name="Q599";Expression={$_."consented-knowfemcondoms-Q599"}},
      @{Name="Q599otherpvn";Expression={$_."consented-knowfemcondoms-Q599otherpvn"}},
      @{Name="Q599other";Expression={$_."consented-knowfemcondoms-Q599other"}},
      @{Name="Q59901";Expression={$_."consented-knowfemcondoms-Q59901"}},
      @{Name="Q59902";Expression={$_."consented-knowfemcondoms-Q59902"}},
      @{Name="Q59902other";Expression={$_."consented-knowfemcondoms-Q59902other"}},
      @{Name="Q59903";Expression={$_."consented-knowfemcondoms-Q59903"}},
      @{Name="Q59904a";Expression={$_."consented-knowfemcondoms-Q59904-Q59904a"}},
      @{Name="Q59904b";Expression={$_."consented-knowfemcondoms-Q59904-Q59904b"}},
      @{Name="Q59904c";Expression={$_."consented-knowfemcondoms-Q59904-Q59904c"}},
      @{Name="Q59904d";Expression={$_."consented-knowfemcondoms-Q59904-Q59904d"}},
      @{Name="Q59904e";Expression={$_."consented-knowfemcondoms-Q59904-Q59904e"}},
      @{Name="Q59904f";Expression={$_."consented-knowfemcondoms-Q59904-Q59904f"}},
      @{Name="Q59905";Expression={$_."consented-knowfemcondoms-Q59905"}},
      @{Name="Q59906";Expression={$_."consented-knowfemcondoms-Q59906"}},
      @{Name="Q59907";Expression={$_."consented-knowfemcondoms-hadsex-Q59907"}},
      @{Name="Q59908";Expression={$_."consented-knowfemcondoms-hadsex-Q59908"}},
      @{Name="Q59909";Expression={$_."consented-knowfemcondoms-hadsex-Q59909"}},
      @{Name="Q59910";Expression={$_."consented-knowfemcondoms-hadsex-Q59910"}},
      @{Name="Q59911";Expression={$_."consented-knowfemcondoms-hadsex-Q59911"}},
      @{Name="Q59912";Expression={$_."consented-knowfemcondoms-Q59912"}},
      @{Name="Q59913";Expression={$_."consented-knowfemcondoms-Q59913"}},
      @{Name="Q59914a";Expression={$_."consented-knowfemcondoms-Q59914-Q59914a"}},
      @{Name="Q59914b";Expression={$_."consented-knowfemcondoms-Q59914-Q59914b"}},
      @{Name="Q59914c";Expression={$_."consented-knowfemcondoms-Q59914-Q59914c"}},
      @{Name="Q59914d";Expression={$_."consented-knowfemcondoms-Q59914-Q59914d"}},
      @{Name="Q59914e";Expression={$_."consented-knowfemcondoms-Q59914-Q59914e"}},
      @{Name="Q59914f";Expression={$_."consented-knowfemcondoms-Q59914-Q59914f"}},
      @{Name="Q59914other";Expression={$_."consented-knowfemcondoms-Q59914-Q59914other"}},
      @{Name="Q59915a";Expression={$_."consented-knowfemcondoms-Q59915-Q59915a"}},
      @{Name="Q59915b";Expression={$_."consented-knowfemcondoms-Q59915-Q59915b"}},
      @{Name="Q59915c";Expression={$_."consented-knowfemcondoms-Q59915-Q59915c"}},
      @{Name="Q59915d";Expression={$_."consented-knowfemcondoms-Q59915-Q59915d"}},
      @{Name="Q59915e";Expression={$_."consented-knowfemcondoms-Q59915-Q59915e"}},
      @{Name="Q59915other";Expression={$_."consented-knowfemcondoms-Q59915-Q59915other"}},
      @{Name="Q59916";Expression={$_."consented-knowfemcondoms-Q59916"}},
      @{Name="Q59917";Expression={$_."consented-knowfemcondoms-Q59917"}},
      @{Name="Q59918";Expression={$_."consented-knowfemcondoms-Q59918"}},
      @{Name="Q59919";Expression={$_."consented-knowfemcondoms-Q59919"}},
      @{Name="Q59920";Expression={$_."consented-knowfemcondoms-Q59920"}},
      @{Name="Q59921";Expression={$_."consented-knowfemcondoms-Q59921"}},
      @{Name="Q59922a";Expression={$_."consented-knowfemcondoms-Q59922-Q59922a"}},
      @{Name="Q59922b";Expression={$_."consented-knowfemcondoms-Q59922-Q59922b"}},
      @{Name="Q59922c";Expression={$_."consented-knowfemcondoms-Q59922-Q59922c"}},
      @{Name="Q59922d";Expression={$_."consented-knowfemcondoms-Q59922-Q59922d"}},
      @{Name="Q59922e";Expression={$_."consented-knowfemcondoms-Q59922-Q59922e"}},
      @{Name="Q59922f";Expression={$_."consented-knowfemcondoms-Q59922-Q59922f"}},
      @{Name="Q59922g";Expression={$_."consented-knowfemcondoms-Q59922-Q59922g"}},
      @{Name="Q59922h";Expression={$_."consented-knowfemcondoms-Q59922-Q59922h"}},
      @{Name="Q59922i";Expression={$_."consented-knowfemcondoms-Q59922-Q59922i"}},
      @{Name="Q59922j";Expression={$_."consented-knowfemcondoms-Q59922-Q59922j"}},
      @{Name="Q59922k";Expression={$_."consented-knowfemcondoms-Q59922-Q59922k"}},
      @{Name="Q59922otherpvn";Expression={$_."consented-knowfemcondoms-Q59922-Q59922otherpvn"}},
      @{Name="Q59922other";Expression={$_."consented-knowfemcondoms-Q59922-Q59922other"}},
      @{Name="Q59923a";Expression={$_."consented-knowfemcondoms-Q59923-Q59923a"}},
      @{Name="Q59923b";Expression={$_."consented-knowfemcondoms-Q59923-Q59923b"}},
      @{Name="Q59923c";Expression={$_."consented-knowfemcondoms-Q59923-Q59923c"}},
      @{Name="Q59923d";Expression={$_."consented-knowfemcondoms-Q59923-Q59923d"}},
      @{Name="Q59923e";Expression={$_."consented-knowfemcondoms-Q59923-Q59923e"}},
      @{Name="Q59923f";Expression={$_."consented-knowfemcondoms-Q59923-Q59923f"}},
      @{Name="Q59923g";Expression={$_."consented-knowfemcondoms-Q59923-Q59923g"}},
      @{Name="Q59923other";Expression={$_."consented-knowfemcondoms-Q59923-Q59923other"}},
      @{Name="Q59924";Expression={$_."consented-knowfemcondoms-Q59924"}},
      @{Name="Q59925";Expression={$_."consented-knowfemcondoms-Q59925"}},
      @{Name="Q59926";Expression={$_."consented-knowfemcondoms-Q59926"}},
      @{Name="Q59927";Expression={$_."consented-knowfemcondoms-Q59927"}},
      @{Name="Q59928a";Expression={$_."consented-knowfemcondoms-Q59928-Q59928a"}},
      @{Name="Q59928b";Expression={$_."consented-knowfemcondoms-Q59928-Q59928b"}},
      @{Name="Q59928c";Expression={$_."consented-knowfemcondoms-Q59928-Q59928c"}},
      @{Name="Q59928d";Expression={$_."consented-knowfemcondoms-Q59928-Q59928d"}},
      @{Name="Q59928e";Expression={$_."consented-knowfemcondoms-Q59928-Q59928e"}},
      @{Name="Q59928other";Expression={$_."consented-knowfemcondoms-Q59928-Q59928other"}},
      @{Name="Q59929a";Expression={$_."consented-knowfemcondoms-Q59929-Q59929a"}},
      @{Name="Q59929b";Expression={$_."consented-knowfemcondoms-Q59929-Q59929b"}},
      @{Name="Q59930";Expression={$_."consented-Q59930"}},
      @{Name="Q59931a";Expression={$_."consented-Q59931-Q59931a"}},
      @{Name="Q59931b";Expression={$_."consented-Q59931-Q59931b"}},
      @{Name="Q59932";Expression={$_."consented-Q59932"}},
      @{Name="Q59932other";Expression={$_."consented-Q59932other"}},
      @{Name="Q59933a";Expression={$_."consented-Q59933-Q59933a"}},
      @{Name="Q59933b";Expression={$_."consented-Q59933-Q59933b"}},
      @{Name="Q59933c";Expression={$_."consented-Q59933-Q59933c"}},
      @{Name="Q59934";Expression={$_."consented-Q59934"}},
      @{Name="Q59935a";Expression={$_."consented-Q59935-Q59935a"}},
      @{Name="Q59935b";Expression={$_."consented-Q59935-Q59935b"}},
      @{Name="Q59935c";Expression={$_."consented-Q59935-Q59935c"}},
      @{Name="Q59935d";Expression={$_."consented-Q59935-Q59935d"}},
      @{Name="Q59935e";Expression={$_."consented-Q59935-Q59935e"}},
      @{Name="Q59935other";Expression={$_."consented-Q59935-Q59935other"}},
      @{Name="Q59936";Expression={$_."consented-Q59936"}},
      @{Name="Q59936re";Expression={$_."consented-Q59936re"}},
      @{Name="Q59937";Expression={$_."consented-Q59937"}},
      @{Name="Q59938a";Expression={$_."consented-Q59938-Q59938a"}},
      @{Name="Q59938b";Expression={$_."consented-Q59938-Q59938b"}},
      @{Name="Q59938c";Expression={$_."consented-Q59938-Q59938c"}},
      @{Name="Q59938d";Expression={$_."consented-Q59938-Q59938d"}},
      @{Name="Q59938e";Expression={$_."consented-Q59938-Q59938e"}},
      @{Name="Q59938f";Expression={$_."consented-Q59938-Q59938f"}},
      @{Name="Q59938g";Expression={$_."consented-Q59938-Q59938g"}},
      @{Name="Q59939a";Expression={$_."consented-Q59939-Q59939a"}},
      @{Name="Q59939b";Expression={$_."consented-Q59939-Q59939b"}},
      @{Name="Q59939c";Expression={$_."consented-Q59939-Q59939c"}},
      @{Name="Q59939d";Expression={$_."consented-Q59939-Q59939d"}},
      @{Name="Q59939e";Expression={$_."consented-Q59939-Q59939e"}},
      @{Name="Q59939f";Expression={$_."consented-Q59939-Q59939f"}},
      @{Name="Q59939g";Expression={$_."consented-Q59939-Q59939g"}},
      @{Name="Q59939h";Expression={$_."consented-Q59939-Q59939h"}},
      @{Name="Q59939other";Expression={$_."consented-Q59939-Q59939other"}},
      @{Name="Q59940a";Expression={$_."consented-Q59940-Q59940a"}},
      @{Name="Q59940b";Expression={$_."consented-Q59940-Q59940b"}},
      @{Name="Q59940c";Expression={$_."consented-Q59940-Q59940c"}},
      @{Name="Q59940d";Expression={$_."consented-Q59940-Q59940d"}},
      @{Name="Q59940e";Expression={$_."consented-Q59940-Q59940e"}},
      @{Name="Q59940f";Expression={$_."consented-Q59940-Q59940f"}},
      @{Name="Q59941a";Expression={$_."consented-Q59941-Q59941a"}},
      @{Name="Q59941b";Expression={$_."consented-Q59941-Q59941b"}},
      @{Name="Q59941c";Expression={$_."consented-Q59941-Q59941c"}},
      @{Name="Q59941d";Expression={$_."consented-Q59941-Q59941d"}},
      @{Name="Q59941other";Expression={$_."consented-Q59941-Q59941other"}},
      @{Name="Q59942";Expression={$_."consented-Q59942"}},
      @{Name="Q59942orgn";Expression={$_."consented-Q59942orgn"}},
      @{Name="Q59942other";Expression={$_."consented-Q59942other"}},
      @{Name="Q59943";Expression={$_."consented-Q59943"}},
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
$Q501= $i.Q501
$Q502a= $i.Q502a
$Q502b= $i.Q502b
$Q502c= $i.Q502c
$Q502d= $i.Q502d
$Q502e= $i.Q502e
$Q502f= $i.Q502f
$Q502g= $i.Q502g
$Q502h= $i.Q502h
$Q502i= $i.Q502i
$Q502other= $i.Q502other.replace("'","")
$Q503vmmc= $i.Q503vmmc
$Q503othervmmc= $i.Q503othervmmc.replace("'","")
$Q504vmmc= $i.Q504vmmc
$Q504othervmmc= $i.Q504othervmmc.replace("'","")
$Q503prep= $i.Q503prep
$Q503otherprep= $i.Q503otherprep.replace("'","")
$Q504prep= $i.Q504prep
$Q504otherprep= $i.Q504otherprep.replace("'","")
$Q503mcondom= $i.Q503mcondom
$Q503othermcondom= $i.Q503othermcondom.replace("'","")
$Q504mcondom= $i.Q504mcondom
$Q504othermcondom= $i.Q504othermcondom.replace("'","")
$Q503fcondom= $i.Q503fcondom
$Q503otherfcondom= $i.Q503otherfcondom.replace("'","")
$Q504fcondom= $i.Q504fcondom
$Q504otherfcondom= $i.Q504otherfcondom.replace("'","")
$Q503sp= $i.Q503sp
$Q503othersp= $i.Q503othersp.replace("'","")
$Q504sp= $i.Q504sp
$Q504othersp= $i.Q504othersp.replace("'","")
$Q503hivtc= $i.Q503hivtc
$Q503otherhivtc= $i.Q503otherhivtc.replace("'","")
$Q504hivtc= $i.Q504hivtc
$Q504otherhivtc= $i.Q504otherhivtc.replace("'","")
$Q505a= $i.Q505a
$Q505b= $i.Q505b
$Q505c= $i.Q505c
$Q505d= $i.Q505d
$Q505e= $i.Q505e
$Q505f= $i.Q505f
$Q505g= $i.Q505g
$Q506a= $i.Q506a
$Q506b= $i.Q506b
$Q506c= $i.Q506c
$Q506d= $i.Q506d
$Q506e= $i.Q506e
$Q506f= $i.Q506f
$Q506g= $i.Q506g
$Q507= $i.Q507
$Q507other= $i.Q507other.replace("'","")
$Q508vmmc= $i.Q508vmmc
$Q508prep= $i.Q508prep
$Q508mcondom= $i.Q508mcondom
$Q508fcondom= $i.Q508fcondom
$Q508hivtc= $i.Q508hivtc
$Q509= $i.Q509
$Q510= $i.Q510
$Q511= $i.Q511
$Q512= $i.Q512
$Q514= $i.Q514
$Q515a= $i.Q515a
$Q515b= $i.Q515b
$Q515c= $i.Q515c
$Q515d= $i.Q515d
$Q516= $i.Q516
$Q516b= $i.Q516b
$Q517a= $i.Q517a
$Q517b= $i.Q517b
$Q517c= $i.Q517c
$Q517d= $i.Q517d
$Q517e= $i.Q517e
$Q518a= $i.Q518a
$Q518b= $i.Q518b
$Q518c= $i.Q518c
$Q519a= $i.Q519a
$Q519b= $i.Q519b
$Q519c= $i.Q519c
$Q519d= $i.Q519d
$Q520= $i.Q520
$Q521= $i.Q521
$Q522= $i.Q522
$Q523= $i.Q523
$Q524a= $i.Q524a
$Q524b= $i.Q524b
$Q524c= $i.Q524c
$Q524d= $i.Q524d
$Q524e= $i.Q524e
$Q524f= $i.Q524f
$Q524g= $i.Q524g
$Q524other= $i.Q524other.replace("'","")
$Q525= $i.Q525
$Q526= $i.Q526
$Q527= $i.Q527
$Q528= $i.Q528
$Q529a= $i.Q529a
$Q529b= $i.Q529b
$Q529c= $i.Q529c
$Q529d= $i.Q529d
$Q529e= $i.Q529e
$Q529f= $i.Q529f
$Q529g= $i.Q529g
$Q529h= $i.Q529h
$Q529i= $i.Q529i
$Q529j= $i.Q529j
$Q529k= $i.Q529k
$Q529l= $i.Q529l
$Q529m= $i.Q529m
$Q529n= $i.Q529n
$Q529othermthd= $i.Q529othermthd.replace("'","")
$Q529other= $i.Q529other.replace("'","")
$Q530a= $i.Q530a
$Q530b= $i.Q530b
$Q530c= $i.Q530c
$Q530d= $i.Q530d
$Q530e= $i.Q530e
$Q530f= $i.Q530f.replace("'","")
$Q531= $i.Q531
$Q532= $i.Q532
$Q533= $i.Q533
$Q534teenager= $i.Q534teenager
$Q534youngman= $i.Q534youngman
$Q535= $i.Q535
$Q536= $i.Q536
$Q537= $i.Q537
$Q538= $i.Q538
$Q539= $i.Q539
$Q539Q545= $i.Q539Q545
$Q539Q545a= $i.Q539Q545a.replace("'","")
$Q539Q545b= $i.Q539Q545b.replace("'","")
$Q540= $i.Q540
$Q541a= $i.Q541a
$Q541b= $i.Q541b
$Q541c= $i.Q541c
$Q541other= $i.Q541other.replace("'","")
$Q542= $i.Q542
$Q543= $i.Q543
$Q544= $i.Q544
$Q545= $i.Q545
$Q545a= $i.Q545a
$Q545b= $i.Q545b
$Q546= $i.Q546
$Q547a= $i.Q547a
$Q547b= $i.Q547b
$Q547c= $i.Q547c
$Q548a= $i.Q548a
$Q548b= $i.Q548b
$Q548c= $i.Q548c
$Q548d= $i.Q548d
$Q548e= $i.Q548e
$Q548f= $i.Q548f
$Q548g= $i.Q548g
$Q549= $i.Q549
$Q550= $i.Q550
$Q551= $i.Q551
$Q552= $i.Q552
$Q553= $i.Q553
$Q554a= $i.Q554a
$Q554b= $i.Q554b
$Q554c= $i.Q554c
$Q554d= $i.Q554d
$Q554e= $i.Q554e
$Q554f= $i.Q554f
$Q554g= $i.Q554g
$Q554h= $i.Q554h
$Q554i= $i.Q554i
$Q554other= $i.Q554other.replace("'","")
$Q555= $i.Q555
$Q556= $i.Q556
$Q557= $i.Q557
$Q558= $i.Q558
$Q559a= $i.Q559a
$Q559b= $i.Q559b
$Q559c= $i.Q559c
$Q559d= $i.Q559d
$Q559e= $i.Q559e
$Q559f= $i.Q559f
$Q559g= $i.Q559g
$Q559h= $i.Q559h
$Q559j= $i.Q559j
$Q559i= $i.Q559i
$Q559other= $i.Q559other.replace("'","")
$Q560a= $i.Q560a
$Q560b= $i.Q560b
$Q560c= $i.Q560c
$Q560d= $i.Q560d
$Q560e= $i.Q560e
$Q560f= $i.Q560f
$Q560other= $i.Q560other.replace("'","")
$Q561= $i.Q561
$Q562= $i.Q562
$Q563= $i.Q563
$Q564teenager= $i.Q564teenager
$Q564youngman= $i.Q564youngman
$Q565a= $i.Q565a
$Q565b= $i.Q565b
$Q566= $i.Q566
$Q567= $i.Q567
$Q568= $i.Q568
$Q568otherprev= $i.Q568otherprev.replace("'","")
$Q568other= $i.Q568other.replace("'","")
$Q569= $i.Q569
$Q570= $i.Q570
$Q570other= $i.Q570other.replace("'","")
$Q571= $i.Q571
$Q572a= $i.Q572a
$Q572b= $i.Q572b
$Q572c= $i.Q572c
$Q572d= $i.Q572d
$Q572e= $i.Q572e
$Q572f= $i.Q572f
$Q573= $i.Q573
$Q574= $i.Q574
$Q575= $i.Q575
$Q576= $i.Q576
$Q577= $i.Q577
$Q578= $i.Q578
$Q579= $i.Q579
$Q580= $i.Q580
$Q581= $i.Q581
$Q582a= $i.Q582a
$Q582b= $i.Q582b
$Q582c= $i.Q582c
$Q582d= $i.Q582d
$Q582e= $i.Q582e
$Q582f= $i.Q582f
$Q582other= $i.Q582other.replace("'","")
$Q583a= $i.Q583a
$Q583b= $i.Q583b
$Q583c= $i.Q583c
$Q583d= $i.Q583d
$Q583e= $i.Q583e
$Q583other= $i.Q583other.replace("'","")
$Q584= $i.Q584
$Q585= $i.Q585
$Q586= $i.Q586
$Q587= $i.Q587
$Q588= $i.Q588
$Q589= $i.Q589
$Q590a= $i.Q590a
$Q590b= $i.Q590b
$Q590c= $i.Q590c
$Q590d= $i.Q590d
$Q590e= $i.Q590e
$Q590f= $i.Q590f
$Q590g= $i.Q590g
$Q590h= $i.Q590h
$Q590i= $i.Q590i
$Q590otherpvn= $i.Q590otherpvn.replace("'","")
$Q590other= $i.Q590other.replace("'","")
$Q591a= $i.Q591a
$Q591b= $i.Q591b
$Q591c= $i.Q591c
$Q591d= $i.Q591d
$Q591e= $i.Q591e
$Q591f= $i.Q591f
$Q591g= $i.Q591g
$Q591other= $i.Q591other.replace("'","")
$Q592= $i.Q592
$Q593= $i.Q593
$Q594= $i.Q594
$Q595a= $i.Q595a
$Q595b= $i.Q595b
$Q595c= $i.Q595c
$Q595d= $i.Q595d
$Q595e= $i.Q595e
$Q595other= $i.Q595other.replace("'","")
$Q596a= $i.Q596a
$Q596b= $i.Q596b
$Q597= $i.Q597
$Q598= $i.Q598
$Q599= $i.Q599
$Q599otherpvn= $i.Q599otherpvn.replace("'","")
$Q599other= $i.Q599other.replace("'","")
$Q59901= $i.Q59901
$Q59902= $i.Q59902
$Q59902other= $i.Q59902other.replace("'","")
$Q59903= $i.Q59903
$Q59904a= $i.Q59904a
$Q59904b= $i.Q59904b
$Q59904c= $i.Q59904c
$Q59904d= $i.Q59904d
$Q59904e= $i.Q59904e
$Q59904f= $i.Q59904f
$Q59905= $i.Q59905
$Q59906= $i.Q59906
$Q59907= $i.Q59907
$Q59908= $i.Q59908
$Q59909= $i.Q59909
$Q59910= $i.Q59910
$Q59911= $i.Q59911
$Q59912= $i.Q59912
$Q59913= $i.Q59913
$Q59914a= $i.Q59914a
$Q59914b= $i.Q59914b
$Q59914c= $i.Q59914c
$Q59914d= $i.Q59914d
$Q59914e= $i.Q59914e
$Q59914f= $i.Q59914f
$Q59914other= $i.Q59914other.replace("'","")
$Q59915a= $i.Q59915a
$Q59915b= $i.Q59915b
$Q59915c= $i.Q59915c
$Q59915d= $i.Q59915d
$Q59915e= $i.Q59915e
$Q59915other= $i.Q59915other.replace("'","")
$Q59916= $i.Q59916
$Q59917= $i.Q59917
$Q59918= $i.Q59918
$Q59919= $i.Q59919
$Q59920= $i.Q59920
$Q59921= $i.Q59921
$Q59922a= $i.Q59922a
$Q59922b= $i.Q59922b
$Q59922c= $i.Q59922c
$Q59922d= $i.Q59922d
$Q59922e= $i.Q59922e
$Q59922f= $i.Q59922f
$Q59922g= $i.Q59922g
$Q59922h= $i.Q59922h
$Q59922i= $i.Q59922i
$Q59922j= $i.Q59922j
$Q59922k= $i.Q59922k
$Q59922otherpvn= $i.Q59922otherpvn.replace("'","")
$Q59922other= $i.Q59922other.replace("'","")
$Q59923a= $i.Q59923a
$Q59923b= $i.Q59923b
$Q59923c= $i.Q59923c
$Q59923d= $i.Q59923d
$Q59923e= $i.Q59923e
$Q59923f= $i.Q59923f
$Q59923g= $i.Q59923g
$Q59923other= $i.Q59923other.replace("'","")
$Q59924= $i.Q59924
$Q59925= $i.Q59925
$Q59926= $i.Q59926
$Q59927= $i.Q59927
$Q59928a= $i.Q59928a
$Q59928b= $i.Q59928b
$Q59928c= $i.Q59928c
$Q59928d= $i.Q59928d
$Q59928e= $i.Q59928e
$Q59928other= $i.Q59928other.replace("'","")
$Q59929a= $i.Q59929a
$Q59929b= $i.Q59929b
$Q59930= $i.Q59930
$Q59931a= $i.Q59931a
$Q59931b= $i.Q59931b
$Q59932= $i.Q59932
$Q59932other= $i.Q59932other.replace("'","")
$Q59933a= $i.Q59933a
$Q59933b= $i.Q59933b
$Q59933c= $i.Q59933c
$Q59934= $i.Q59934
$Q59935a= $i.Q59935a
$Q59935b= $i.Q59935b
$Q59935c= $i.Q59935c
$Q59935d= $i.Q59935d
$Q59935e= $i.Q59935e
$Q59935other= $i.Q59935other.replace("'","")
$Q59936= $i.Q59936
$Q59936re= $i.Q59936re
$Q59937= $i.Q59937
$Q59938a= $i.Q59938a
$Q59938b= $i.Q59938b
$Q59938c= $i.Q59938c
$Q59938d= $i.Q59938d
$Q59938e= $i.Q59938e
$Q59938f= $i.Q59938f
$Q59938g= $i.Q59938g.replace("'","")
$Q59939a= $i.Q59939a
$Q59939b= $i.Q59939b
$Q59939c= $i.Q59939c
$Q59939d= $i.Q59939d
$Q59939e= $i.Q59939e
$Q59939f= $i.Q59939f
$Q59939g= $i.Q59939g
$Q59939h= $i.Q59939h
$Q59939other= $i.Q59939other.replace("'","")
$Q59940a= $i.Q59940a
$Q59940b= $i.Q59940b
$Q59940c= $i.Q59940c
$Q59940d= $i.Q59940d.replace("'","")
$Q59940e= $i.Q59940e
$Q59940f= $i.Q59940f.replace("'","")
$Q59941a= $i.Q59941a
$Q59941b= $i.Q59941b
$Q59941c= $i.Q59941c
$Q59941d= $i.Q59941d
$Q59941other= $i.Q59941other.replace("'","")
$Q59942= $i.Q59942
$Q59942orgn= $i.Q59942orgn.replace("'","")
$Q59942other= $i.Q59942other.replace("'","")
$Q59943= $i.Q59943
$METAKEY= $i.METAKEY


$SQLQuery = "INSERT INTO hivprev_7 ( hhkey,
hhmem_key,
Q501,
Q502a,
Q502b,
Q502c,
Q502d,
Q502e,
Q502f,
Q502g,
Q502h,
Q502i,
Q502other,
Q503vmmc,
Q503othervmmc,
Q504vmmc,
Q504othervmmc,
Q503prep,
Q503otherprep,
Q504prep,
Q504otherprep,
Q503mcondom,
Q503othermcondom,
Q504mcondom,
Q504othermcondom,
Q503fcondom,
Q503otherfcondom,
Q504fcondom,
Q504otherfcondom,
Q503sp,
Q503othersp,
Q504sp,
Q504othersp,
Q503hivtc,
Q503otherhivtc,
Q504hivtc,
Q504otherhivtc,
Q505a,
Q505b,
Q505c,
Q505d,
Q505e,
Q505f,
Q505g,
Q506a,
Q506b,
Q506c,
Q506d,
Q506e,
Q506f,
Q506g,
Q507,
Q507other,
Q508vmmc,
Q508prep,
Q508mcondom,
Q508fcondom,
Q508hivtc,
Q509,
Q510,
Q511,
Q512,
Q514,
Q515a,
Q515b,
Q515c,
Q515d,
Q516,
Q516b,
Q517a,
Q517b,
Q517c,
Q517d,
Q517e,
Q518a,
Q518b,
Q518c,
Q519a,
Q519b,
Q519c,
Q519d,
Q520,
Q521,
Q522,
Q523,
Q524a,
Q524b,
Q524c,
Q524d,
Q524e,
Q524f,
Q524g,
Q524other,
Q525,
Q526,
Q527,
Q528,
Q529a,
Q529b,
Q529c,
Q529d,
Q529e,
Q529f,
Q529g,
Q529h,
Q529i,
Q529j,
Q529k,
Q529l,
Q529m,
Q529n,
Q529othermthd,
Q529other,
Q530a,
Q530b,
Q530c,
Q530d,
Q530e,
Q530f,
Q531,
Q532,
Q533,
Q534teenager,
Q534youngman,
Q535,
Q536,
Q537,
Q538,
Q539,
Q539Q545,
Q539Q545a,
Q539Q545b,
Q540,
Q541a,
Q541b,
Q541c,
Q541other,
Q542,
Q543,
Q544,
Q545,
Q545a,
Q545b,
Q546,
Q547a,
Q547b,
Q547c,
Q548a,
Q548b,
Q548c,
Q548d,
Q548e,
Q548f,
Q548g,
Q549,
Q550,
Q551,
Q552,
Q553,
Q554a,
Q554b,
Q554c,
Q554d,
Q554e,
Q554f,
Q554g,
Q554h,
Q554i,
Q554other,
Q555,
Q556,
Q557,
Q558,
Q559a,
Q559b,
Q559c,
Q559d,
Q559e,
Q559f,
Q559g,
Q559h,
Q559j,
Q559i,
Q559other,
Q560a,
Q560b,
Q560c,
Q560d,
Q560e,
Q560f,
Q560other,
Q561,
Q562,
Q563,
Q564teenager,
Q564youngman,
Q565a,
Q565b,
Q566,
Q567,
Q568,
Q568otherprev,
Q568other,
Q569,
Q570,
Q570other,
Q571,
Q572a,
Q572b,
Q572c,
Q572d,
Q572e,
Q572f,
Q573,
Q574,
Q575,
Q576,
Q577,
Q578,
Q579,
Q580,
Q581,
Q582a,
Q582b,
Q582c,
Q582d,
Q582e,
Q582f,
Q582other,
Q583a,
Q583b,
Q583c,
Q583d,
Q583e,
Q583other,
Q584,
Q585,
Q586,
Q587,
Q588,
Q589,
Q590a,
Q590b,
Q590c,
Q590d,
Q590e,
Q590f,
Q590g,
Q590h,
Q590i,
Q590otherpvn,
Q590other,
Q591a,
Q591b,
Q591c,
Q591d,
Q591e,
Q591f,
Q591g,
Q591other,
Q592,
Q593,
Q594,
Q595a,
Q595b,
Q595c,
Q595d,
Q595e,
Q595other,
Q596a,
Q596b,
Q597,
Q598,
Q599,
Q599otherpvn,
Q599other,
Q59901,
Q59902,
Q59902other,
Q59903,
Q59904a,
Q59904b,
Q59904c,
Q59904d,
Q59904e,
Q59904f,
Q59905,
Q59906,
Q59907,
Q59908,
Q59909,
Q59910,
Q59911,
Q59912,
Q59913,
Q59914a,
Q59914b,
Q59914c,
Q59914d,
Q59914e,
Q59914f,
Q59914other,
Q59915a,
Q59915b,
Q59915c,
Q59915d,
Q59915e,
Q59915other,
Q59916,
Q59917,
Q59918,
Q59919,
Q59920,
Q59921,
Q59922a,
Q59922b,
Q59922c,
Q59922d,
Q59922e,
Q59922f,
Q59922g,
Q59922h,
Q59922i,
Q59922j,
Q59922k,
Q59922otherpvn,
Q59922other,
Q59923a,
Q59923b,
Q59923c,
Q59923d,
Q59923e,
Q59923f,
Q59923g,
Q59923other,
Q59924,
Q59925,
Q59926,
Q59927,
Q59928a,
Q59928b,
Q59928c,
Q59928d,
Q59928e,
Q59928other,
Q59929a,
Q59929b,
Q59930,
Q59931a,
Q59931b,
Q59932,
Q59932other,
Q59933a,
Q59933b,
Q59933c,
Q59934,
Q59935a,
Q59935b,
Q59935c,
Q59935d,
Q59935e,
Q59935other,
Q59936,
Q59936re,
Q59937,
Q59938a,
Q59938b,
Q59938c,
Q59938d,
Q59938e,
Q59938f,
Q59938g,
Q59939a,
Q59939b,
Q59939c,
Q59939d,
Q59939e,
Q59939f,
Q59939g,
Q59939h,
Q59939other,
Q59940a,
Q59940b,
Q59940c,
Q59940d,
Q59940e,
Q59940f,
Q59941a,
Q59941b,
Q59941c,
Q59941d,
Q59941other,
Q59942,
Q59942orgn,
Q59942other,
Q59943,
METAKEY)      VALUES ('$hhkey',
'$hhmem_key',
'$Q501',
'$Q502a',
'$Q502b',
'$Q502c',
'$Q502d',
'$Q502e',
'$Q502f',
'$Q502g',
'$Q502h',
'$Q502i',
'$Q502other',
'$Q503vmmc',
'$Q503othervmmc',
'$Q504vmmc',
'$Q504othervmmc',
'$Q503prep',
'$Q503otherprep',
'$Q504prep',
'$Q504otherprep',
'$Q503mcondom',
'$Q503othermcondom',
'$Q504mcondom',
'$Q504othermcondom',
'$Q503fcondom',
'$Q503otherfcondom',
'$Q504fcondom',
'$Q504otherfcondom',
'$Q503sp',
'$Q503othersp',
'$Q504sp',
'$Q504othersp',
'$Q503hivtc',
'$Q503otherhivtc',
'$Q504hivtc',
'$Q504otherhivtc',
'$Q505a',
'$Q505b',
'$Q505c',
'$Q505d',
'$Q505e',
'$Q505f',
'$Q505g',
'$Q506a',
'$Q506b',
'$Q506c',
'$Q506d',
'$Q506e',
'$Q506f',
'$Q506g',
'$Q507',
'$Q507other',
'$Q508vmmc',
'$Q508prep',
'$Q508mcondom',
'$Q508fcondom',
'$Q508hivtc',
'$Q509',
'$Q510',
'$Q511',
'$Q512',
'$Q514',
'$Q515a',
'$Q515b',
'$Q515c',
'$Q515d',
'$Q516',
'$Q516b',
'$Q517a',
'$Q517b',
'$Q517c',
'$Q517d',
'$Q517e',
'$Q518a',
'$Q518b',
'$Q518c',
'$Q519a',
'$Q519b',
'$Q519c',
'$Q519d',
'$Q520',
'$Q521',
'$Q522',
'$Q523',
'$Q524a',
'$Q524b',
'$Q524c',
'$Q524d',
'$Q524e',
'$Q524f',
'$Q524g',
'$Q524other',
'$Q525',
'$Q526',
'$Q527',
'$Q528',
'$Q529a',
'$Q529b',
'$Q529c',
'$Q529d',
'$Q529e',
'$Q529f',
'$Q529g',
'$Q529h',
'$Q529i',
'$Q529j',
'$Q529k',
'$Q529l',
'$Q529m',
'$Q529n',
'$Q529othermthd',
'$Q529other',
'$Q530a',
'$Q530b',
'$Q530c',
'$Q530d',
'$Q530e',
'$Q530f',
'$Q531',
'$Q532',
'$Q533',
'$Q534teenager',
'$Q534youngman',
'$Q535',
'$Q536',
'$Q537',
'$Q538',
'$Q539',
'$Q539Q545',
'$Q539Q545a',
'$Q539Q545b',
'$Q540',
'$Q541a',
'$Q541b',
'$Q541c',
'$Q541other',
'$Q542',
'$Q543',
'$Q544',
'$Q545',
'$Q545a',
'$Q545b',
'$Q546',
'$Q547a',
'$Q547b',
'$Q547c',
'$Q548a',
'$Q548b',
'$Q548c',
'$Q548d',
'$Q548e',
'$Q548f',
'$Q548g',
'$Q549',
'$Q550',
'$Q551',
'$Q552',
'$Q553',
'$Q554a',
'$Q554b',
'$Q554c',
'$Q554d',
'$Q554e',
'$Q554f',
'$Q554g',
'$Q554h',
'$Q554i',
'$Q554other',
'$Q555',
'$Q556',
'$Q557',
'$Q558',
'$Q559a',
'$Q559b',
'$Q559c',
'$Q559d',
'$Q559e',
'$Q559f',
'$Q559g',
'$Q559h',
'$Q559j',
'$Q559i',
'$Q559other',
'$Q560a',
'$Q560b',
'$Q560c',
'$Q560d',
'$Q560e',
'$Q560f',
'$Q560other',
'$Q561',
'$Q562',
'$Q563',
'$Q564teenager',
'$Q564youngman',
'$Q565a',
'$Q565b',
'$Q566',
'$Q567',
'$Q568',
'$Q568otherprev',
'$Q568other',
'$Q569',
'$Q570',
'$Q570other',
'$Q571',
'$Q572a',
'$Q572b',
'$Q572c',
'$Q572d',
'$Q572e',
'$Q572f',
'$Q573',
'$Q574',
'$Q575',
'$Q576',
'$Q577',
'$Q578',
'$Q579',
'$Q580',
'$Q581',
'$Q582a',
'$Q582b',
'$Q582c',
'$Q582d',
'$Q582e',
'$Q582f',
'$Q582other',
'$Q583a',
'$Q583b',
'$Q583c',
'$Q583d',
'$Q583e',
'$Q583other',
'$Q584',
'$Q585',
'$Q586',
'$Q587',
'$Q588',
'$Q589',
'$Q590a',
'$Q590b',
'$Q590c',
'$Q590d',
'$Q590e',
'$Q590f',
'$Q590g',
'$Q590h',
'$Q590i',
'$Q590otherpvn',
'$Q590other',
'$Q591a',
'$Q591b',
'$Q591c',
'$Q591d',
'$Q591e',
'$Q591f',
'$Q591g',
'$Q591other',
'$Q592',
'$Q593',
'$Q594',
'$Q595a',
'$Q595b',
'$Q595c',
'$Q595d',
'$Q595e',
'$Q595other',
'$Q596a',
'$Q596b',
'$Q597',
'$Q598',
'$Q599',
'$Q599otherpvn',
'$Q599other',
'$Q59901',
'$Q59902',
'$Q59902other',
'$Q59903',
'$Q59904a',
'$Q59904b',
'$Q59904c',
'$Q59904d',
'$Q59904e',
'$Q59904f',
'$Q59905',
'$Q59906',
'$Q59907',
'$Q59908',
'$Q59909',
'$Q59910',
'$Q59911',
'$Q59912',
'$Q59913',
'$Q59914a',
'$Q59914b',
'$Q59914c',
'$Q59914d',
'$Q59914e',
'$Q59914f',
'$Q59914other',
'$Q59915a',
'$Q59915b',
'$Q59915c',
'$Q59915d',
'$Q59915e',
'$Q59915other',
'$Q59916',
'$Q59917',
'$Q59918',
'$Q59919',
'$Q59920',
'$Q59921',
'$Q59922a',
'$Q59922b',
'$Q59922c',
'$Q59922d',
'$Q59922e',
'$Q59922f',
'$Q59922g',
'$Q59922h',
'$Q59922i',
'$Q59922j',
'$Q59922k',
'$Q59922otherpvn',
'$Q59922other',
'$Q59923a',
'$Q59923b',
'$Q59923c',
'$Q59923d',
'$Q59923e',
'$Q59923f',
'$Q59923g',
'$Q59923other',
'$Q59924',
'$Q59925',
'$Q59926',
'$Q59927',
'$Q59928a',
'$Q59928b',
'$Q59928c',
'$Q59928d',
'$Q59928e',
'$Q59928other',
'$Q59929a',
'$Q59929b',
'$Q59930',
'$Q59931a',
'$Q59931b',
'$Q59932',
'$Q59932other',
'$Q59933a',
'$Q59933b',
'$Q59933c',
'$Q59934',
'$Q59935a',
'$Q59935b',
'$Q59935c',
'$Q59935d',
'$Q59935e',
'$Q59935other',
'$Q59936',
'$Q59936re',
'$Q59937',
'$Q59938a',
'$Q59938b',
'$Q59938c',
'$Q59938d',
'$Q59938e',
'$Q59938f',
'$Q59938g',
'$Q59939a',
'$Q59939b',
'$Q59939c',
'$Q59939d',
'$Q59939e',
'$Q59939f',
'$Q59939g',
'$Q59939h',
'$Q59939other',
'$Q59940a',
'$Q59940b',
'$Q59940c',
'$Q59940d',
'$Q59940e',
'$Q59940f',
'$Q59941a',
'$Q59941b',
'$Q59941c',
'$Q59941d',
'$Q59941other',
'$Q59942',
'$Q59942orgn',
'$Q59942other',
'$Q59943',
'$METAKEY')"



 $impcsv = invoke-sqlcmd -Username $LocalDatabaseUser -Password $LocalDatabasePWD -Database $LocalDatabaseName -Query $SQLQuery  -serverinstance $LocalSQLServerInstance  
        $InfoMessage = "Household memID $hhmem_key successfully uploaded to YZ-UHP Local MSSSQL Server."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 
 $InfoMessage = "Successfully imported $count HIVPREV  Qstns into the YZ-UHP database" 
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
$Q501= $i.Q501
$Q502a= $i.Q502a
$Q502b= $i.Q502b
$Q502c= $i.Q502c
$Q502d= $i.Q502d
$Q502e= $i.Q502e
$Q502f= $i.Q502f
$Q502g= $i.Q502g
$Q502h= $i.Q502h
$Q502i= $i.Q502i
$Q502other= $i.Q502other.replace("'","")
$Q503vmmc= $i.Q503vmmc
$Q503othervmmc= $i.Q503othervmmc.replace("'","")
$Q504vmmc= $i.Q504vmmc
$Q504othervmmc= $i.Q504othervmmc.replace("'","")
$Q503prep= $i.Q503prep
$Q503otherprep= $i.Q503otherprep.replace("'","")
$Q504prep= $i.Q504prep
$Q504otherprep= $i.Q504otherprep.replace("'","")
$Q503mcondom= $i.Q503mcondom
$Q503othermcondom= $i.Q503othermcondom.replace("'","")
$Q504mcondom= $i.Q504mcondom
$Q504othermcondom= $i.Q504othermcondom.replace("'","")
$Q503fcondom= $i.Q503fcondom
$Q503otherfcondom= $i.Q503otherfcondom.replace("'","")
$Q504fcondom= $i.Q504fcondom
$Q504otherfcondom= $i.Q504otherfcondom.replace("'","")
$Q503sp= $i.Q503sp
$Q503othersp= $i.Q503othersp.replace("'","")
$Q504sp= $i.Q504sp
$Q504othersp= $i.Q504othersp.replace("'","")
$Q503hivtc= $i.Q503hivtc
$Q503otherhivtc= $i.Q503otherhivtc.replace("'","")
$Q504hivtc= $i.Q504hivtc
$Q504otherhivtc= $i.Q504otherhivtc.replace("'","")
$Q505a= $i.Q505a
$Q505b= $i.Q505b
$Q505c= $i.Q505c
$Q505d= $i.Q505d
$Q505e= $i.Q505e
$Q505f= $i.Q505f
$Q505g= $i.Q505g
$Q506a= $i.Q506a
$Q506b= $i.Q506b
$Q506c= $i.Q506c
$Q506d= $i.Q506d
$Q506e= $i.Q506e
$Q506f= $i.Q506f
$Q506g= $i.Q506g
$Q507= $i.Q507
$Q507other= $i.Q507other.replace("'","")
$Q508vmmc= $i.Q508vmmc
$Q508prep= $i.Q508prep
$Q508mcondom= $i.Q508mcondom
$Q508fcondom= $i.Q508fcondom
$Q508hivtc= $i.Q508hivtc
$Q509= $i.Q509
$Q510= $i.Q510
$Q511= $i.Q511
$Q512= $i.Q512
$Q514= $i.Q514
$Q515a= $i.Q515a
$Q515b= $i.Q515b
$Q515c= $i.Q515c
$Q515d= $i.Q515d
$Q516= $i.Q516
$Q516b= $i.Q516b
$Q517a= $i.Q517a
$Q517b= $i.Q517b
$Q517c= $i.Q517c
$Q517d= $i.Q517d
$Q517e= $i.Q517e
$Q518a= $i.Q518a
$Q518b= $i.Q518b
$Q518c= $i.Q518c
$Q519a= $i.Q519a
$Q519b= $i.Q519b
$Q519c= $i.Q519c
$Q519d= $i.Q519d
$Q520= $i.Q520
$Q521= $i.Q521
$Q522= $i.Q522
$Q523= $i.Q523
$Q524a= $i.Q524a
$Q524b= $i.Q524b
$Q524c= $i.Q524c
$Q524d= $i.Q524d
$Q524e= $i.Q524e
$Q524f= $i.Q524f
$Q524g= $i.Q524g
$Q524other= $i.Q524other.replace("'","")
$Q525= $i.Q525
$Q526= $i.Q526
$Q527= $i.Q527
$Q528= $i.Q528
$Q529a= $i.Q529a
$Q529b= $i.Q529b
$Q529c= $i.Q529c
$Q529d= $i.Q529d
$Q529e= $i.Q529e
$Q529f= $i.Q529f
$Q529g= $i.Q529g
$Q529h= $i.Q529h
$Q529i= $i.Q529i
$Q529j= $i.Q529j
$Q529k= $i.Q529k
$Q529l= $i.Q529l
$Q529m= $i.Q529m
$Q529n= $i.Q529n
$Q529othermthd= $i.Q529othermthd.replace("'","")
$Q529other= $i.Q529other.replace("'","")
$Q530a= $i.Q530a
$Q530b= $i.Q530b
$Q530c= $i.Q530c
$Q530d= $i.Q530d
$Q530e= $i.Q530e
$Q530f= $i.Q530f.replace("'","")
$Q531= $i.Q531
$Q532= $i.Q532
$Q533= $i.Q533
$Q534teenager= $i.Q534teenager
$Q534youngman= $i.Q534youngman
$Q535= $i.Q535
$Q536= $i.Q536
$Q537= $i.Q537
$Q538= $i.Q538
$Q539= $i.Q539
$Q539Q545= $i.Q539Q545
$Q539Q545a= $i.Q539Q545a.replace("'","")
$Q539Q545b= $i.Q539Q545b.replace("'","")
$Q540= $i.Q540
$Q541a= $i.Q541a
$Q541b= $i.Q541b
$Q541c= $i.Q541c
$Q541other= $i.Q541other.replace("'","")
$Q542= $i.Q542
$Q543= $i.Q543
$Q544= $i.Q544
$Q545= $i.Q545
$Q545a= $i.Q545a
$Q545b= $i.Q545b
$Q546= $i.Q546
$Q547a= $i.Q547a
$Q547b= $i.Q547b
$Q547c= $i.Q547c
$Q548a= $i.Q548a
$Q548b= $i.Q548b
$Q548c= $i.Q548c
$Q548d= $i.Q548d
$Q548e= $i.Q548e
$Q548f= $i.Q548f
$Q548g= $i.Q548g
$Q549= $i.Q549
$Q550= $i.Q550
$Q551= $i.Q551
$Q552= $i.Q552
$Q553= $i.Q553
$Q554a= $i.Q554a
$Q554b= $i.Q554b
$Q554c= $i.Q554c
$Q554d= $i.Q554d
$Q554e= $i.Q554e
$Q554f= $i.Q554f
$Q554g= $i.Q554g
$Q554h= $i.Q554h
$Q554i= $i.Q554i
$Q554other= $i.Q554other.replace("'","")
$Q555= $i.Q555
$Q556= $i.Q556
$Q557= $i.Q557
$Q558= $i.Q558
$Q559a= $i.Q559a
$Q559b= $i.Q559b
$Q559c= $i.Q559c
$Q559d= $i.Q559d
$Q559e= $i.Q559e
$Q559f= $i.Q559f
$Q559g= $i.Q559g
$Q559h= $i.Q559h
$Q559j= $i.Q559j
$Q559i= $i.Q559i
$Q559other= $i.Q559other.replace("'","")
$Q560a= $i.Q560a
$Q560b= $i.Q560b
$Q560c= $i.Q560c
$Q560d= $i.Q560d
$Q560e= $i.Q560e
$Q560f= $i.Q560f
$Q560other= $i.Q560other.replace("'","")
$Q561= $i.Q561
$Q562= $i.Q562
$Q563= $i.Q563
$Q564teenager= $i.Q564teenager
$Q564youngman= $i.Q564youngman
$Q565a= $i.Q565a
$Q565b= $i.Q565b
$Q566= $i.Q566
$Q567= $i.Q567
$Q568= $i.Q568
$Q568otherprev= $i.Q568otherprev.replace("'","")
$Q568other= $i.Q568other.replace("'","")
$Q569= $i.Q569
$Q570= $i.Q570
$Q570other= $i.Q570other.replace("'","")
$Q571= $i.Q571
$Q572a= $i.Q572a
$Q572b= $i.Q572b
$Q572c= $i.Q572c
$Q572d= $i.Q572d
$Q572e= $i.Q572e
$Q572f= $i.Q572f
$Q573= $i.Q573
$Q574= $i.Q574
$Q575= $i.Q575
$Q576= $i.Q576
$Q577= $i.Q577
$Q578= $i.Q578
$Q579= $i.Q579
$Q580= $i.Q580
$Q581= $i.Q581
$Q582a= $i.Q582a
$Q582b= $i.Q582b
$Q582c= $i.Q582c
$Q582d= $i.Q582d
$Q582e= $i.Q582e
$Q582f= $i.Q582f
$Q582other= $i.Q582other.replace("'","")
$Q583a= $i.Q583a
$Q583b= $i.Q583b
$Q583c= $i.Q583c
$Q583d= $i.Q583d
$Q583e= $i.Q583e
$Q583other= $i.Q583other.replace("'","")
$Q584= $i.Q584
$Q585= $i.Q585
$Q586= $i.Q586
$Q587= $i.Q587
$Q588= $i.Q588
$Q589= $i.Q589
$Q590a= $i.Q590a
$Q590b= $i.Q590b
$Q590c= $i.Q590c
$Q590d= $i.Q590d
$Q590e= $i.Q590e
$Q590f= $i.Q590f
$Q590g= $i.Q590g
$Q590h= $i.Q590h
$Q590i= $i.Q590i
$Q590otherpvn= $i.Q590otherpvn.replace("'","")
$Q590other= $i.Q590other.replace("'","")
$Q591a= $i.Q591a
$Q591b= $i.Q591b
$Q591c= $i.Q591c
$Q591d= $i.Q591d
$Q591e= $i.Q591e
$Q591f= $i.Q591f
$Q591g= $i.Q591g
$Q591other= $i.Q591other.replace("'","")
$Q592= $i.Q592
$Q593= $i.Q593
$Q594= $i.Q594
$Q595a= $i.Q595a
$Q595b= $i.Q595b
$Q595c= $i.Q595c
$Q595d= $i.Q595d
$Q595e= $i.Q595e
$Q595other= $i.Q595other.replace("'","")
$Q596a= $i.Q596a
$Q596b= $i.Q596b
$Q597= $i.Q597
$Q598= $i.Q598
$Q599= $i.Q599
$Q599otherpvn= $i.Q599otherpvn.replace("'","")
$Q599other= $i.Q599other.replace("'","")
$Q59901= $i.Q59901
$Q59902= $i.Q59902
$Q59902other= $i.Q59902other.replace("'","")
$Q59903= $i.Q59903
$Q59904a= $i.Q59904a
$Q59904b= $i.Q59904b
$Q59904c= $i.Q59904c
$Q59904d= $i.Q59904d
$Q59904e= $i.Q59904e
$Q59904f= $i.Q59904f
$Q59905= $i.Q59905
$Q59906= $i.Q59906
$Q59907= $i.Q59907
$Q59908= $i.Q59908
$Q59909= $i.Q59909
$Q59910= $i.Q59910
$Q59911= $i.Q59911
$Q59912= $i.Q59912
$Q59913= $i.Q59913
$Q59914a= $i.Q59914a
$Q59914b= $i.Q59914b
$Q59914c= $i.Q59914c
$Q59914d= $i.Q59914d
$Q59914e= $i.Q59914e
$Q59914f= $i.Q59914f
$Q59914other= $i.Q59914other.replace("'","")
$Q59915a= $i.Q59915a
$Q59915b= $i.Q59915b
$Q59915c= $i.Q59915c
$Q59915d= $i.Q59915d
$Q59915e= $i.Q59915e
$Q59915other= $i.Q59915other.replace("'","")
$Q59916= $i.Q59916
$Q59917= $i.Q59917
$Q59918= $i.Q59918
$Q59919= $i.Q59919
$Q59920= $i.Q59920
$Q59921= $i.Q59921
$Q59922a= $i.Q59922a
$Q59922b= $i.Q59922b
$Q59922c= $i.Q59922c
$Q59922d= $i.Q59922d
$Q59922e= $i.Q59922e
$Q59922f= $i.Q59922f
$Q59922g= $i.Q59922g
$Q59922h= $i.Q59922h
$Q59922i= $i.Q59922i
$Q59922j= $i.Q59922j
$Q59922k= $i.Q59922k
$Q59922otherpvn= $i.Q59922otherpvn.replace("'","")
$Q59922other= $i.Q59922other.replace("'","")
$Q59923a= $i.Q59923a
$Q59923b= $i.Q59923b
$Q59923c= $i.Q59923c
$Q59923d= $i.Q59923d
$Q59923e= $i.Q59923e
$Q59923f= $i.Q59923f
$Q59923g= $i.Q59923g
$Q59923other= $i.Q59923other.replace("'","")
$Q59924= $i.Q59924
$Q59925= $i.Q59925
$Q59926= $i.Q59926
$Q59927= $i.Q59927
$Q59928a= $i.Q59928a
$Q59928b= $i.Q59928b
$Q59928c= $i.Q59928c
$Q59928d= $i.Q59928d
$Q59928e= $i.Q59928e
$Q59928other= $i.Q59928other.replace("'","")
$Q59929a= $i.Q59929a
$Q59929b= $i.Q59929b
$Q59930= $i.Q59930
$Q59931a= $i.Q59931a
$Q59931b= $i.Q59931b
$Q59932= $i.Q59932
$Q59932other= $i.Q59932other.replace("'","")
$Q59933a= $i.Q59933a
$Q59933b= $i.Q59933b
$Q59933c= $i.Q59933c
$Q59934= $i.Q59934
$Q59935a= $i.Q59935a
$Q59935b= $i.Q59935b
$Q59935c= $i.Q59935c
$Q59935d= $i.Q59935d
$Q59935e= $i.Q59935e
$Q59935other= $i.Q59935other.replace("'","")
$Q59936= $i.Q59936
$Q59936re= $i.Q59936re
$Q59937= $i.Q59937
$Q59938a= $i.Q59938a
$Q59938b= $i.Q59938b
$Q59938c= $i.Q59938c
$Q59938d= $i.Q59938d
$Q59938e= $i.Q59938e
$Q59938f= $i.Q59938f
$Q59938g= $i.Q59938g.replace("'","")
$Q59939a= $i.Q59939a
$Q59939b= $i.Q59939b
$Q59939c= $i.Q59939c
$Q59939d= $i.Q59939d
$Q59939e= $i.Q59939e
$Q59939f= $i.Q59939f
$Q59939g= $i.Q59939g
$Q59939h= $i.Q59939h
$Q59939other= $i.Q59939other.replace("'","")
$Q59940a= $i.Q59940a
$Q59940b= $i.Q59940b
$Q59940c= $i.Q59940c
$Q59940d= $i.Q59940d.replace("'","")
$Q59940e= $i.Q59940e
$Q59940f= $i.Q59940f.replace("'","")
$Q59941a= $i.Q59941a
$Q59941b= $i.Q59941b
$Q59941c= $i.Q59941c
$Q59941d= $i.Q59941d
$Q59941other= $i.Q59941other.replace("'","")
$Q59942= $i.Q59942
$Q59942orgn= $i.Q59942orgn.replace("'","")
$Q59942other= $i.Q59942other.replace("'","")
$Q59943= $i.Q59943
$METAKEY= $i.METAKEY


$SQLQuery = "INSERT INTO hivprev_7 ( hhkey,
hhmem_key,
Q501,
Q502a,
Q502b,
Q502c,
Q502d,
Q502e,
Q502f,
Q502g,
Q502h,
Q502i,
Q502other,
Q503vmmc,
Q503othervmmc,
Q504vmmc,
Q504othervmmc,
Q503prep,
Q503otherprep,
Q504prep,
Q504otherprep,
Q503mcondom,
Q503othermcondom,
Q504mcondom,
Q504othermcondom,
Q503fcondom,
Q503otherfcondom,
Q504fcondom,
Q504otherfcondom,
Q503sp,
Q503othersp,
Q504sp,
Q504othersp,
Q503hivtc,
Q503otherhivtc,
Q504hivtc,
Q504otherhivtc,
Q505a,
Q505b,
Q505c,
Q505d,
Q505e,
Q505f,
Q505g,
Q506a,
Q506b,
Q506c,
Q506d,
Q506e,
Q506f,
Q506g,
Q507,
Q507other,
Q508vmmc,
Q508prep,
Q508mcondom,
Q508fcondom,
Q508hivtc,
Q509,
Q510,
Q511,
Q512,
Q514,
Q515a,
Q515b,
Q515c,
Q515d,
Q516,
Q516b,
Q517a,
Q517b,
Q517c,
Q517d,
Q517e,
Q518a,
Q518b,
Q518c,
Q519a,
Q519b,
Q519c,
Q519d,
Q520,
Q521,
Q522,
Q523,
Q524a,
Q524b,
Q524c,
Q524d,
Q524e,
Q524f,
Q524g,
Q524other,
Q525,
Q526,
Q527,
Q528,
Q529a,
Q529b,
Q529c,
Q529d,
Q529e,
Q529f,
Q529g,
Q529h,
Q529i,
Q529j,
Q529k,
Q529l,
Q529m,
Q529n,
Q529othermthd,
Q529other,
Q530a,
Q530b,
Q530c,
Q530d,
Q530e,
Q530f,
Q531,
Q532,
Q533,
Q534teenager,
Q534youngman,
Q535,
Q536,
Q537,
Q538,
Q539,
Q539Q545,
Q539Q545a,
Q539Q545b,
Q540,
Q541a,
Q541b,
Q541c,
Q541other,
Q542,
Q543,
Q544,
Q545,
Q545a,
Q545b,
Q546,
Q547a,
Q547b,
Q547c,
Q548a,
Q548b,
Q548c,
Q548d,
Q548e,
Q548f,
Q548g,
Q549,
Q550,
Q551,
Q552,
Q553,
Q554a,
Q554b,
Q554c,
Q554d,
Q554e,
Q554f,
Q554g,
Q554h,
Q554i,
Q554other,
Q555,
Q556,
Q557,
Q558,
Q559a,
Q559b,
Q559c,
Q559d,
Q559e,
Q559f,
Q559g,
Q559h,
Q559j,
Q559i,
Q559other,
Q560a,
Q560b,
Q560c,
Q560d,
Q560e,
Q560f,
Q560other,
Q561,
Q562,
Q563,
Q564teenager,
Q564youngman,
Q565a,
Q565b,
Q566,
Q567,
Q568,
Q568otherprev,
Q568other,
Q569,
Q570,
Q570other,
Q571,
Q572a,
Q572b,
Q572c,
Q572d,
Q572e,
Q572f,
Q573,
Q574,
Q575,
Q576,
Q577,
Q578,
Q579,
Q580,
Q581,
Q582a,
Q582b,
Q582c,
Q582d,
Q582e,
Q582f,
Q582other,
Q583a,
Q583b,
Q583c,
Q583d,
Q583e,
Q583other,
Q584,
Q585,
Q586,
Q587,
Q588,
Q589,
Q590a,
Q590b,
Q590c,
Q590d,
Q590e,
Q590f,
Q590g,
Q590h,
Q590i,
Q590otherpvn,
Q590other,
Q591a,
Q591b,
Q591c,
Q591d,
Q591e,
Q591f,
Q591g,
Q591other,
Q592,
Q593,
Q594,
Q595a,
Q595b,
Q595c,
Q595d,
Q595e,
Q595other,
Q596a,
Q596b,
Q597,
Q598,
Q599,
Q599otherpvn,
Q599other,
Q59901,
Q59902,
Q59902other,
Q59903,
Q59904a,
Q59904b,
Q59904c,
Q59904d,
Q59904e,
Q59904f,
Q59905,
Q59906,
Q59907,
Q59908,
Q59909,
Q59910,
Q59911,
Q59912,
Q59913,
Q59914a,
Q59914b,
Q59914c,
Q59914d,
Q59914e,
Q59914f,
Q59914other,
Q59915a,
Q59915b,
Q59915c,
Q59915d,
Q59915e,
Q59915other,
Q59916,
Q59917,
Q59918,
Q59919,
Q59920,
Q59921,
Q59922a,
Q59922b,
Q59922c,
Q59922d,
Q59922e,
Q59922f,
Q59922g,
Q59922h,
Q59922i,
Q59922j,
Q59922k,
Q59922otherpvn,
Q59922other,
Q59923a,
Q59923b,
Q59923c,
Q59923d,
Q59923e,
Q59923f,
Q59923g,
Q59923other,
Q59924,
Q59925,
Q59926,
Q59927,
Q59928a,
Q59928b,
Q59928c,
Q59928d,
Q59928e,
Q59928other,
Q59929a,
Q59929b,
Q59930,
Q59931a,
Q59931b,
Q59932,
Q59932other,
Q59933a,
Q59933b,
Q59933c,
Q59934,
Q59935a,
Q59935b,
Q59935c,
Q59935d,
Q59935e,
Q59935other,
Q59936,
Q59936re,
Q59937,
Q59938a,
Q59938b,
Q59938c,
Q59938d,
Q59938e,
Q59938f,
Q59938g,
Q59939a,
Q59939b,
Q59939c,
Q59939d,
Q59939e,
Q59939f,
Q59939g,
Q59939h,
Q59939other,
Q59940a,
Q59940b,
Q59940c,
Q59940d,
Q59940e,
Q59940f,
Q59941a,
Q59941b,
Q59941c,
Q59941d,
Q59941other,
Q59942,
Q59942orgn,
Q59942other,
Q59943,
METAKEY)      VALUES ('$hhkey',
'$hhmem_key',
'$Q501',
'$Q502a',
'$Q502b',
'$Q502c',
'$Q502d',
'$Q502e',
'$Q502f',
'$Q502g',
'$Q502h',
'$Q502i',
'$Q502other',
'$Q503vmmc',
'$Q503othervmmc',
'$Q504vmmc',
'$Q504othervmmc',
'$Q503prep',
'$Q503otherprep',
'$Q504prep',
'$Q504otherprep',
'$Q503mcondom',
'$Q503othermcondom',
'$Q504mcondom',
'$Q504othermcondom',
'$Q503fcondom',
'$Q503otherfcondom',
'$Q504fcondom',
'$Q504otherfcondom',
'$Q503sp',
'$Q503othersp',
'$Q504sp',
'$Q504othersp',
'$Q503hivtc',
'$Q503otherhivtc',
'$Q504hivtc',
'$Q504otherhivtc',
'$Q505a',
'$Q505b',
'$Q505c',
'$Q505d',
'$Q505e',
'$Q505f',
'$Q505g',
'$Q506a',
'$Q506b',
'$Q506c',
'$Q506d',
'$Q506e',
'$Q506f',
'$Q506g',
'$Q507',
'$Q507other',
'$Q508vmmc',
'$Q508prep',
'$Q508mcondom',
'$Q508fcondom',
'$Q508hivtc',
'$Q509',
'$Q510',
'$Q511',
'$Q512',
'$Q514',
'$Q515a',
'$Q515b',
'$Q515c',
'$Q515d',
'$Q516',
'$Q516b',
'$Q517a',
'$Q517b',
'$Q517c',
'$Q517d',
'$Q517e',
'$Q518a',
'$Q518b',
'$Q518c',
'$Q519a',
'$Q519b',
'$Q519c',
'$Q519d',
'$Q520',
'$Q521',
'$Q522',
'$Q523',
'$Q524a',
'$Q524b',
'$Q524c',
'$Q524d',
'$Q524e',
'$Q524f',
'$Q524g',
'$Q524other',
'$Q525',
'$Q526',
'$Q527',
'$Q528',
'$Q529a',
'$Q529b',
'$Q529c',
'$Q529d',
'$Q529e',
'$Q529f',
'$Q529g',
'$Q529h',
'$Q529i',
'$Q529j',
'$Q529k',
'$Q529l',
'$Q529m',
'$Q529n',
'$Q529othermthd',
'$Q529other',
'$Q530a',
'$Q530b',
'$Q530c',
'$Q530d',
'$Q530e',
'$Q530f',
'$Q531',
'$Q532',
'$Q533',
'$Q534teenager',
'$Q534youngman',
'$Q535',
'$Q536',
'$Q537',
'$Q538',
'$Q539',
'$Q539Q545',
'$Q539Q545a',
'$Q539Q545b',
'$Q540',
'$Q541a',
'$Q541b',
'$Q541c',
'$Q541other',
'$Q542',
'$Q543',
'$Q544',
'$Q545',
'$Q545a',
'$Q545b',
'$Q546',
'$Q547a',
'$Q547b',
'$Q547c',
'$Q548a',
'$Q548b',
'$Q548c',
'$Q548d',
'$Q548e',
'$Q548f',
'$Q548g',
'$Q549',
'$Q550',
'$Q551',
'$Q552',
'$Q553',
'$Q554a',
'$Q554b',
'$Q554c',
'$Q554d',
'$Q554e',
'$Q554f',
'$Q554g',
'$Q554h',
'$Q554i',
'$Q554other',
'$Q555',
'$Q556',
'$Q557',
'$Q558',
'$Q559a',
'$Q559b',
'$Q559c',
'$Q559d',
'$Q559e',
'$Q559f',
'$Q559g',
'$Q559h',
'$Q559j',
'$Q559i',
'$Q559other',
'$Q560a',
'$Q560b',
'$Q560c',
'$Q560d',
'$Q560e',
'$Q560f',
'$Q560other',
'$Q561',
'$Q562',
'$Q563',
'$Q564teenager',
'$Q564youngman',
'$Q565a',
'$Q565b',
'$Q566',
'$Q567',
'$Q568',
'$Q568otherprev',
'$Q568other',
'$Q569',
'$Q570',
'$Q570other',
'$Q571',
'$Q572a',
'$Q572b',
'$Q572c',
'$Q572d',
'$Q572e',
'$Q572f',
'$Q573',
'$Q574',
'$Q575',
'$Q576',
'$Q577',
'$Q578',
'$Q579',
'$Q580',
'$Q581',
'$Q582a',
'$Q582b',
'$Q582c',
'$Q582d',
'$Q582e',
'$Q582f',
'$Q582other',
'$Q583a',
'$Q583b',
'$Q583c',
'$Q583d',
'$Q583e',
'$Q583other',
'$Q584',
'$Q585',
'$Q586',
'$Q587',
'$Q588',
'$Q589',
'$Q590a',
'$Q590b',
'$Q590c',
'$Q590d',
'$Q590e',
'$Q590f',
'$Q590g',
'$Q590h',
'$Q590i',
'$Q590otherpvn',
'$Q590other',
'$Q591a',
'$Q591b',
'$Q591c',
'$Q591d',
'$Q591e',
'$Q591f',
'$Q591g',
'$Q591other',
'$Q592',
'$Q593',
'$Q594',
'$Q595a',
'$Q595b',
'$Q595c',
'$Q595d',
'$Q595e',
'$Q595other',
'$Q596a',
'$Q596b',
'$Q597',
'$Q598',
'$Q599',
'$Q599otherpvn',
'$Q599other',
'$Q59901',
'$Q59902',
'$Q59902other',
'$Q59903',
'$Q59904a',
'$Q59904b',
'$Q59904c',
'$Q59904d',
'$Q59904e',
'$Q59904f',
'$Q59905',
'$Q59906',
'$Q59907',
'$Q59908',
'$Q59909',
'$Q59910',
'$Q59911',
'$Q59912',
'$Q59913',
'$Q59914a',
'$Q59914b',
'$Q59914c',
'$Q59914d',
'$Q59914e',
'$Q59914f',
'$Q59914other',
'$Q59915a',
'$Q59915b',
'$Q59915c',
'$Q59915d',
'$Q59915e',
'$Q59915other',
'$Q59916',
'$Q59917',
'$Q59918',
'$Q59919',
'$Q59920',
'$Q59921',
'$Q59922a',
'$Q59922b',
'$Q59922c',
'$Q59922d',
'$Q59922e',
'$Q59922f',
'$Q59922g',
'$Q59922h',
'$Q59922i',
'$Q59922j',
'$Q59922k',
'$Q59922otherpvn',
'$Q59922other',
'$Q59923a',
'$Q59923b',
'$Q59923c',
'$Q59923d',
'$Q59923e',
'$Q59923f',
'$Q59923g',
'$Q59923other',
'$Q59924',
'$Q59925',
'$Q59926',
'$Q59927',
'$Q59928a',
'$Q59928b',
'$Q59928c',
'$Q59928d',
'$Q59928e',
'$Q59928other',
'$Q59929a',
'$Q59929b',
'$Q59930',
'$Q59931a',
'$Q59931b',
'$Q59932',
'$Q59932other',
'$Q59933a',
'$Q59933b',
'$Q59933c',
'$Q59934',
'$Q59935a',
'$Q59935b',
'$Q59935c',
'$Q59935d',
'$Q59935e',
'$Q59935other',
'$Q59936',
'$Q59936re',
'$Q59937',
'$Q59938a',
'$Q59938b',
'$Q59938c',
'$Q59938d',
'$Q59938e',
'$Q59938f',
'$Q59938g',
'$Q59939a',
'$Q59939b',
'$Q59939c',
'$Q59939d',
'$Q59939e',
'$Q59939f',
'$Q59939g',
'$Q59939h',
'$Q59939other',
'$Q59940a',
'$Q59940b',
'$Q59940c',
'$Q59940d',
'$Q59940e',
'$Q59940f',
'$Q59941a',
'$Q59941b',
'$Q59941c',
'$Q59941d',
'$Q59941other',
'$Q59942',
'$Q59942orgn',
'$Q59942other',
'$Q59943',
'$METAKEY')"

 
       
       # Cloud Database Settings
        $impcsv = invoke-sqlcmd -Username $CloudDatabaseUser -Password $CloudDatabasePWD -Database $CloudDatabaseName -Query $SQLQuery  -serverinstance $CloudSQLServerInstance  
        $InfoMessage = "Household memID $hhmem_key successfully uploaded to Cloud YZ-UHP database on SmarterASP."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 


 $InfoMessage = "Successfully imported $count HIVPREV Qstns into the YZ-UHP CLOUD database" 
 Write-Log -Message $InfoMessage -Path $LogFile   -Level Info

 

$InfoMessage = "Qstns Data upload completed"
}



Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    
    Write-Log -Message "Error : Upload to Cloud database failed with the error : $ErrorMessage" -Path $LogFile -Level Error
}









