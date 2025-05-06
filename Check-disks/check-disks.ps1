<#
DISCLAIMER:
Este script é fornecido "tal como está", sem garantias. Foi desenvolvido para fins informativos e administrativos internos.
Utilize por sua conta e risco. Teste sempre antes de aplicar em ambientes de produção.
#>

# Obter o nome do host
$hostname = $env:COMPUTERNAME
Write-Host "Nome do host: $hostname"
Write-Host ""

# Obter informações sobre discos físicos
Write-Host "Informações sobre discos físicos:"
$physicalDisks = Get-PhysicalDisk
foreach ($disk in $physicalDisks) {
    Write-Host "Nome do disco: $($disk.DeviceID)"
    Write-Host "Status: $($disk.HealthStatus)"
    Write-Host "Tamanho total: $($disk.Size) bytes"
    Write-Host "Fabricante: $($disk.Manufacturer)"
    Write-Host ""
}

# Obter informações sobre discos virtuais
Write-Host "Informações sobre discos virtuais:"
$virtualDisks = Get-VirtualDisk
foreach ($disk in $virtualDisks) {
    Write-Host "Nome do disco: $($disk.FriendlyName)"
    Write-Host "Status: $($disk.HealthStatus)"
    Write-Host "Tamanho total: $($disk.Size) bytes"
    Write-Host ""
}
