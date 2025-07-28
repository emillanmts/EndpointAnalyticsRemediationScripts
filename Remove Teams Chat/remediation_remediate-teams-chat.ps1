<#
Version: 1.0
Author: 
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
Script: remediate-teams-chat.ps1
Description: Removes Teams Chat (fully)
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: User
Context: 64 Bit
#> 

#Remove Teams Chat
$MSTeams = "MicrosoftTeams"

$WinPackage = Get-AppxPackage -allusers | Where-Object {$_.Name -eq $MSTeams}
$ProvisionedPackage = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $WinPackage.Name }
If ($null -ne $WinPackage) 
{
    Remove-AppxPackage  -Package $WinPackage.PackageFullName
} 

If ($null -ne $ProvisionedPackage) 
{
    Remove-AppxProvisionedPackage -online -Packagename $ProvisionedPackage.Packagename
}

##Tweak reg permissions
invoke-webrequest -uri "https://github.com/andrew-s-taylor/public/raw/main/De-Bloat/SetACL.exe" -outfile "C:\Windows\Temp\SetACL.exe"
C:\Windows\Temp\SetACL.exe -on "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications" -ot reg -actn setowner -ownr "n:administrators"
 C:\Windows\Temp\SetACL.exe -on "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications" -ot reg -actn ace -ace "n:administrators;p:full"
Remove-Item C:\Windows\Temp\SetACL.exe -recurse


##Stop it coming back
$registryPath = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications"
If (!(Test-Path $registryPath)) { 
    New-Item $registryPath
}
Set-ItemProperty $registryPath ConfigureChatAutoInstall -Value 0


##Unpin it
$registryPath = "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Chat"
If (!(Test-Path $registryPath)) { 
    New-Item $registryPath
}
Set-ItemProperty $registryPath "ChatIcon" -Value 2
write-host "Removed Teams Chat"
