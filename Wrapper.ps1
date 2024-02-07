
$ScriptPath = Split-Path $MyInvocation.MyCommand.Path
<#    Calling the Household Scripts  #>
. "$ScriptPath\importCSVhhindent.ps1"
. "$ScriptPath\importCSVhhmall.ps1"
. "$ScriptPath\importCSVhhelig.ps1"

<#    Calling the INDVQ Scripts  #>
. "$ScriptPath\importCSVbackchar.ps1"
. "$ScriptPath\importCSVsexpartnresnow.ps1"
. "$ScriptPath\importCSVpsycho.ps1"
. "$ScriptPath\importCSVsexrels.ps1"
. "$ScriptPath\importCSVsexrelslast.ps1"
. "$ScriptPath\importCSVhivprev.ps1"
. "$ScriptPath\importCSVhivaware.ps1"
. "$ScriptPath\importCSVhlthaces.ps1"
. "$ScriptPath\importCSVferthist.ps1"

<#    Calling the PITC Scripts  #>
. "$ScriptPath\importCSVPITC.ps1"




