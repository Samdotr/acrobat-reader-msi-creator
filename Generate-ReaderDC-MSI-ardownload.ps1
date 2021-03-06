$ErrorActionPreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"

# LOGGING INITIALISATION
$logSource = "Heathfield Adobe Reader MSI generation"
if (![System.Diagnostics.EventLog]::SourceExists($logSource)){
        new-eventlog -LogName Application -Source $logSource
}

# END LOGGING

# CONFIGURATION VARIABLES


# Adobe reader version, visit https://www.adobe.com/devnet-docs/acrobatetk/tools/ReleaseNotesDC/index.html to check current version
$readerVersion  = "2100120155"
$URL = "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC"

# This is where our Adobe Reader installer will be saved, it is best to save on an SMB share that can be accessed by all workstations
$destinationPath = "\\YOUR-SMB-SERVER\group-policy\readerdc"

# The chosen Language. Adobe doesn't make an en_GB version, so we have to use en_US
$installerExtension = "_en_US.exe"

$readerEXE  = $readerVersion + $installerExtension
$extractLocation = "$destinationPath\$readerVersion\Extract"
$extractProcess = "$destinationPath\$readerVersion\installer.exe"
$extractArgs = "-nos_ne -nos_o$extractLocation"
$msiProcess = "msiexec"
$msiArgsEXE = "/a $destinationPath\$readerVersion\Extract\AcroRead.msi /qb TARGETDIR=$destinationPath\$readerVersion\Install"
$msiArgsMSP = "/a $destinationPath\$readerVersion\Install\AcroRead.msi /qb /p $destinationPath\$readerVersion\updatefile.msp"

$ErrorActionPreference = "Inquire"



#$readerVersion = Read-Host -Prompt 'Please enter the Adobe Reader version (10 digits)'

# END CONFIGURATION

Write-Host "Creating folder for $readerVersion"
New-Item -Path $destinationPath\$readerVersion -ItemType Directory
Write-Host "Folder created"
Write-Host " "

Write-Host "Downloading the exe installer for $readerVersion"
Invoke-WebRequest $URL/$readerVersion/AcroRdrDC$readerEXE -OutFile $destinationPath\$readerVersion\installer.exe
Write-Host "Exe downloaded"
Write-Host " "

Write-Host "Downloading the msp update for $readerVersion"
Invoke-WebRequest "$URL/$readerVersion/AcroRdrDCUpd$readerVersion.msp" -OutFile $destinationPath\$readerVersion\updatefile.msp
Write-Host "Update downloaded"
Write-Host " "

Write-Host "Creating the Extract folder"
New-Item -Path $destinationPath\$readerVersion\Extract -ItemType Directory
Write-Host "Folder created"
Write-Host " "

Write-Host "Extracting the contents of Adobe's exe installer"
Start-Process $extractProcess -ArgumentList $extractArgs -Wait
Write-Host "Contents finished extracting"
Write-Host " "

Write-Host "Creating the Install folder"
New-Item -Path $destinationPath\$readerVersion\Install -ItemType Directory
Write-Host "Folder created"
Write-Host " "

Write-Host "Copying program files to the Install directory"
Start-Process $msiProcess -ArgumentList $msiArgsEXE -Wait
Write-Host "Files finished copying"
Write-Host " "

Write-Host "Copying the setup.ini file"
Copy-Item $destinationPath\$readerVersion\Extract\setup.ini $destinationPath\$readerVersion\Install\setup.ini
Write-Host "File copied"
Write-Host " "

Write-Host "Applying the msp file"
Start-Process $msiProcess -ArgumentList $msiArgsMSP -Wait
Write-Host "msp file applied"
Write-Host " "