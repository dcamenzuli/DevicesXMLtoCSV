#The XML file for this script can be found at the following URL: https://[RUM CONSOLE]:4183/cxf/rest/backup

$inputFile = Read-Host -Prompt 'Enter XML File Name'
[xml]$inputXML = Get-Content $inputFile -Encoding:UTF8
$xmlSize = $inputXML.ChildNodes.devices.Count
$fileOutput = @()

for($i=1; $i -lt $xmlSize; ++$i)
{
	$DeviceName = $inputXML.ChildNodes.devices[$i].name
	$Type = $inputXML.ChildNodes.devices[$i].type
	$Version = $inputXML.ChildNodes.devices[$i].version
	$OS = $inputXML.ChildNodes.devices[$i].os
	$IPAddress = ($inputXML.ChildNodes.devices[$i].parameters.entries | Where-Object { $_.Key -eq 'IP'}).Value
	$Role = ''
	switch($Type)
		{
			0 { $Type = 'AMD' }
			5 { $Type = 'ESM' }
			11 { $Type = 'ADS' }
			10 { $Type = 'CAS' ; $Role = ($inputXML.ChildNodes.devices[$i].parameters.entries | Where-Object { $_.Key -eq 'SERVER_ROLE'}).Value }
		}
	$row = New-Object PSObject
	$row | Add-Member -MemberType NoteProperty -Name 'Device Name' -Value $DeviceName
	$row | Add-Member -MemberType NoteProperty -Name 'IP' -Value $IPAddress
	$row | Add-Member -MemberType NoteProperty -Name 'Device Type' -Value $Type
	$row | Add-Member -MemberType NoteProperty -Name 'Version' -Value $Version
	$row | Add-Member -MemberType NoteProperty -Name 'OS' -Value $OS
	$row | Add-Member -MemberType NoteProperty -Name 'Role' -Value $Role
	$fileOutput += $row
}

$outputName = Read-Host -Prompt 'Enter name for output CSV file'
$fileOutput | Export-CSV $outputName -NoTypeInformation

