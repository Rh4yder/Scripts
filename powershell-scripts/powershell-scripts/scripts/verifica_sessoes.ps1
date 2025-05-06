<#
.SYNOPSIS
    Verifica em que servidores Windows um utilizador está com sessão iniciada.

.DESCRIPTION
    Este script consulta o Active Directory para obter uma lista de servidores Windows ativos (últimos 90 dias),
    verifica quais estão online, e para cada servidor, verifica se um utilizador específico tem sessão iniciada.

.PARAMETER utilizadorEsperado
    O nome de utilizador a verificar (por exemplo: adm_xux4415).

.OUTPUTS
    - Servidores_ligados.txt: lista de servidores acessíveis.
    - Lista_Servidores.txt: lista de servidores consultados.
    - Servidores_Com_Utilizador.csv: servidores onde o utilizador está ligado com os restantes utilizadores.

.NOTES
    Requer permissões de leitura no Active Directory e acesso de rede aos servidores remotos.
#>

# Configuração
$utilizadorEsperado = "adm_xux4415"
$diretorio = "C:\temp"
$fichPing = "$diretorio\Servidores_ligados.txt"
$fichLista = "$diretorio\Lista_Servidores.txt"
$fichCSV   = "$diretorio\Servidores_Com_Utilizador.csv"

# Criar pasta de destino se não existir
if (-not (Test-Path $diretorio)) {
    New-Item -ItemType Directory -Path $diretorio | Out-Null
}

# Inicializar ficheiros
"" | Out-File -FilePath $fichPing -Force
"" | Out-File -FilePath $fichCSV -Force

# Data de referência (últimos 90 dias)
$dataLimite = [DateTime]::Today.AddDays(-90)

# Obter servidores do AD
$servidores = Get-ADComputer -Filter 'OperatingSystem -like "Windows server*" -and lastLogondate -ge $dataLimite' `
    | Where-Object { $_.Name -match '^[VS]' } `
    | Sort-Object Name | Select-Object -ExpandProperty Name

# Guardar lista de servidores
$servidores | Out-File -FilePath $fichLista -Force

# Verificar sessões ativas
foreach ($servidor in $servidores) {
    $servidor = $servidor.Trim()

    if (Test-Connection -ComputerName $servidor -Count 2 -Quiet) {
        Write-Host "$servidor está ligado" -ForegroundColor Green
        Add-Content -Path $fichPing -Value $servidor

        try {
            $linhas = @(query user /server:$servidor) -split "`n"
        } catch {
            Write-Host "Erro ao consultar sessões no servidor $servidor" -ForegroundColor Yellow
            continue
        }

        $utilizadoresLigados = @()

        foreach ($linha in $linhas) {
            if ($linha -match "USERNAME\s+SESSIONNAME\s+ID\s+STATE\s+IDLE TIME\s+LOGON TIME") { continue }
            $partes = $linha -split '\s+'
            if ($partes.Count -ge 2) {
                $utilizadoresLigados += $partes[1]
            }
        }

        if ($utilizadoresLigados -contains $utilizadorEsperado) {
            Write-Host "$servidor -> $utilizadorEsperado está ligado (junto com outros)" -ForegroundColor Cyan
            "$servidor," + ($utilizadoresLigados -join ";") | Out-File -Append -FilePath $fichCSV
        }
    } else {
        Write-Host "$servidor está desligado ou inacessível" -ForegroundColor Red
    }
}