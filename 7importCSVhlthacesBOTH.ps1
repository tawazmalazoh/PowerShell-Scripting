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
$FormattedCSVFile = 'C:\DATA\Briefcase\Formatted\hlthaces_7.csv'
$RawBackupFolder = 'C:\DATA\Briefcase\Backup\Raw\ivq\'
$FormattedBackupFolder = 'C:\DATA\Briefcase\Backup\Formatted\ivq\'
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
$DatabaseTable = 'hlthaces_7'


# Lets create a Log file to log the events that will be happening today. Generate log file with current date.
$date = Get-Date -UFormat "%Y%m%d"
$LogFile = $LogFileFolder+'log-'+$date+'-hlthaces_7.log'



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
      @{Name="Q701a";Expression={$_."consented-Q701-Q701a"}},
      @{Name="Q701b";Expression={$_."consented-Q701-Q701b"}},
      @{Name="Q701c";Expression={$_."consented-Q701-Q701c"}},
      @{Name="Q701d";Expression={$_."consented-Q701-Q701d"}},
      @{Name="Q701e";Expression={$_."consented-Q701-Q701e"}},
      @{Name="Q701f";Expression={$_."consented-Q701-Q701f"}},
      @{Name="Q701g";Expression={$_."consented-Q701-Q701g"}},
      @{Name="Q701h";Expression={$_."consented-Q701-Q701h"}},
      @{Name="Q701i";Expression={$_."consented-Q701-Q701i"}},
      @{Name="Q701j";Expression={$_."consented-Q701-Q701j"}},
      @{Name="Q701k";Expression={$_."consented-Q701-Q701k"}},
      @{Name="Q701l";Expression={$_."consented-Q701-Q701l"}},
      @{Name="Q701m";Expression={$_."consented-Q701-Q701m"}},
      @{Name="Q701n";Expression={$_."consented-Q701-Q701n"}},
      @{Name="Q701p";Expression={$_."consented-Q701-Q701p"}},
      @{Name="Q701q";Expression={$_."consented-Q701-Q701q"}},
      @{Name="Q701o";Expression={$_."consented-Q701-Q701o"}},
      @{Name="Q702a";Expression={$_."consented-Q702-Q702a"}},
      @{Name="Q702b";Expression={$_."consented-Q702-Q702b"}},
      @{Name="Q702c";Expression={$_."consented-Q702-Q702c"}},
      @{Name="Q702d";Expression={$_."consented-Q702-Q702d"}},
      @{Name="Q702e";Expression={$_."consented-Q702-Q702e"}},
      @{Name="Q702f";Expression={$_."consented-Q702-Q702f"}},
      @{Name="Q702g";Expression={$_."consented-Q702-Q702g"}},
      @{Name="Q702h";Expression={$_."consented-Q702-Q702h"}},
      @{Name="Q702i";Expression={$_."consented-Q702-Q702i"}},
      @{Name="Q702j";Expression={$_."consented-Q702-Q702j"}},
      @{Name="Q702k";Expression={$_."consented-Q702-Q702k"}},
      @{Name="Q702l";Expression={$_."consented-Q702-Q702l"}},
      @{Name="Q702m";Expression={$_."consented-Q702-Q702m"}},
      @{Name="Q702n";Expression={$_."consented-Q702-Q702n"}},
      @{Name="Q702o";Expression={$_."consented-Q702-Q703o"}},
      @{Name="Q702p";Expression={$_."consented-Q702-Q702p"}},
      @{Name="Q702q";Expression={$_."consented-Q702-Q702q"}},
      @{Name="Q703a";Expression={$_."consented-Q703-Q703a"}},
      @{Name="Q703b";Expression={$_."consented-Q703-Q703b"}},
      @{Name="Q703c";Expression={$_."consented-Q703-Q703c"}},
      @{Name="Q703d";Expression={$_."consented-Q703-Q703d"}},
      @{Name="Q703e";Expression={$_."consented-Q703-Q703e"}},
      @{Name="Q703f";Expression={$_."consented-Q703-Q703f"}},
      @{Name="Q703g";Expression={$_."consented-Q703-Q703g"}},
      @{Name="Q703h";Expression={$_."consented-Q703-Q703h"}},
      @{Name="Q703i";Expression={$_."consented-Q703-Q703i"}},
      @{Name="Q703j";Expression={$_."consented-Q703-Q703j"}},
      @{Name="Q703k";Expression={$_."consented-Q703-Q703k"}},
      @{Name="Q703l";Expression={$_."consented-Q703-Q703l"}},
      @{Name="Q703m";Expression={$_."consented-Q703-Q703m"}},
      @{Name="Q703n";Expression={$_."consented-Q703-Q703n"}},
      @{Name="Q703o";Expression={$_."consented-Q703-Q703o"}},
      @{Name="Q703p";Expression={$_."consented-Q703-Q703p"}},
      @{Name="Q703q";Expression={$_."consented-Q703-Q703q"}},
      @{Name="Q704a";Expression={$_."consented-Q704-Q704a"}},
      @{Name="Q704b";Expression={$_."consented-Q704-Q704b"}},
      @{Name="Q704c";Expression={$_."consented-Q704-Q704c"}},
      @{Name="Q704d";Expression={$_."consented-Q704-Q704d"}},
      @{Name="Q704e";Expression={$_."consented-Q704-Q704e"}},
      @{Name="Q704f";Expression={$_."consented-Q704-Q704f"}},
      @{Name="Q704g";Expression={$_."consented-Q704-Q704g"}},
      @{Name="Q704h";Expression={$_."consented-Q704-Q704h"}},
      @{Name="Q704i";Expression={$_."consented-Q704-Q704i"}},
      @{Name="Q704j";Expression={$_."consented-Q704-Q704j"}},
      @{Name="Q704k";Expression={$_."consented-Q704-Q704k"}},
      @{Name="Q704l";Expression={$_."consented-Q704-Q704l"}},
      @{Name="Q704m";Expression={$_."consented-Q704-Q704m"}},
      @{Name="Q704n";Expression={$_."consented-Q704-Q704n"}},
      @{Name="Q704o";Expression={$_."consented-Q704-Q704o"}},
      @{Name="Q704p";Expression={$_."consented-Q704-Q704p"}},
      @{Name="Q704q";Expression={$_."consented-Q704-Q704q"}},
      @{Name="Q705a";Expression={$_."consented-Q705-Q705a"}},
      @{Name="Q705b";Expression={$_."consented-Q705-Q705b"}},
      @{Name="Q705c";Expression={$_."consented-Q705-Q705c"}},
      @{Name="Q706";Expression={$_."consented-Q706"}},
      @{Name="Q706other";Expression={$_."consented-Q706other"}},
      @{Name="Q707a";Expression={$_."consented-Q707-Q707a"}},
      @{Name="Q707b";Expression={$_."consented-Q707-Q707b"}},
      @{Name="Q707c";Expression={$_."consented-Q707-Q707c"}},
      @{Name="Q708";Expression={$_."consented-Q708"}},
      @{Name="Q708other";Expression={$_."consented-Q708other"}},
      @{Name="Q709a";Expression={$_."consented-assisted-Q709-Q709a"}},
      @{Name="Q709b";Expression={$_."consented-assisted-Q709-Q709b"}},
      @{Name="Q709c";Expression={$_."consented-assisted-Q709-Q709c"}},
      @{Name="Q709other";Expression={$_."consented-assisted-Q709-Q709other"}},
      @{Name="Q710a";Expression={$_."consented-assisted-Q710-Q710a"}},
      @{Name="Q710b";Expression={$_."consented-assisted-Q710-Q710b"}},
      @{Name="Q710c";Expression={$_."consented-assisted-Q710-Q710c"}},
      @{Name="Q710d";Expression={$_."consented-assisted-Q710-Q710d"}},
      @{Name="Q710e";Expression={$_."consented-assisted-Q710-Q710e"}},
      @{Name="Q710f";Expression={$_."consented-assisted-Q710-Q710f"}},
      @{Name="Q710g";Expression={$_."consented-assisted-Q710-Q710g"}},
      @{Name="Q711";Expression={$_."consented-assisted-Q711"}},
      @{Name="Q712";Expression={$_."consented-assisted-Q712"}},
      @{Name="Q713";Expression={$_."consented-assisted-Q713"}},
      @{Name="Q714men";Expression={$_."consented-Q714men"}},
      @{Name="Q714women";Expression={$_."consented-Q714women"}},
      @{Name="Q715";Expression={$_."consented-Q715"}},
      @{Name="Q716a";Expression={$_."consented-Q716-Q716a"}},
      @{Name="Q716b";Expression={$_."consented-Q716-Q716b"}},
      @{Name="Q716c";Expression={$_."consented-Q716-Q716c"}},
      @{Name="Q716d";Expression={$_."consented-Q716-Q716d"}},
      @{Name="Q716e";Expression={$_."consented-Q716-Q716e"}},
      @{Name="Q716f";Expression={$_."consented-Q716-Q716f"}},
      @{Name="Q717a";Expression={$_."consented-Q717-Q717a"}},
      @{Name="Q717b";Expression={$_."consented-Q717-Q717b"}},
      @{Name="Q718a";Expression={$_."consented-hivtest-Q718-Q718a"}},
      @{Name="Q718b";Expression={$_."consented-hivtest-Q718-Q718b"}},
      @{Name="Q719";Expression={$_."consented-hivtest-Q719"}},
      @{Name="Q720";Expression={$_."consented-hivtest-Q720"}},
      @{Name="Q721ca";Expression={$_."consented-hivtest-Q721cnsl-Q721ca"}},
      @{Name="Q721cb";Expression={$_."consented-hivtest-Q721cnsl-Q721cb"}},
      @{Name="Q721cc";Expression={$_."consented-hivtest-Q721cnsl-Q721cc"}},
      @{Name="Q721cd";Expression={$_."consented-hivtest-Q721cnsl-Q721cd"}},
      @{Name="Q721ce";Expression={$_."consented-hivtest-Q721cnsl-Q721ce"}},
      @{Name="Q721cf";Expression={$_."consented-hivtest-Q721cnsl-Q721cf"}},
      @{Name="Q721cg";Expression={$_."consented-hivtest-Q721cnsl-Q721cg"}},
      @{Name="Q721ra";Expression={$_."consented-hivtest-Q721ref-Q721ra"}},
      @{Name="Q721rb";Expression={$_."consented-hivtest-Q721ref-Q721rb"}},
      @{Name="Q721rc";Expression={$_."consented-hivtest-Q721ref-Q721rc"}},
      @{Name="Q721rd";Expression={$_."consented-hivtest-Q721ref-Q721rd"}},
      @{Name="Q721re";Expression={$_."consented-hivtest-Q721ref-Q721re"}},
      @{Name="Q721rf";Expression={$_."consented-hivtest-Q721ref-Q721rf"}},
      @{Name="Q721rg";Expression={$_."consented-hivtest-Q721ref-Q721rg"}},
      @{Name="Q722";Expression={$_."consented-hivtest-Q722"}},
      @{Name="Q723a";Expression={$_."consented-hivtest-Q723-Q723a"}},
      @{Name="Q723b";Expression={$_."consented-hivtest-Q723-Q723b"}},
      @{Name="Q724a";Expression={$_."consented-hivtest-Q724-Q724a"}},
      @{Name="Q724b";Expression={$_."consented-hivtest-Q724-Q724b"}},
      @{Name="Q725a";Expression={$_."consented-resneg-Q725-Q725a"}},
      @{Name="Q725b";Expression={$_."consented-resneg-Q725-Q725b"}},
      @{Name="Q725c";Expression={$_."consented-resneg-Q725-Q725c"}},
      @{Name="Q725d";Expression={$_."consented-resneg-Q725-Q725d"}},
      @{Name="Q725e";Expression={$_."consented-resneg-Q725-Q725e"}},
      @{Name="Q726";Expression={$_."consented-resneg-Q726"}},
      @{Name="Q727";Expression={$_."consented-resneg-Q727"}},
      @{Name="Q728";Expression={$_."consented-resneg-Q728"}},
      @{Name="Q729";Expression={$_."consented-resneg-Q729"}},
      @{Name="Q730";Expression={$_."consented-resneg-Q730"}},
      @{Name="Q731a";Expression={$_."consented-resneg-Q731-Q731a"}},
      @{Name="Q731b";Expression={$_."consented-resneg-Q731-Q731b"}},
      @{Name="Q731c";Expression={$_."consented-resneg-Q731-Q731c"}},
      @{Name="Q731d";Expression={$_."consented-resneg-Q731-Q731d"}},
      @{Name="Q731e";Expression={$_."consented-resneg-Q731-Q731e"}},
      @{Name="Q731f";Expression={$_."consented-resneg-Q731-Q731f"}},
      @{Name="Q731other";Expression={$_."consented-resneg-Q731-Q731other"}},
      @{Name="Q732";Expression={$_."consented-resneg-Q732"}},
      @{Name="Q733";Expression={$_."consented-resneg-Q733"}},
      @{Name="Q734";Expression={$_."consented-resneg-Q734"}},
      @{Name="Q735";Expression={$_."consented-resneg-Q735"}},
      @{Name="Q736";Expression={$_."consented-Q736"}},
      @{Name="Q737a";Expression={$_."consented-Q737-Q737a"}},
      @{Name="Q737b";Expression={$_."consented-Q737-Q737b"}},
      @{Name="Q737c";Expression={$_."consented-Q737-Q737c"}},
      @{Name="Q737d";Expression={$_."consented-Q737-Q737d"}},
      @{Name="Q737e";Expression={$_."consented-Q737-Q737e"}},
      @{Name="Q737f";Expression={$_."consented-Q737-Q737f"}},
      @{Name="Q737g";Expression={$_."consented-Q737-Q737g"}},
      @{Name="Q737h";Expression={$_."consented-Q737-Q737h"}},
      @{Name="Q737i";Expression={$_."consented-Q737-Q737i"}},
      @{Name="Q737j";Expression={$_."consented-Q737-Q737j"}},
      @{Name="Q737k";Expression={$_."consented-Q737-Q737k"}},
      @{Name="Q737l";Expression={$_."consented-Q737-Q737l"}},
      @{Name="Q737m";Expression={$_."consented-Q737-Q737m"}},
      @{Name="Q737n";Expression={$_."consented-Q737-Q737n"}},
      @{Name="Q737o";Expression={$_."consented-Q737-Q737o"}},
      @{Name="Q737other";Expression={$_."consented-Q737-Q737other"}},
      @{Name="Q738a";Expression={$_."consented-Q738-Q738a"}},
      @{Name="Q738b";Expression={$_."consented-Q738-Q738b"}},
      @{Name="Q738c";Expression={$_."consented-Q738-Q738c"}},
      @{Name="Q738d";Expression={$_."consented-Q738-Q738d"}},
      @{Name="Q738e";Expression={$_."consented-Q738-Q738e"}},
      @{Name="Q738f";Expression={$_."consented-Q738-Q738f"}},
      @{Name="Q738g";Expression={$_."consented-Q738-Q738g"}},
      @{Name="Q738h";Expression={$_."consented-Q738-Q738h"}},
      @{Name="Q738i";Expression={$_."consented-Q738-Q738i"}},
      @{Name="Q738j";Expression={$_."consented-Q738-Q738j"}},
      @{Name="Q739a";Expression={$_."consented-Q739-Q739a"}},
      @{Name="Q739b";Expression={$_."consented-Q739-Q739b"}},
      @{Name="Q740a";Expression={$_."consented-hivtestslong-Q740a"}},
      @{Name="Q740b";Expression={$_."consented-hivtestslong-Q740b"}},
      @{Name="Q740c";Expression={$_."consented-hivtestslong-Q740c"}},
      @{Name="Q741";Expression={$_."consented-selftest-Q741"}},
      @{Name="Q742";Expression={$_."consented-selftest-Q742"}},
      @{Name="Q743";Expression={$_."consented-Q743"}},
      @{Name="Q744";Expression={$_."consented-Q744"}},
      @{Name="Q745";Expression={$_."consented-arv-Q745"}},
      @{Name="Q746";Expression={$_."consented-arv-knowplace-Q746gp-Q746"}},
      @{Name="Q746a";Expression={$_."consented-arv-knowplace-Q746gp-Q746a"}},
      @{Name="Q747";Expression={$_."consented-arv-knowplace-Q747"}},
      @{Name="Q748";Expression={$_."consented-Q748"}},
      @{Name="Q749";Expression={$_."consented-Q749"}},
      @{Name="Q749other";Expression={$_."consented-Q749other"}},
      @{Name="Q750a";Expression={$_."consented-takeart-Q750-Q750a"}},
      @{Name="Q750b";Expression={$_."consented-takeart-Q750-Q750b"}},
      @{Name="Q751";Expression={$_."consented-takeart-Q751"}},
      @{Name="Q751other";Expression={$_."consented-takeart-Q751other"}},
      @{Name="Q752";Expression={$_."consented-takeart-Q752"}},
      @{Name="Q753";Expression={$_."consented-takeart-Q753"}},
      @{Name="Q753other";Expression={$_."consented-takeart-Q753other"}},
      @{Name="Q754";Expression={$_."consented-takeart-Q754"}},
      @{Name="Q754other";Expression={$_."consented-takeart-Q754other"}},
      @{Name="Q755";Expression={$_."consented-takeart-Q755"}},
      @{Name="Q756";Expression={$_."consented-takeart-Q756"}},
      @{Name="Q757a";Expression={$_."consented-takeart-Q757-Q757a"}},
      @{Name="Q757b";Expression={$_."consented-takeart-Q757-Q757b"}},
      @{Name="Q758";Expression={$_."consented-takeart-Q758"}},
      @{Name="Q759";Expression={$_."consented-takeart-Q759"}},
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
$Q701a= $i.Q701a
$Q701b= $i.Q701b
$Q701c= $i.Q701c
$Q701d= $i.Q701d
$Q701e= $i.Q701e
$Q701f= $i.Q701f
$Q701g= $i.Q701g
$Q701h= $i.Q701h
$Q701i= $i.Q701i
$Q701j= $i.Q701j
$Q701k= $i.Q701k
$Q701l= $i.Q701l
$Q701m= $i.Q701m
$Q701n= $i.Q701n
$Q701p= $i.Q701p
$Q701q= $i.Q701q
$Q701o= $i.Q701o
$Q702a= $i.Q702a
$Q702b= $i.Q702b
$Q702c= $i.Q702c
$Q702d= $i.Q702d
$Q702e= $i.Q702e
$Q702f= $i.Q702f
$Q702g= $i.Q702g
$Q702h= $i.Q702h
$Q702i= $i.Q702i
$Q702j= $i.Q702j
$Q702k= $i.Q702k
$Q702l= $i.Q702l
$Q702m= $i.Q702m
$Q702n= $i.Q702n
$Q702o= $i.Q702o
$Q702p= $i.Q702p
$Q702q= $i.Q702q
$Q703a= $i.Q703a
$Q703b= $i.Q703b
$Q703c= $i.Q703c
$Q703d= $i.Q703d
$Q703e= $i.Q703e
$Q703f= $i.Q703f
$Q703g= $i.Q703g
$Q703h= $i.Q703h
$Q703i= $i.Q703i
$Q703j= $i.Q703j
$Q703k= $i.Q703k
$Q703l= $i.Q703l
$Q703m= $i.Q703m
$Q703n= $i.Q703n
$Q703o= $i.Q703o
$Q703p= $i.Q703p
$Q703q= $i.Q703q
$Q704a= $i.Q704a
$Q704b= $i.Q704b
$Q704c= $i.Q704c
$Q704d= $i.Q704d
$Q704e= $i.Q704e
$Q704f= $i.Q704f
$Q704g= $i.Q704g
$Q704h= $i.Q704h
$Q704i= $i.Q704i
$Q704j= $i.Q704j
$Q704k= $i.Q704k
$Q704l= $i.Q704l
$Q704m= $i.Q704m
$Q704n= $i.Q704n
$Q704o= $i.Q704o
$Q704p= $i.Q704p
$Q704q= $i.Q704q
$Q705a= $i.Q705a
$Q705b= $i.Q705b
$Q705c= $i.Q705c
$Q706= $i.Q706
$Q706other= $i.Q706other.replace("'","")
$Q707a= $i.Q707a
$Q707b= $i.Q707b
$Q707c= $i.Q707c
$Q708= $i.Q708
$Q708other= $i.Q708other.replace("'","")
$Q709a= $i.Q709a
$Q709b= $i.Q709b
$Q709c= $i.Q709c
$Q709other= $i.Q709other.replace("'","")
$Q710a= $i.Q710a
$Q710b= $i.Q710b
$Q710c= $i.Q710c
$Q710d= $i.Q710d
$Q710e= $i.Q710e
$Q710f= $i.Q710f
$Q710g= $i.Q710g.replace("'","")
$Q711= $i.Q711
$Q712= $i.Q712
$Q713= $i.Q713
$Q714men= $i.Q714men
$Q714women= $i.Q714women
$Q715= $i.Q715
$Q716a= $i.Q716a
$Q716b= $i.Q716b
$Q716c= $i.Q716c
$Q716d= $i.Q716d
$Q716e= $i.Q716e
$Q716f= $i.Q716f
$Q717a= $i.Q717a
$Q717b= $i.Q717b
$Q718a= $i.Q718a
$Q718b= $i.Q718b
$Q719= $i.Q719
$Q720= $i.Q720
$Q721ca= $i.Q721ca
$Q721cb= $i.Q721cb
$Q721cc= $i.Q721cc
$Q721cd= $i.Q721cd
$Q721ce= $i.Q721ce
$Q721cf= $i.Q721cf
$Q721cg= $i.Q721cg
$Q721ra= $i.Q721ra
$Q721rb= $i.Q721rb
$Q721rc= $i.Q721rc
$Q721rd= $i.Q721rd
$Q721re= $i.Q721re
$Q721rf= $i.Q721rf
$Q721rg= $i.Q721rg
$Q722= $i.Q722
$Q723a= $i.Q723a
$Q723b= $i.Q723b
$Q724a= $i.Q724a
$Q724b= $i.Q724b
$Q725a= $i.Q725a
$Q725b= $i.Q725b
$Q725c= $i.Q725c
$Q725d= $i.Q725d
$Q725e= $i.Q725e
$Q726= $i.Q726
$Q727= $i.Q727
$Q728= $i.Q728
$Q729= $i.Q729
$Q730= $i.Q730
$Q731a= $i.Q731a
$Q731b= $i.Q731b
$Q731c= $i.Q731c
$Q731d= $i.Q731d
$Q731e= $i.Q731e
$Q731f= $i.Q731f
$Q731other= $i.Q731other.replace("'","")
$Q732= $i.Q732
$Q733= $i.Q733
$Q734= $i.Q734
$Q735= $i.Q735
$Q736= $i.Q736
$Q737a= $i.Q737a
$Q737b= $i.Q737b
$Q737c= $i.Q737c
$Q737d= $i.Q737d
$Q737e= $i.Q737e
$Q737f= $i.Q737f
$Q737g= $i.Q737g
$Q737h= $i.Q737h
$Q737i= $i.Q737i
$Q737j= $i.Q737j
$Q737k= $i.Q737k
$Q737l= $i.Q737l
$Q737m= $i.Q737m
$Q737n= $i.Q737n
$Q737o= $i.Q737o
$Q737other= $i.Q737other.replace("'","")
$Q738a= $i.Q738a
$Q738b= $i.Q738b
$Q738c= $i.Q738c
$Q738d= $i.Q738d
$Q738e= $i.Q738e
$Q738f= $i.Q738f
$Q738g= $i.Q738g
$Q738h= $i.Q738h
$Q738i= $i.Q738i
$Q738j= $i.Q738j.replace("'","")
$Q739a= $i.Q739a
$Q739b= $i.Q739b
$Q740a= $i.Q740a
$Q740b= $i.Q740b
$Q740c= $i.Q740c
$Q741= $i.Q741
$Q742= $i.Q742
$Q743= $i.Q743
$Q744= $i.Q744
$Q745= $i.Q745
$Q746= $i.Q746
$Q746a= $i.Q746a.replace("'","")
$Q747= $i.Q747
$Q748= $i.Q748
$Q749= $i.Q749
$Q749other= $i.Q749other.replace("'","")
$Q750a= $i.Q750a
$Q750b= $i.Q750b
$Q751= $i.Q751
$Q751other= $i.Q751other.replace("'","")
$Q752= $i.Q752
$Q753= $i.Q753
$Q753other= $i.Q753other.replace("'","")
$Q754= $i.Q754
$Q754other= $i.Q754other.replace("'","")
$Q755= $i.Q755
$Q756= $i.Q756
$Q757a= $i.Q757a
$Q757b= $i.Q757b
$Q758= $i.Q758
$Q759= $i.Q759
$METAKEY= $i.METAKEY

