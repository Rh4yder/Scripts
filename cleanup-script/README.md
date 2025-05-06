# PowerShell Script: Limpeza de Disco C:\

Este script executa uma limpeza abrangente em sistemas Windows, removendo ficheiros temporários, caches de browsers e logs antigos. Também permite analisar e arquivar logs de segurança antigos.

## ⚠️ Aviso de Segurança

**Este script remove ficheiros potencialmente importantes. Use por sua conta e risco.**
- Teste sempre em ambiente controlado.
- Certifique-se de que compreende as ações de cada comando antes de executar em produção.

## 📋 Funcionalidades
- Limpa pastas: Downloads, Temp, Cache, WebCache, etc.
- Liberta espaço em disco.
- Verifica espaço antes/depois.
- Identifica tamanho dos logs EVT e oferece opção de arquivar.

## 🔧 Requisitos
- PowerShell com permissões de administrador.
- Opcional: Software de backup (Tivoli TSM) se desejar arquivar logs automaticamente.

---

🛠️ Personalize os caminhos se necessário para o seu ambiente.