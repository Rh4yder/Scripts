# PowerShell Scripts

Coleção de scripts PowerShell úteis para administração de sistemas Windows.

## 📂 Scripts

### `verifica_sessoes.ps1`

Este script verifica em que servidores Windows (cujo nome começa por "V" ou "S") um utilizador especificado tem sessão iniciada.

#### 🔍 Funcionalidade:
- Filtra servidores ativos no Active Directory (últimos 90 dias).
- Testa conectividade a cada servidor.
- Executa `query user` remotamente.
- Verifica se o utilizador está com sessão iniciada.
- Gera relatórios em:
  - `Servidores_ligados.txt` — servidores acessíveis.
  - `Lista_Servidores.txt` — lista total de servidores encontrados.
  - `Servidores_Com_Utilizador.csv` — sessões onde o utilizador está presente.

#### 🛠️ Requisitos:
- Acesso ao Active Directory.
- Permissões de execução remota.
- PowerShell com acesso a `Get-ADComputer` (RSAT).

---

💡 Para adaptar o script, basta alterar a variável `$utilizadorEsperado` no topo do ficheiro.