$SQLQuery = "INSERT INTO hlthaces_7 (hhkey,
hhmem_key,
Q701a,
Q701b,
Q701c,
Q701d,
Q701e,
Q701f,
Q701g,
Q701h,
Q701i,
Q701j,
Q701k,
Q701l,
Q701m,
Q701n,
Q701p,
Q701q,
Q701o,
Q702a,
Q702b,
Q702c,
Q702d,
Q702e,
Q702f,
Q702g,
Q702h,
Q702i,
Q702j,
Q702k,
Q702l,
Q702m,
Q702n,
Q702o,
Q702p,
Q702q,
Q703a,
Q703b,
Q703c,
Q703d,
Q703e,
Q703f,
Q703g,
Q703h,
Q703i,
Q703j,
Q703k,
Q703l,
Q703m,
Q703n,
Q703o,
Q703p,
Q703q,
Q704a,
Q704b,
Q704c,
Q704d,
Q704e,
Q704f,
Q704g,
Q704h,
Q704i,
Q704j,
Q704k,
Q704l,
Q704m,
Q704n,
Q704o,
Q704p,
Q704q,
Q705a,
Q705b,
Q705c,
Q706,
Q706other,
Q707a,
Q707b,
Q707c,
Q708,
Q708other,
Q709a,
Q709b,
Q709c,
Q709other,
Q710a,
Q710b,
Q710c,
Q710d,
Q710e,
Q710f,
Q710g,
Q711,
Q712,
Q713,
Q714men,
Q714women,
Q715,
Q716a,
Q716b,
Q716c,
Q716d,
Q716e,
Q716f,
Q717a,
Q717b,
Q718a,
Q718b,
Q719,
Q720,
Q721ca,
Q721cb,
Q721cc,
Q721cd,
Q721ce,
Q721cf,
Q721cg,
Q721ra,
Q721rb,
Q721rc,
Q721rd,
Q721re,
Q721rf,
Q721rg,
Q722,
Q723a,
Q723b,
Q724a,
Q724b,
Q725a,
Q725b,
Q725c,
Q725d,
Q725e,
Q726,
Q727,
Q728,
Q729,
Q730,
Q731a,
Q731b,
Q731c,
Q731d,
Q731e,
Q731f,
Q731other,
Q732,
Q733,
Q734,
Q735,
Q736,
Q737a,
Q737b,
Q737c,
Q737d,
Q737e,
Q737f,
Q737g,
Q737h,
Q737i,
Q737j,
Q737k,
Q737l,
Q737m,
Q737n,
Q737o,
Q737other,
Q738a,
Q738b,
Q738c,
Q738d,
Q738e,
Q738f,
Q738g,
Q738h,
Q738i,
Q738j,
Q739a,
Q739b,
Q740a,
Q740b,
Q740c,
Q741,
Q742,
Q743,
Q744,
Q745,
Q746,
Q746a,
Q747,
Q748,
Q749,
Q749other,
Q750a,
Q750b,
Q751,
Q751other,
Q752,
Q753,
Q753other,
Q754,
Q754other,
Q755,
Q756,
Q757a,
Q757b,
Q758,
Q759,
METAKEY)     VALUES ('$hhkey',
'$hhmem_key',
'$Q701a',
'$Q701b',
'$Q701c',
'$Q701d',
'$Q701e',
'$Q701f',
'$Q701g',
'$Q701h',
'$Q701i',
'$Q701j',
'$Q701k',
'$Q701l',
'$Q701m',
'$Q701n',
'$Q701p',
'$Q701q',
'$Q701o',
'$Q702a',
'$Q702b',
'$Q702c',
'$Q702d',
'$Q702e',
'$Q702f',
'$Q702g',
'$Q702h',
'$Q702i',
'$Q702j',
'$Q702k',
'$Q702l',
'$Q702m',
'$Q702n',
'$Q702o',
'$Q702p',
'$Q702q',
'$Q703a',
'$Q703b',
'$Q703c',
'$Q703d',
'$Q703e',
'$Q703f',
'$Q703g',
'$Q703h',
'$Q703i',
'$Q703j',
'$Q703k',
'$Q703l',
'$Q703m',
'$Q703n',
'$Q703o',
'$Q703p',
'$Q703q',
'$Q704a',
'$Q704b',
'$Q704c',
'$Q704d',
'$Q704e',
'$Q704f',
'$Q704g',
'$Q704h',
'$Q704i',
'$Q704j',
'$Q704k',
'$Q704l',
'$Q704m',
'$Q704n',
'$Q704o',
'$Q704p',
'$Q704q',
'$Q705a',
'$Q705b',
'$Q705c',
'$Q706',
'$Q706other',
'$Q707a',
'$Q707b',
'$Q707c',
'$Q708',
'$Q708other',
'$Q709a',
'$Q709b',
'$Q709c',
'$Q709other',
'$Q710a',
'$Q710b',
'$Q710c',
'$Q710d',
'$Q710e',
'$Q710f',
'$Q710g',
'$Q711',
'$Q712',
'$Q713',
'$Q714men',
'$Q714women',
'$Q715',
'$Q716a',
'$Q716b',
'$Q716c',
'$Q716d',
'$Q716e',
'$Q716f',
'$Q717a',
'$Q717b',
'$Q718a',
'$Q718b',
'$Q719',
'$Q720',
'$Q721ca',
'$Q721cb',
'$Q721cc',
'$Q721cd',
'$Q721ce',
'$Q721cf',
'$Q721cg',
'$Q721ra',
'$Q721rb',
'$Q721rc',
'$Q721rd',
'$Q721re',
'$Q721rf',
'$Q721rg',
'$Q722',
'$Q723a',
'$Q723b',
'$Q724a',
'$Q724b',
'$Q725a',
'$Q725b',
'$Q725c',
'$Q725d',
'$Q725e',
'$Q726',
'$Q727',
'$Q728',
'$Q729',
'$Q730',
'$Q731a',
'$Q731b',
'$Q731c',
'$Q731d',
'$Q731e',
'$Q731f',
'$Q731other',
'$Q732',
'$Q733',
'$Q734',
'$Q735',
'$Q736',
'$Q737a',
'$Q737b',
'$Q737c',
'$Q737d',
'$Q737e',
'$Q737f',
'$Q737g',
'$Q737h',
'$Q737i',
'$Q737j',
'$Q737k',
'$Q737l',
'$Q737m',
'$Q737n',
'$Q737o',
'$Q737other',
'$Q738a',
'$Q738b',
'$Q738c',
'$Q738d',
'$Q738e',
'$Q738f',
'$Q738g',
'$Q738h',
'$Q738i',
'$Q738j',
'$Q739a',
'$Q739b',
'$Q740a',
'$Q740b',
'$Q740c',
'$Q741',
'$Q742',
'$Q743',
'$Q744',
'$Q745',
'$Q746',
'$Q746a',
'$Q747',
'$Q748',
'$Q749',
'$Q749other',
'$Q750a',
'$Q750b',
'$Q751',
'$Q751other',
'$Q752',
'$Q753',
'$Q753other',
'$Q754',
'$Q754other',
'$Q755',
'$Q756',
'$Q757a',
'$Q757b',
'$Q758',
'$Q759',
'$METAKEY')"



 $impcsv = invoke-sqlcmd -Username $LocalDatabaseUser -Password $LocalDatabasePWD -Database $LocalDatabaseName -Query $SQLQuery  -serverinstance $LocalSQLServerInstance  
        $InfoMessage = "Household memID $hhmem_key successfully uploaded to YZ-UHP Local MSSSQL Server."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 
 $InfoMessage = "Successfully imported $count HIVACESS  Qstns into the YZ-UHP database" 
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
$Q701a= $i.Q701a
$Q701b= $i.Q701b
$Q701c= $i.Q701c
$Q701d= $i.Q701d
$Q701e= $i.Q701e
$Q701f= $i.Q701f
$Q701g= $i.Q701g
$Q701h= $i.Q701h
$Q701i= $i.Q701i
$Q701j= $i.Q701j
$Q701k= $i.Q701k
$Q701l= $i.Q701l
$Q701m= $i.Q701m
$Q701n= $i.Q701n
$Q701p= $i.Q701p
$Q701q= $i.Q701q
$Q701o= $i.Q701o
$Q702a= $i.Q702a
$Q702b= $i.Q702b
$Q702c= $i.Q702c
$Q702d= $i.Q702d
$Q702e= $i.Q702e
$Q702f= $i.Q702f
$Q702g= $i.Q702g
$Q702h= $i.Q702h
$Q702i= $i.Q702i
$Q702j= $i.Q702j
$Q702k= $i.Q702k
$Q702l= $i.Q702l
$Q702m= $i.Q702m
$Q702n= $i.Q702n
$Q702o= $i.Q702o
$Q702p= $i.Q702p
$Q702q= $i.Q702q
$Q703a= $i.Q703a
$Q703b= $i.Q703b
$Q703c= $i.Q703c
$Q703d= $i.Q703d
$Q703e= $i.Q703e
$Q703f= $i.Q703f
$Q703g= $i.Q703g
$Q703h= $i.Q703h
$Q703i= $i.Q703i
$Q703j= $i.Q703j
$Q703k= $i.Q703k
$Q703l= $i.Q703l
$Q703m= $i.Q703m
$Q703n= $i.Q703n
$Q703o= $i.Q703o
$Q703p= $i.Q703p
$Q703q= $i.Q703q
$Q704a= $i.Q704a
$Q704b= $i.Q704b
$Q704c= $i.Q704c
$Q704d= $i.Q704d
$Q704e= $i.Q704e
$Q704f= $i.Q704f
$Q704g= $i.Q704g
$Q704h= $i.Q704h
$Q704i= $i.Q704i
$Q704j= $i.Q704j
$Q704k= $i.Q704k
$Q704l= $i.Q704l
$Q704m= $i.Q704m
$Q704n= $i.Q704n
$Q704o= $i.Q704o
$Q704p= $i.Q704p
$Q704q= $i.Q704q
$Q705a= $i.Q705a
$Q705b= $i.Q705b
$Q705c= $i.Q705c
$Q706= $i.Q706
$Q706other= $i.Q706other.replace("'","")
$Q707a= $i.Q707a
$Q707b= $i.Q707b
$Q707c= $i.Q707c
$Q708= $i.Q708
$Q708other= $i.Q708other.replace("'","")
$Q709a= $i.Q709a
$Q709b= $i.Q709b
$Q709c= $i.Q709c
$Q709other= $i.Q709other.replace("'","")
$Q710a= $i.Q710a
$Q710b= $i.Q710b
$Q710c= $i.Q710c
$Q710d= $i.Q710d
$Q710e= $i.Q710e
$Q710f= $i.Q710f
$Q710g= $i.Q710g.replace("'","")
$Q711= $i.Q711
$Q712= $i.Q712
$Q713= $i.Q713
$Q714men= $i.Q714men
$Q714women= $i.Q714women
$Q715= $i.Q715
$Q716a= $i.Q716a
$Q716b= $i.Q716b
$Q716c= $i.Q716c
$Q716d= $i.Q716d
$Q716e= $i.Q716e
$Q716f= $i.Q716f
$Q717a= $i.Q717a
$Q717b= $i.Q717b
$Q718a= $i.Q718a
$Q718b= $i.Q718b
$Q719= $i.Q719
$Q720= $i.Q720
$Q721ca= $i.Q721ca
$Q721cb= $i.Q721cb
$Q721cc= $i.Q721cc
$Q721cd= $i.Q721cd
$Q721ce= $i.Q721ce
$Q721cf= $i.Q721cf
$Q721cg= $i.Q721cg
$Q721ra= $i.Q721ra
$Q721rb= $i.Q721rb
$Q721rc= $i.Q721rc
$Q721rd= $i.Q721rd
$Q721re= $i.Q721re
$Q721rf= $i.Q721rf
$Q721rg= $i.Q721rg
$Q722= $i.Q722
$Q723a= $i.Q723a
$Q723b= $i.Q723b
$Q724a= $i.Q724a
$Q724b= $i.Q724b
$Q725a= $i.Q725a
$Q725b= $i.Q725b
$Q725c= $i.Q725c
$Q725d= $i.Q725d
$Q725e= $i.Q725e
$Q726= $i.Q726
$Q727= $i.Q727
$Q728= $i.Q728
$Q729= $i.Q729
$Q730= $i.Q730
$Q731a= $i.Q731a
$Q731b= $i.Q731b
$Q731c= $i.Q731c
$Q731d= $i.Q731d
$Q731e= $i.Q731e
$Q731f= $i.Q731f
$Q731other= $i.Q731other.replace("'","")
$Q732= $i.Q732
$Q733= $i.Q733
$Q734= $i.Q734
$Q735= $i.Q735
$Q736= $i.Q736
$Q737a= $i.Q737a
$Q737b= $i.Q737b
$Q737c= $i.Q737c
$Q737d= $i.Q737d
$Q737e= $i.Q737e
$Q737f= $i.Q737f
$Q737g= $i.Q737g
$Q737h= $i.Q737h
$Q737i= $i.Q737i
$Q737j= $i.Q737j
$Q737k= $i.Q737k
$Q737l= $i.Q737l
$Q737m= $i.Q737m
$Q737n= $i.Q737n
$Q737o= $i.Q737o
$Q737other= $i.Q737other.replace("'","")
$Q738a= $i.Q738a
$Q738b= $i.Q738b
$Q738c= $i.Q738c
$Q738d= $i.Q738d
$Q738e= $i.Q738e
$Q738f= $i.Q738f
$Q738g= $i.Q738g
$Q738h= $i.Q738h
$Q738i= $i.Q738i
$Q738j= $i.Q738j.replace("'","")
$Q739a= $i.Q739a
$Q739b= $i.Q739b
$Q740a= $i.Q740a
$Q740b= $i.Q740b
$Q740c= $i.Q740c
$Q741= $i.Q741
$Q742= $i.Q742
$Q743= $i.Q743
$Q744= $i.Q744
$Q745= $i.Q745
$Q746= $i.Q746
$Q746a= $i.Q746a.replace("'","")
$Q747= $i.Q747
$Q748= $i.Q748
$Q749= $i.Q749
$Q749other= $i.Q749other.replace("'","")
$Q750a= $i.Q750a
$Q750b= $i.Q750b
$Q751= $i.Q751
$Q751other= $i.Q751other.replace("'","")
$Q752= $i.Q752
$Q753= $i.Q753
$Q753other= $i.Q753other.replace("'","")
$Q754= $i.Q754
$Q754other= $i.Q754other.replace("'","")
$Q755= $i.Q755
$Q756= $i.Q756
$Q757a= $i.Q757a
$Q757b= $i.Q757b
$Q758= $i.Q758
$Q759= $i.Q759
$METAKEY= $i.METAKEY

