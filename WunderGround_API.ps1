#requires -version 3
<#
.SYNOPSIS
    This script will connect to the wunderground API and get weather data.
.DESCRIPTION
    This script used Invoke-RestMethod to collect the data from the wunderground API and then output that data
    as an option.  The intent of this script is to be used with a trending application like zabbix.
.PARAMETER Option
    Feed the Option of the metric you want to collect.  Supported options are Temp, Dew, Pressure, Gust, Wind
    Rain, humidity, Time
.NOTES
    Version:        1.0
    Author:         Dusty Lane
    Creation Date:  07/11/2017
    Purpose/Change: Initial script development
  
.EXAMPLE
    .\WUnderGround_API.ps1 -Option Temp
#>
param(
    [Parameter(Mandatory = $true,Position = 0)]
	[String] $Option
)


#region ######### Initializations ##################
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
set-location $here
$path = $env:TEMP
$filePineGap = "$path\PineGap.xml"
$fileSweet = "$path\sweet.xml"
$apikey = get-content .\apikey.txt
$lastWrite = (get-item $filePineGap).LastWriteTime
$timespan = new-timespan -minutes 6
$KIDHURL = "http://api.wunderground.com/api/$apikey/conditions/q/pws:KIDHORSE4.xml"
$KIDSURL = "http://api.wunderground.com/api/$apikey/conditions/q/pws:KIDSWEET2.xml"
#endregion

# make sure that the files exist the first time around (limiting errors)
if (!(Test-Path $filePineGap))
{
    Invoke-RestMethod -Uri $KIDHURL -Method get -OutFile $filePineGap
    [xml]$Out = (Get-Content $filePineGap)
}

if (!(Test-Path $fileSweet))
{
    Invoke-RestMethod -Uri $KIDSURL -Method get -OutFile $fileSweet
    [xml]$Out = (Get-Content $fileSweet)
}

# update the files if they are older than x minutes
if (((get-date) - $lastWrite) -gt $timespan) {

    Invoke-RestMethod -Uri $KIDSURL -Method get -OutFile $fileSweet
    Invoke-RestMethod -Uri $KIDHURL -Method get -OutFile $filePineGap
}

# Get the data from the file - depending on what weather station we need.

If ($option -eq "Wind" -or $option -eq "Gust" -or $option -eq "Rain")
{
    Write-Verbose "getting location sweet data"
    [xml]$Out = (Get-Content $fileSweet)
}
else
{
    Write-Verbose "getting location PineGap data"
    [xml]$Out = (Get-Content $filePineGap)
}

# create an object to reference
$output = [PSCustomObject]@{
    Temp = $Out.response.current_observation.temp_f
    Time = $Out.response.current_observation.observation_epoch
    Humidity = ($out.response.current_observation.relative_humidity).split('%')[0]
    Pressure = $Out.response.current_observation.pressure_in
    Dew = $Out.response.current_observation.dewpoint_f
    Wind = $Out.response.current_observation.wind_mph
    Gust = $Out.response.current_observation.wind_gust_mph
    Rain = $Out.response.current_observation.precip_1hr_in
}

$output.$option

$out = $null
