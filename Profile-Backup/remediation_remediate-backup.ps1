<#
Version: 1.0
Author: 
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: remediate-backup.ps1
Description: Downloads custom backup script and deploys to backup user profile to OneDrive
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: User
Context: 64 Bit
#> 
$DirectoryToCreate = $env:APPDATA + "\backup-restore"
if (-not (Test-Path -LiteralPath $DirectoryToCreate)) {
    
    try {
        New-Item -Path $DirectoryToCreate -ItemType Directory -ErrorAction Stop | Out-Null #-Force
    }
    catch {
        Write-Error -Message "Unable to create directory '$DirectoryToCreate'. Error was: $_" -ErrorAction Stop
    }
    "Successfully created directory '$DirectoryToCreate'."

}
else {
    "Directory already existed"
}

##Download Backup Script
$backupurl="https://raw.githubusercontent.com/andrew-s-taylor/public/main/Batch%20Scripts/backup.bat"
$backupscript = $DirectoryToCreate + "\backup.bat"
if (-not (Test-Path -LiteralPath $backupscript)) {
Invoke-WebRequest -Uri $backupurl -OutFile $backupscript -UseBasicParsing
}
##Download Restore Script
$restoreurl="https://raw.githubusercontent.com/andrew-s-taylor/public/main/Batch%20Scripts/NEWrestore.bat"
$restorescript = $DirectoryToCreate + "\restore.bat"
if (-not (Test-Path -LiteralPath $restorescript)) {
Invoke-WebRequest -Uri $restoreurl -OutFile $restorescript -UseBasicParsing
}

##Download Silent Launch Script
$launchurl="https://raw.githubusercontent.com/andrew-s-taylor/public/main/Batch%20Scripts/run-invisible.vbs"
$launchscript = $DirectoryToCreate + "\run-invisible.vbs"
if (-not (Test-Path -LiteralPath $launchscript)) {
Invoke-WebRequest -Uri $launchurl -OutFile $launchscript -UseBasicParsing
}

##Run it
$acommand = "C:\Windows\System32\Cscript.exe $DirectoryToCreate\run-invisible.vbs"

Invoke-Expression $acommand

##Create/Update txt for detection
$todaysdate = Get-Date -Format "dd-MM-yyyy-HH"
$detection = $DirectoryToCreate + "\backup.txt"
if (-not (Test-Path -LiteralPath $detection)) {
    New-Item -Path $detection -ItemType File -Force
    Add-Content -Path $detection -Value $todaysdate
}
else {
    set-Content -Path $detection -Value $todaysdate
    }
    
