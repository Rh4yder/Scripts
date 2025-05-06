<#
.SYNOPSIS
    Script de limpeza da drive C:\ em sistemas Windows.

.DESCRIPTION
    Remove ficheiros temporários, caches de browsers, ficheiros de log antigos, etc.
    Também analisa logs EVT e permite arquivamento opcional.

.DISCLAIMER
    ⚠️ Este script remove ficheiros e diretórios sensíveis. Utilize com precaução.
    Recomenda-se testar em ambiente controlado antes de usar em produção.
#>

$t = Get-PSDrive C
$ti = [math]::Round($t.Free/1MB,2)

Set-Location "C:\Users"
$users = Get-ChildItem

foreach ($u in $users){
    Remove-Item -Path (-Join($u,"\Downloads\*")) -Force -Recurse -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path (-Join($u,"\AppData\Local\Microsoft\Internet Explorer\Recovery\High\Active\*")) -Force -Recurse -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path (-Join($u,"\AppData\Local\Microsoft\Terminal Server Client\Cache\*")) -Force -Recurse -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path (-Join($u,"\AppData\Local\Google\Chrome\User Data\Default\Cache\*")) -Force -Recurse -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path (-Join($u,"\AppData\Local\Google\Chrome\User Data\Default\Media Cache\*")) -Force -Recurse -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path (-Join($u,"\AppData\Local\Temp\*")) -Force -Recurse -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path (-Join($u,"\AppData\Local\Microsoft\Windows\Temporary Internet Files\*")) -Force -Recurse -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path (-Join($u,"\AppData\Local\Microsoft\Windows\WebCache\*")) -Force -Recurse -ErrorAction SilentlyContinue -Verbose
}

Set-Location "C:\Documents and Settings" -ErrorAction SilentlyContinue -Verbose
$folders = Get-ChildItem -ErrorAction SilentlyContinue -Verbose
foreach ($f in $folders){
    Remove-Item -Path (-Join($f,"\Local Settings\Temp\*")) -Force -Recurse -ErrorAction SilentlyContinue -Verbose
    Remove-Item -Path (-Join($f,"\Local Settings\Temporary Internet Files\*")) -Force -Recurse -ErrorAction SilentlyContinue -Verbose
}

Remove-Item C:\$"recycle.bin\*" -Force -Recurse -ErrorAction SilentlyContinue -Verbose
Remove-Item C:\Perflogs\* -Force -Recurse -ErrorAction SilentlyContinue -Verbose
Remove-Item C:\WINDOWS\pchealth\ERRORREP\UserDumps\* -Force -Recurse -ErrorAction SilentlyContinue -Verbose
Remove-Item C:\tsm_images\* -Force -Recurse -ErrorAction SilentlyContinue -Verbose

# Optional: Limpeza de CCMCache
Try {
    $resman = New-Object -com "UIResource.UIResourceMgr"
    $cacheInfo = $resman.GetCacheInfo()
    $cacheinfo.GetCacheElements()  | foreach {$cacheInfo.DeleteCacheElement($_.CacheElementID)}
} Catch { Write-Warning "Could not clear CCMCache." }

# Optional: Autolimpeza de WinSxS
Try {
    schtasks.exe /Run /TN "\Microsoft\Windows\Servicing\StartComponentCleanup"
    Write-Verbose "Autocleaning WinSxS"
} Catch { Write-Warning "Could not autoclean WinSxS" }

Stop-Service wuauserv -ErrorAction SilentlyContinue -Verbose
Remove-Item C:\WINDOWS\SoftwareDistribution\DataStore\DataStore.edb -Force -Recurse -ErrorAction SilentlyContinue -Verbose
Remove-Item C:\Windows\SoftwareDistribution\Download\* -Force -Recurse -ErrorAction SilentlyContinue -Verbose
Start-Service wuauserv -ErrorAction SilentlyContinue -Verbose

$t = Get-PSDrive C
$tf = [math]::Round($t.Free/1MB,2)
$tg = [Math]::Round($tf-$ti,2)
$tt = [Math]::Round($t.Free/1Mb + $t.Used/1Mb,2)

Write-Host @("
Initial free space was $ti MB.
Final free space is $tf MB of $tt MB.
(Gained $tg MB)")

$evt = [math]::Round(((Get-ChildItem C:\Windows\System32\winevt -Recurse | Where-Object { $_.Name -match "Archive-Security"} | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB),2)
$evtold = [math]::Round(((Get-ChildItem C:\Windows\System32\winevt -Recurse | Where-Object { $_.Name -match "Archive-Security" -and $_.LastWriteTime -lt (Get-Date).AddDays(-90)} | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB),2)

if ($evt -gt 500){
    Write-Host "You still have $evt MB in EVT logs, $evtold MB older than 90 days. Consider archiving."
}

$arch = Read-Host -Prompt "Archive? [Y/A/N]"

if ($arch.toUpper() -eq "N") {
    Write-Host "Goodbye."
    break
} elseif ($arch.toUpper() -eq "A") {
    Get-ChildItem C:\Windows\System32\winevt\Logs\ | Where-Object { $_.Name -match "Archive-Security" } | select Name >> "c:\filelist.txt"
} elseif ($arch.toUpper() -eq "Y") {
    Get-ChildItem C:\Windows\System32\winevt\Logs\ | Where-Object { $_.Name -match "Archive-Security" -and $_.LastWriteTime -lt (Get-Date).AddDays(-90) } | select Name >> "c:\filelist.txt"
} else {
    Write-Host "No valid option selected."
}

# Parte opcional referente a software de backup Tivoli TSM foi comentada
# if (Test-Path "C:\Program Files\Tivoli\TSM\baclient\" -PathType Container) {
#     $dsmclocation = "C:\Program Files\Tivoli\TSM\baclient\dsmc.exe"
# } elseif (Test-Path "E:\Tivoli\TSM\baclient\" -PathType Container) {
#     $dsmclocation = "E:\Tivoli\TSM\baclient\dsmc.exe"
# } else {
#     $dsmclocation = Read-Host -Prompt "Please enter path to dsmc.exe"
# }

# Set-Location "C:\Windows\System32\winevt\Logs\"
# Start-Process $dsmclocation -ArgumentList "archive -filelist=c:\filelist.txt -deletefiles -archmc=EVTLOG"
# Wait-Process dsmc
# Remove-Item "c:\filelist.txt"

$t = Get-PSDrive C
$tf = [math]::Round($t.Free/1MB,2)
$tg = [Math]::Round($tf-$ti,2)
$tt = [Math]::Round($t.Free/1Mb + $t.Used/1Mb,2)

Write-Host @("
After Archiving:
Initial free space was $ti MB.
Final free space is $tf MB of $tt MB.
(Gained $tg MB)")

Read-Host