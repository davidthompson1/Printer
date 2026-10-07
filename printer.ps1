 <#
Description: Downloads and installs the Printer Driver for Zendesk Printers
             $PrinterIP needs to be updated with the IP of the printer
             $PrinterName needs to be updated with the office code, floor
                          and printer number e.g. SFO 6th BizHub 1
Author:	     Dave Thompson
Date:        07/10/2023
ChangeLog
22/04/26 - Updated the URL for the driver download and replaced for 7Zip requirement with expand-archive
#>

$PrinterIP = "10.14.0.198"
$PrinterName = "MAD 6th BizHub"
$PrinterPort = "IP_$PrinterIP"
$DriverName = "KONICA MINOLTA Universal V4 PCL"
$DownloadPath = "C:\Temp"
$DownloadUrl = "https://dl.konicaminolta.eu/en/?tx_kmdownloadproxy_downloadproxy[fileId]=d8c397e3d1d47fba3dd9993ae0bc5ba9&tx_kmdownloadproxy_downloadproxy[documentId]=147717&tx_kmdownloadproxy_downloadproxy[system]=KonicaMinolta&tx_kmdownloadproxy_downloadproxy[language]=EN&type=1558521685"

# Delete old driver
if (Test-Path $DownloadPath\KonicaDriver.zip){
    Remove-Item $DownloadPath\KonicaDriver.zip
    Remove-Item $DownloadPath\Driver -Recurse -Force
    }

# Download Konica Minolta universal driver. 
Invoke-WebRequest $DownloadUrl -UseBasicParsing -OutFile $DownloadPath\KonicaDriver.zip

# Extract Driver
Expand-Archive $DownloadPath\KonicaDriver.zip $DownloadPath\Driver 

# Remove existing printer and port
Get-Printer | where {$_.PortName -eq $PrinterPort} | Remove-Printer
Get-PrinterPort | Where {$_.Name -eq $PrinterPort} | Remove-PrinterPort

# Install Architecture specific driver, port and printer. 
if(${env:ProgramFiles(Arm)}){
    pnputil /add-driver "$DownloadPath\Driver\UPD4PCL6Win81P_2904MU\Driver\ARM64_Win11\PCL6\KOBxxK__01.inf" 
    }
else {
    pnputil /add-driver "$DownloadPath\Driver\UPD4PCL6Win81P_2904MU\Driver\x64\PCL6\KOBxxK__01.inf" 
    }
Add-PrinterPort -Name $PrinterPort -PrinterHostAddress $PrinterIP
Add-PrinterDriver -Name $DriverName 
Add-Printer -Name $PrinterName -DriverName $DriverName -PortName $PrinterPort 