$SQLQuery = "INSERT INTO hlthaces_7 (hhkey,
hhmem_key,
Q701a,
Q701b,
Q701c,
Q701d,
Q701e,
Q701f,
Q701g,
Q701h,
Q701i,
Q701j,
Q701k,
Q701l,
Q701m,
Q701n,
Q701p,
Q701q,
Q701o,
Q702a,
Q702b,
Q702c,
Q702d,
Q702e,
Q702f,
Q702g,
Q702h,
Q702i,
Q702j,
Q702k,
Q702l,
Q702m,
Q702n,
Q702o,
Q702p,
Q702q,
Q703a,
Q703b,
Q703c,
Q703d,
Q703e,
Q703f,
Q703g,
Q703h,
Q703i,
Q703j,
Q703k,
Q703l,
Q703m,
Q703n,
Q703o,
Q703p,
Q703q,
Q704a,
Q704b,
Q704c,
Q704d,
Q704e,
Q704f,
Q704g,
Q704h,
Q704i,
Q704j,
Q704k,
Q704l,
Q704m,
Q704n,
Q704o,
Q704p,
Q704q,
Q705a,
Q705b,
Q705c,
Q706,
Q706other,
Q707a,
Q707b,
Q707c,
Q708,
Q708other,
Q709a,
Q709b,
Q709c,
Q709other,
Q710a,
Q710b,
Q710c,
Q710d,
Q710e,
Q710f,
Q710g,
Q711,
Q712,
Q713,
Q714men,
Q714women,
Q715,
Q716a,
Q716b,
Q716c,
Q716d,
Q716e,
Q716f,
Q717a,
Q717b,
Q718a,
Q718b,
Q719,
Q720,
Q721ca,
Q721cb,
Q721cc,
Q721cd,
Q721ce,
Q721cf,
Q721cg,
Q721ra,
Q721rb,
Q721rc,
Q721rd,
Q721re,
Q721rf,
Q721rg,
Q722,
Q723a,
Q723b,
Q724a,
Q724b,
Q725a,
Q725b,
Q725c,
Q725d,
Q725e,
Q726,
Q727,
Q728,
Q729,
Q730,
Q731a,
Q731b,
Q731c,
Q731d,
Q731e,
Q731f,
Q731other,
Q732,
Q733,
Q734,
Q735,
Q736,
Q737a,
Q737b,
Q737c,
Q737d,
Q737e,
Q737f,
Q737g,
Q737h,
Q737i,
Q737j,
Q737k,
Q737l,
Q737m,
Q737n,
Q737o,
Q737other,
Q738a,
Q738b,
Q738c,
Q738d,
Q738e,
Q738f,
Q738g,
Q738h,
Q738i,
Q738j,
Q739a,
Q739b,
Q740a,
Q740b,
Q740c,
Q741,
Q742,
Q743,
Q744,
Q745,
Q746,
Q746a,
Q747,
Q748,
Q749,
Q749other,
Q750a,
Q750b,
Q751,
Q751other,
Q752,
Q753,
Q753other,
Q754,
Q754other,
Q755,
Q756,
Q757a,
Q757b,
Q758,
Q759,
METAKEY)     VALUES ('$hhkey',
'$hhmem_key',
'$Q701a',
'$Q701b',
'$Q701c',
'$Q701d',
'$Q701e',
'$Q701f',
'$Q701g',
'$Q701h',
'$Q701i',
'$Q701j',
'$Q701k',
'$Q701l',
'$Q701m',
'$Q701n',
'$Q701p',
'$Q701q',
'$Q701o',
'$Q702a',
'$Q702b',
'$Q702c',
'$Q702d',
'$Q702e',
'$Q702f',
'$Q702g',
'$Q702h',
'$Q702i',
'$Q702j',
'$Q702k',
'$Q702l',
'$Q702m',
'$Q702n',
'$Q702o',
'$Q702p',
'$Q702q',
'$Q703a',
'$Q703b',
'$Q703c',
'$Q703d',
'$Q703e',
'$Q703f',
'$Q703g',
'$Q703h',
'$Q703i',
'$Q703j',
'$Q703k',
'$Q703l',
'$Q703m',
'$Q703n',
'$Q703o',
'$Q703p',
'$Q703q',
'$Q704a',
'$Q704b',
'$Q704c',
'$Q704d',
'$Q704e',
'$Q704f',
'$Q704g',
'$Q704h',
'$Q704i',
'$Q704j',
'$Q704k',
'$Q704l',
'$Q704m',
'$Q704n',
'$Q704o',
'$Q704p',
'$Q704q',
'$Q705a',
'$Q705b',
'$Q705c',
'$Q706',
'$Q706other',
'$Q707a',
'$Q707b',
'$Q707c',
'$Q708',
'$Q708other',
'$Q709a',
'$Q709b',
'$Q709c',
'$Q709other',
'$Q710a',
'$Q710b',
'$Q710c',
'$Q710d',
'$Q710e',
'$Q710f',
'$Q710g',
'$Q711',
'$Q712',
'$Q713',
'$Q714men',
'$Q714women',
'$Q715',
'$Q716a',
'$Q716b',
'$Q716c',
'$Q716d',
'$Q716e',
'$Q716f',
'$Q717a',
'$Q717b',
'$Q718a',
'$Q718b',
'$Q719',
'$Q720',
'$Q721ca',
'$Q721cb',
'$Q721cc',
'$Q721cd',
'$Q721ce',
'$Q721cf',
'$Q721cg',
'$Q721ra',
'$Q721rb',
'$Q721rc',
'$Q721rd',
'$Q721re',
'$Q721rf',
'$Q721rg',
'$Q722',
'$Q723a',
'$Q723b',
'$Q724a',
'$Q724b',
'$Q725a',
'$Q725b',
'$Q725c',
'$Q725d',
'$Q725e',
'$Q726',
'$Q727',
'$Q728',
'$Q729',
'$Q730',
'$Q731a',
'$Q731b',
'$Q731c',
'$Q731d',
'$Q731e',
'$Q731f',
'$Q731other',
'$Q732',
'$Q733',
'$Q734',
'$Q735',
'$Q736',
'$Q737a',
'$Q737b',
'$Q737c',
'$Q737d',
'$Q737e',
'$Q737f',
'$Q737g',
'$Q737h',
'$Q737i',
'$Q737j',
'$Q737k',
'$Q737l',
'$Q737m',
'$Q737n',
'$Q737o',
'$Q737other',
'$Q738a',
'$Q738b',
'$Q738c',
'$Q738d',
'$Q738e',
'$Q738f',
'$Q738g',
'$Q738h',
'$Q738i',
'$Q738j',
'$Q739a',
'$Q739b',
'$Q740a',
'$Q740b',
'$Q740c',
'$Q741',
'$Q742',
'$Q743',
'$Q744',
'$Q745',
'$Q746',
'$Q746a',
'$Q747',
'$Q748',
'$Q749',
'$Q749other',
'$Q750a',
'$Q750b',
'$Q751',
'$Q751other',
'$Q752',
'$Q753',
'$Q753other',
'$Q754',
'$Q754other',
'$Q755',
'$Q756',
'$Q757a',
'$Q757b',
'$Q758',
'$Q759',
'$METAKEY')"


       
       # Cloud Database Settings
        $impcsv = invoke-sqlcmd -Username $CloudDatabaseUser -Password $CloudDatabasePWD -Database $CloudDatabaseName -Query $SQLQuery  -serverinstance $CloudSQLServerInstance  
        $InfoMessage = "Household memID $hhmem_key successfully uploaded to Cloud YZ-UHP database on SmarterASP."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 


 $InfoMessage = "Successfully imported $count HLTHACCESS Qstns into the YZ-UHP CLOUD database" 
 Write-Log -Message $InfoMessage -Path $LogFile   -Level Info

 

$InfoMessage = "Qstns Data upload completed"
}



Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    
    Write-Log -Message "Error : Upload to Cloud database failed with the error : $ErrorMessage" -Path $LogFile -Level Error
}






