
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
$SourceCSVFile = 'C:\DATA\Briefcase\BriefcaseDownloads\Household_Questionnaire.csv'
$FormattedCSVFile = 'C:\DATA\Briefcase\Formatted\hhindent_7.csv'
$RawBackupFolder = 'C:\DATA\Briefcase\Backup\Raw\hh\'
$FormattedBackupFolder = 'C:\DATA\Briefcase\Backup\Formatted\hh\'
$LogFileFolder = 'C:\DATA\Briefcase\Log\'
$ConsentEsignature = 'C:\DATA\Briefcase\BriefcaseDownloads\media'
$ESignatureBackupFolderPath = 'C:\DATA\Briefcase\Backup\signatures\'

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
$DatabaseTable = 'hhident_7'

# Lets create a Log file to log the events that will be happening today. Generate log file with current date.
$date = Get-Date -UFormat "%Y%m%d"
$LogFile = $LogFileFolder+'log-'+$date+'-hhident.log'

# Backup folder name
$BackupFolderName = 'bck'+$date
$SignaturesBackupFolderName = $ESignatureBackupFolderPath+'esignaturebck'+$date


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
 Select  -Property @{Name="SubmissionDate";Expression={$_."SubmissionDate"}},
			      @{Name="start";Expression={$_."start"}},
			      @{Name="endtime";Expression={$_."endtime"}},
			      @{Name="deviceid";Expression={$_."deviceid"}},
			      @{Name="simid";Expression={$_."simid"}},
			      @{Name="devicephonenumber";Expression={$_."devicephonenumber"}},
			      @{Name="now_string";Expression={$_."now_string"}},
			      @{Name="interviewer";Expression={$_."interviewer"}},
			      @{Name="interviewer_other";Expression={$_."interviewer_other"}},
			      @{Name="site";Expression={$_."site"}},
			      @{Name="hhonlist";Expression={$_."hhdetails-hhonlist"}},
			      @{Name="hhid_7";Expression={$_."hhdetails-hhid_7"}},
			      @{Name="rand_dice";Expression={$_."hhdetails-rand_dice"}},
			      @{Name="hhkey";Expression={$_."hhdetails-hhkey"}},
			      @{Name="cluster_r6";Expression={$_."hhdetails-cluster_r6"}},
			      @{Name="village_r6";Expression={$_."hhdetails-village_r6"}},
			      @{Name="category_r6";Expression={$_."hhdetails-category_r6"}},
			      @{Name="gp_r6";Expression={$_."hhdetails-gp_r6"}},
			      @{Name="disttr_r6";Expression={$_."hhdetails-disttr_r6"}},
			      @{Name="head_r6";Expression={$_."hhdetails-head_r6"}},
			      @{Name="yeshh_6";Expression={$_."hhdetails-yeshh_6"}},
			      @{Name="hhkey_r7";Expression={$_."hhdetails-dent-hhkey_r7"}},
			      @{Name="district_7";Expression={$_."hhdetails-district_7"}},
			      @{Name="ward_r7";Expression={$_."hhdetails-ward_r7"}},
			      @{Name="village_r7";Expression={$_."hhdetails-village_r7"}},
			      @{Name="hhaddress_r7";Expression={$_."hhdetails-hhaddress_r7"}},
			      @{Name="hhname_r6";Expression={$_."hhdetails-hhname_r6"}},
			      @{Name="hhname_r7";Expression={$_."hhdetails-hhname_r7"}},
			      @{Name="category_r7";Expression={$_."hhdetails-category_r7"}},
			      @{Name="cluster_r7";Expression={$_."hhdetails-cluster_r7"}},
			      @{Name="gp_r7";Expression={$_."hhdetails-gp_r7"}},
			      @{Name="disttr_r7";Expression={$_."hhdetails-disttr_r7"}},
			      @{Name="gps_Latitude";Expression={$_."hhdetails-gps-Latitude"}},
			      @{Name="gps_Longitude";Expression={$_."hhdetails-gps-Longitude"}},
			      @{Name="gps_Altitude";Expression={$_."hhdetails-gps-Altitude"}},
			      @{Name="gps_Accuracy";Expression={$_."hhdetails-gps-Accuracy"}},
			      @{Name="householdmet";Expression={$_."hhdetails-householdmet"}},
			      @{Name="HouseHoldType";Expression={$_."InterviewerMetARespondent-HouseHoldType"}},
			      @{Name="hhtype1";Expression={$_."InterviewerMetARespondent-hhtype1"}},
			      @{Name="hhtype2";Expression={$_."InterviewerMetARespondent-hhtype2"}},
			      @{Name="yeshh_7";Expression={$_."InterviewerMetARespondent-yeshh_7"}},
			      @{Name="n_dths12m_7";Expression={$_."InterviewerMetARespondent-n_dths12m_7"}},
			      @{Name="n_dths12m_1559_7";Expression={$_."InterviewerMetARespondent-n_dths12m_1559_7"}},
			      @{Name="consent_r7";Expression={$_."InterviewerMetARespondent-consent_r7"}},
                  @{Name="signature_r7";Expression={$_."InterviewerMetARespondent-consentform-signature"}},         
  
			      @{Name="consent_form_collected_r7";Expression={$_."InterviewerMetARespondent-ConsentFormCollection-consent_form_collected_r7"}},

			      @{Name="watersource_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-socio-economic-watersource_r7"}},
			      @{Name="other_watersource_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-socio-economic-other_watersource_r7"}},

			      @{Name="toilet_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-socio-economic-toilet_r7"}},
			      @{Name="other_toilet_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-socio-economic-other_toilet_r7"}},
			      @{Name="toiletshared_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-socio-economic-toiletshared_r7"}},
			      @{Name="electricity_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-socio-economic-hhhave_r7-electricity_r7"}},
			      @{Name="fridge_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-socio-economic-hhhave_r7-fridge_r7"}},
			      @{Name="radio_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-socio-economic-hhhave_r7-radio_r7"}},
			      @{Name="tv_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-socio-economic-hhhave_r7-tv_r7"}},
			      @{Name="hsetype_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-socio-economic-hsetype_r7"}},
			      @{Name="hsefloor_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-socio-economic-hsefloor_r7"}},
			      @{Name="bicycle_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-socio-economic-hhown_r7-bicycle_r7"}},
			      @{Name="motorcycle_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-socio-economic-hhown_r7-motorcycle_r7"}},
			      @{Name="car_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-socio-economic-hhown_r7-car_r7"}},
			      @{Name="tractor_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-socio-economic-hhown_r7-tractor_r7"}},
			      @{Name="hhcattle_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-socio-economic-hhcattle_r7"}},
			      @{Name="hhfood1_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-hhfood-hhfood1_r7"}},
			      @{Name="hhfood2_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-hhfood-hhfood2_r7"}},
			      @{Name="hhfood3_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-hhfood-hhfood3_r7"}},
			      @{Name="hhfood4_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-hhfood-hhfood4_r7"}},
			      @{Name="hhfood5_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-hhfood-hhfood5_r7"}},
			      @{Name="hhfood6_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-hhfood-hhfood6_r7"}},
			      @{Name="hhfood7_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-hhfood-hhfood7_r7"}},
			      @{Name="hhfood8_r7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-hhfood-hhfood8_r7"}},
			      @{Name="memberleft";Expression={$_."InterviewerMetARespondent-ConsentedInterview-household-members-memberleft"}},
			      @{Name="memberleft1";Expression={$_."InterviewerMetARespondent-ConsentedInterview-household-members-memberleft1"}},
			      @{Name="memberleft2";Expression={$_."InterviewerMetARespondent-ConsentedInterview-household-members-memberleft2"}},
			      @{Name="NumEligibleMembers";Expression={$_."InterviewerMetARespondent-ConsentedInterview-household-members-NumEligibleMembers"}},

			      @{Name="EligibleMembers_count";Expression={$_."InterviewerMetARespondent-ConsentedInterview-household-members-EligibleHouseHoldMembers-EligibleMembers_count"}},

			      @{Name="hh_head_phone_7";Expression={$_."InterviewerMetARespondent-ConsentedInterview-household-members-EligibleHouseHoldMembers-hh_head_phone_7"}},
			      
			      @{Name="hh_notmet_appntmt_7";Expression={$_."hh_notmet_appntmt_7"}},
			      @{Name="end_1";Expression={$_."end_1"}},
			      @{Name="completed";Expression={$_."completed"}},
			      @{Name="othercompleted";Expression={$_."othercompleted"}},
			      @{Name="not_consented";Expression={$_."not_consented"}},
			      @{Name="InterviewEnd";Expression={$_."InterviewEnd"}},
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
 $count = 0 
 
 foreach($i in $data){
		$SubmissionDate= $i.SubmissionDate
		$start= $i.start
		$endtime= $i.endtime
		$deviceid= $i.deviceid
		$simid= $i.simid
		$devicephonenumber= $i.devicephonenumber
		$now_string= $i.now_string
		$interviewer= $i.interviewer
		$interviewer_other= $i.interviewer_other.replace("'","")
		$site= $i.site
		$hhonlist= $i.hhonlist
		$hhid_7= $i.hhid_7
		$rand_dice= $i.rand_dice
		$hhkey= $i.hhkey
		$cluster_r6= $i.cluster_r6
		$village_r6= $i.village_r6
		$category_r6= $i.category_r6
		$gp_r6= $i.gp_r6
		$disttr_r6= $i.disttr_r6
		$head_r6= $i.head_r6
		$yeshh_6= $i.yeshh_6
		$hhkey_r7= $i.hhkey_r7
		$district_7= $i.district_7
		$ward_r7= $i.ward_r7
		$village_r7= $i.village_r7
		$hhaddress_r7= $i.hhaddress_r7.replace("'","")
		$hhname_r6= $i.hhname_r6
		$hhname_r7= $i.hhname_r7.replace("'","")
		$category_r7= $i.category_r7
		$cluster_r7= $i.cluster_r7
		$gp_r7= $i.gp_r7
		$disttr_r7= $i.disttr_r7
		$gps_Latitude= $i.gps_Latitude
		$gps_Longitude= $i.gps_Longitude
		$gps_Altitude= $i.gps_Altitude
		$gps_Accuracy= $i.gps_Accuracy
		$householdmet= $i.householdmet
		$HouseHoldType= $i.HouseHoldType
		$hhtype1= $i.hhtype1
		$hhtype2= $i.hhtype2
		$yeshh_7= $i.yeshh_7
		$n_dths12m_7= $i.n_dths12m_7
		$n_dths12m_1559_7= $i.n_dths12m_1559_7
		$consent_r7= $i.consent_r7
        $signature_r7= $i.signature_r7
		$consent_form_collected_r7= $i.consent_form_collected_r7
		$watersource_r7= $i.watersource_r7
		$other_watersource_r7= $i.other_watersource_r7.replace("'","")
		$toilet_r7= $i.toilet_r7
		$other_toilet_r7= $i.other_toilet_r7.replace("'","")
		$toiletshared_r7= $i.toiletshared_r7
		$electricity_r7= $i.electricity_r7
		$fridge_r7= $i.fridge_r7
		$radio_r7= $i.radio_r7
		$tv_r7= $i.tv_r7
		$hsetype_r7= $i.hsetype_r7
		$hsefloor_r7= $i.hsefloor_r7
		$bicycle_r7= $i.bicycle_r7
		$motorcycle_r7= $i.motorcycle_r7
		$car_r7= $i.car_r7
		$tractor_r7= $i.tractor_r7
		$hhcattle_r7= $i.hhcattle_r7
		$hhfood1_r7= $i.hhfood1_r7
		$hhfood2_r7= $i.hhfood2_r7
		$hhfood3_r7= $i.hhfood3_r7
		$hhfood4_r7= $i.hhfood4_r7
		$hhfood5_r7= $i.hhfood5_r7
		$hhfood6_r7= $i.hhfood6_r7
		$hhfood7_r7= $i.hhfood7_r7
		$hhfood8_r7= $i.hhfood8_r7
		$memberleft= $i.memberleft
		$memberleft1= $i.memberleft1
		$memberleft2= $i.memberleft2
		$NumEligibleMembers= $i.NumEligibleMembers
		$EligibleMembers_count= $i.EligibleMembers_count
		$hh_head_phone_7= $i.hh_head_phone_7
		$hh_notmet_appntmt_7= $i.hh_notmet_appntmt_7
		$end_1= $i.end_1
		$completed= $i.completed
		$othercompleted= $i.othercompleted.replace("'","")
		$not_consented= $i.not_consented
		$InterviewEnd= $i.InterviewEnd
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
		$METAKEY= $i.METAKEY

    $SQLQuery = "INSERT INTO hhindent_7 (SubmissionDate,
		start,
		endtime,
		deviceid,
		simid,
		devicephonenumber,
		now_string,
		interviewer,
		interviewer_other,
		site,
		hhonlist,
		hhid_7,
		rand_dice,
		hhkey,
		cluster_r6,
		village_r6,
		category_r6,
		gp_r6,
		disttr_r6,
		head_r6,
		yeshh_6,
		hhkey_r7,
		district_7,
		ward_r7,
		village_r7,
		hhaddress_r7,
		hhname_r6,
		hhname_r7,
		category_r7,
		cluster_r7,
		gp_r7,
		disttr_r7,
		gps_Latitude,
		gps_Longitude,
		gps_Altitude,
		gps_Accuracy,
		householdmet,
		HouseHoldType,
		hhtype1,
		hhtype2,
		yeshh_7,
		n_dths12m_7,
		n_dths12m_1559_7,
		consent_r7,
		consent_form_collected_r7,
		watersource_r7,
		other_watersource_r7,
		toilet_r7,
		other_toilet_r7,
		toiletshared_r7,
		electricity_r7,
		fridge_r7,
		radio_r7,
		tv_r7,
		hsetype_r7,
		hsefloor_r7,
		bicycle_r7,
		motorcycle_r7,
		car_r7,
		tractor_r7,
		hhcattle_r7,
		hhfood1_r7,
		hhfood2_r7,
		hhfood3_r7,
		hhfood4_r7,
		hhfood5_r7,
		hhfood6_r7,
		hhfood7_r7,
		hhfood8_r7,
		memberleft,
		memberleft1,
		memberleft2,
		NumEligibleMembers,
		EligibleMembers_count,
		hh_head_phone_7,
		hh_notmet_appntmt_7,
		end_1,
		completed,
		othercompleted,
		not_consented,
		InterviewEnd,
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
		METAKEY, signaturelink)                    VALUES ('$SubmissionDate',
		'$start',
		'$endtime',
		'$deviceid',
		'$simid',
		'$devicephonenumber',
		'$now_string',
		'$interviewer',
		'$interviewer_other',
		'$site',
		'$hhonlist',
		'$hhid_7',
		'$rand_dice',
		'$hhkey',
		'$cluster_r6',
		'$village_r6',
		'$category_r6',
		'$gp_r6',
		'$disttr_r6',
		'$head_r6',
		'$yeshh_6',
		'$hhkey_r7',
		'$district_7',
		'$ward_r7',
		'$village_r7',
		'$hhaddress_r7',
		'$hhname_r6',
		'$hhname_r7',
		'$category_r7',
		'$cluster_r7',
		'$gp_r7',
		'$disttr_r7',
		'$gps_Latitude',
		'$gps_Longitude',
		'$gps_Altitude',
		'$gps_Accuracy',
		'$householdmet',
		'$HouseHoldType',
		'$hhtype1',
		'$hhtype2',
		'$yeshh_7',
		'$n_dths12m_7',
		'$n_dths12m_1559_7',
		'$consent_r7',
		'$consent_form_collected_r7',
		'$watersource_r7',
		'$other_watersource_r7',
		'$toilet_r7',
		'$other_toilet_r7',
		'$toiletshared_r7',
		'$electricity_r7',
		'$fridge_r7',
		'$radio_r7',
		'$tv_r7',
		'$hsetype_r7',
		'$hsefloor_r7',
		'$bicycle_r7',
		'$motorcycle_r7',
		'$car_r7',
		'$tractor_r7',
		'$hhcattle_r7',
		'$hhfood1_r7',
		'$hhfood2_r7',
		'$hhfood3_r7',
		'$hhfood4_r7',
		'$hhfood5_r7',
		'$hhfood6_r7',
		'$hhfood7_r7',
		'$hhfood8_r7',
		'$memberleft',
		'$memberleft1',
		'$memberleft2',
		'$NumEligibleMembers',
		'$EligibleMembers_count',
		'$hh_head_phone_7',
		'$hh_notmet_appntmt_7',
		'$end_1',
		'$completed',
		'$othercompleted',
		'$not_consented',
		'$InterviewEnd',
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
		'$METAKEY','$signature_r7')"


        $impcsv = invoke-sqlcmd -Username $LocalDatabaseUser -Password $LocalDatabasePWD -Database $LocalDatabaseName -Query $SQLQuery  -serverinstance $LocalSQLServerInstance  
        $InfoMessage = "Household ID $hhkey_r7 successfully uploaded to YZ-UHP Local MSSSQL Server."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 
 $InfoMessage = "Successfully imported $count Households into the YZ-UHP database" 
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
		$start= $i.start
		$endtime= $i.endtime
		$deviceid= $i.deviceid
		$simid= $i.simid
		$devicephonenumber= $i.devicephonenumber
		$now_string= $i.now_string
		$interviewer= $i.interviewer
		$interviewer_other= $i.interviewer_other.replace("'","")
		$site= $i.site
		$hhonlist= $i.hhonlist
		$hhid_7= $i.hhid_7
		$rand_dice= $i.rand_dice
		$hhkey= $i.hhkey
		$cluster_r6= $i.cluster_r6
		$village_r6= $i.village_r6
		$category_r6= $i.category_r6
		$gp_r6= $i.gp_r6
		$disttr_r6= $i.disttr_r6
		$head_r6= $i.head_r6
		$yeshh_6= $i.yeshh_6
		$hhkey_r7= $i.hhkey_r7
		$district_7= $i.district_7
		$ward_r7= $i.ward_r7
		$village_r7= $i.village_r7
		$hhaddress_r7= $i.hhaddress_r7.replace("'","")
		$hhname_r6= $i.hhname_r6.replace("'","")
		$hhname_r7= $i.hhname_r7.replace("'","")
		$category_r7= $i.category_r7
		$cluster_r7= $i.cluster_r7
		$gp_r7= $i.gp_r7
		$disttr_r7= $i.disttr_r7
		$gps_Latitude= $i.gps_Latitude
		$gps_Longitude= $i.gps_Longitude
		$gps_Altitude= $i.gps_Altitude
		$gps_Accuracy= $i.gps_Accuracy
		$householdmet= $i.householdmet
		$HouseHoldType= $i.HouseHoldType
		$hhtype1= $i.hhtype1
		$hhtype2= $i.hhtype2
		$yeshh_7= $i.yeshh_7
		$n_dths12m_7= $i.n_dths12m_7
		$n_dths12m_1559_7= $i.n_dths12m_1559_7
		$consent_r7= $i.consent_r7
        $signature_r7= $i.signature_r7
		$consent_form_collected_r7= $i.consent_form_collected_r7
		$watersource_r7= $i.watersource_r7
		$other_watersource_r7= $i.other_watersource_r7.replace("'","")
		$toilet_r7= $i.toilet_r7
		$other_toilet_r7= $i.other_toilet_r7.replace("'","")
		$toiletshared_r7= $i.toiletshared_r7
		$electricity_r7= $i.electricity_r7
		$fridge_r7= $i.fridge_r7
		$radio_r7= $i.radio_r7
		$tv_r7= $i.tv_r7
		$hsetype_r7= $i.hsetype_r7
		$hsefloor_r7= $i.hsefloor_r7
		$bicycle_r7= $i.bicycle_r7
		$motorcycle_r7= $i.motorcycle_r7
		$car_r7= $i.car_r7
		$tractor_r7= $i.tractor_r7
		$hhcattle_r7= $i.hhcattle_r7
		$hhfood1_r7= $i.hhfood1_r7
		$hhfood2_r7= $i.hhfood2_r7
		$hhfood3_r7= $i.hhfood3_r7
		$hhfood4_r7= $i.hhfood4_r7
		$hhfood5_r7= $i.hhfood5_r7
		$hhfood6_r7= $i.hhfood6_r7
		$hhfood7_r7= $i.hhfood7_r7
		$hhfood8_r7= $i.hhfood8_r7
		$memberleft= $i.memberleft
		$memberleft1= $i.memberleft1
		$memberleft2= $i.memberleft2
		$NumEligibleMembers= $i.NumEligibleMembers
		$EligibleMembers_count= $i.EligibleMembers_count
		$hh_head_phone_7= $i.hh_head_phone_7
		$hh_notmet_appntmt_7= $i.hh_notmet_appntmt_7
		$end_1= $i.end_1
		$completed= $i.completed
		$othercompleted= $i.othercompleted.replace("'","")
		$not_consented= $i.not_consented
		$InterviewEnd= $i.InterviewEnd
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
		$METAKEY= $i.METAKEY

    $SQLQuery = "INSERT INTO hhindent_7 (SubmissionDate,
		start,
		endtime,
		deviceid,
		simid,
		devicephonenumber,
		now_string,
		interviewer,
		interviewer_other,
		site,
		hhonlist,
		hhid_7,
		rand_dice,
		hhkey,
		cluster_r6,
		village_r6,
		category_r6,
		gp_r6,
		disttr_r6,
		head_r6,
		yeshh_6,
		hhkey_r7,
		district_7,
		ward_r7,
		village_r7,
		hhaddress_r7,
		hhname_r6,
		hhname_r7,
		category_r7,
		cluster_r7,
		gp_r7,
		disttr_r7,
		gps_Latitude,
		gps_Longitude,
		gps_Altitude,
		gps_Accuracy,
		householdmet,
		HouseHoldType,
		hhtype1,
		hhtype2,
		yeshh_7,
		n_dths12m_7,
		n_dths12m_1559_7,
		consent_r7,
		consent_form_collected_r7,
		watersource_r7,
		other_watersource_r7,
		toilet_r7,
		other_toilet_r7,
		toiletshared_r7,
		electricity_r7,
		fridge_r7,
		radio_r7,
		tv_r7,
		hsetype_r7,
		hsefloor_r7,
		bicycle_r7,
		motorcycle_r7,
		car_r7,
		tractor_r7,
		hhcattle_r7,
		hhfood1_r7,
		hhfood2_r7,
		hhfood3_r7,
		hhfood4_r7,
		hhfood5_r7,
		hhfood6_r7,
		hhfood7_r7,
		hhfood8_r7,
		memberleft,
		memberleft1,
		memberleft2,
		NumEligibleMembers,
		EligibleMembers_count,
		hh_head_phone_7,
		hh_notmet_appntmt_7,
		end_1,
		completed,
		othercompleted,
		not_consented,
		InterviewEnd,
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
		METAKEY,signaturelink)                    VALUES ('$SubmissionDate',
		'$start',
		'$endtime',
		'$deviceid',
		'$simid',
		'$devicephonenumber',
		'$now_string',
		'$interviewer',
		'$interviewer_other',
		'$site',
		'$hhonlist',
		'$hhid_7',
		'$rand_dice',
		'$hhkey',
		'$cluster_r6',
		'$village_r6',
		'$category_r6',
		'$gp_r6',
		'$disttr_r6',
		'$head_r6',
		'$yeshh_6',
		'$hhkey_r7',
		'$district_7',
		'$ward_r7',
		'$village_r7',
		'$hhaddress_r7',
		'$hhname_r6',
		'$hhname_r7',
		'$category_r7',
		'$cluster_r7',
		'$gp_r7',
		'$disttr_r7',
		'$gps_Latitude',
		'$gps_Longitude',
		'$gps_Altitude',
		'$gps_Accuracy',
		'$householdmet',
		'$HouseHoldType',
		'$hhtype1',
		'$hhtype2',
		'$yeshh_7',
		'$n_dths12m_7',
		'$n_dths12m_1559_7',
		'$consent_r7',
		'$consent_form_collected_r7',
		'$watersource_r7',
		'$other_watersource_r7',
		'$toilet_r7',
		'$other_toilet_r7',
		'$toiletshared_r7',
		'$electricity_r7',
		'$fridge_r7',
		'$radio_r7',
		'$tv_r7',
		'$hsetype_r7',
		'$hsefloor_r7',
		'$bicycle_r7',
		'$motorcycle_r7',
		'$car_r7',
		'$tractor_r7',
		'$hhcattle_r7',
		'$hhfood1_r7',
		'$hhfood2_r7',
		'$hhfood3_r7',
		'$hhfood4_r7',
		'$hhfood5_r7',
		'$hhfood6_r7',
		'$hhfood7_r7',
		'$hhfood8_r7',
		'$memberleft',
		'$memberleft1',
		'$memberleft2',
		'$NumEligibleMembers',
		'$EligibleMembers_count',
		'$hh_head_phone_7',
		'$hh_notmet_appntmt_7',
		'$end_1',
		'$completed',
		'$othercompleted',
		'$not_consented',
		'$InterviewEnd',
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
		'$METAKEY','$signature_r7')"

        # Cloud Database Settings
        $impcsv = invoke-sqlcmd -Username $CloudDatabaseUser -Password $CloudDatabasePWD -Database $CloudDatabaseName -Query $SQLQuery  -serverinstance $CloudSQLServerInstance  
        $InfoMessage = "Household ID $hhkey_r7 successfully uploaded to Cloud YZ-UHP database on SmarterASP."  
        Write-Log -Message $InfoMessage -Path $LogFile   -Level Info
 
  $count  = $count + 1 
 
 } 
 $InfoMessage = "Successfully imported $count Households into the YZ-UHP CLOUD database" 
 Write-Log -Message $InfoMessage -Path $LogFile   -Level Info





$InfoMessage = "Household Data upload completed"
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

     if (!(Test-Path $SignaturesBackupFolderName)) { 
       
        Write-Verbose "Creating $SignaturesBackupFolderName." 
        New-Item -ItemType directory -Path $SignaturesBackupFolderName 
     }

     move-item -path $FormattedCSVFile -destination $FormattedBackupFolderPath
     $InfoMessage = "Backed up formatted CSV file $FormattedCSVFile to backup folder $FormattedBackupFolderPath " 
     Write-Log -Message $InfoMessage -Path $LogFile -Level Info

     # Lets move the signatures folder to backup
     move-item -path $ConsentEsignature -destination $SignaturesBackupFolderName  
     $InfoMessage = "Backed up e-signature media files to backup folder $SignaturesBackupFolderName " 
     Write-Log -Message $InfoMessage -Path $LogFile -Level Info

     $Time=Get-Date
     Write-Log "The process ended at $Time" -Path $LogFile -Level Info
    
    #Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential (Get-Credential) -Attachments $Attachment DeliveryNotificationOption OnSuccess
}

# END OF SCRIPT



