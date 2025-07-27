# Força UTF-8 no console
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8

# Trava em erro
$ErrorActionPreference = 'Stop'

# Nome da extensão (uso HÍFEN ASCII normal)
$extensionName = 'taquion-vscode'

# --- 1) Limpa .vsix antigos ---
Write-Host '========================================'
Write-Host ' Removendo arquivos .vsix antigos...'
Write-Host '========================================'
Write-Host ''

try {
    Get-ChildItem -Path "$extensionName-*.vsix" -ErrorAction SilentlyContinue |
      Remove-Item -Force
    Write-Host '✅ Arquivos antigos removidos (se existiam).' -ForegroundColor Green
}
catch {
    Write-Host '❌ Falha ao remover .vsix antigos:' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Read-Host 'Pressione Enter para sair...'
    exit
}

# --- 2) Empacota nova versão ---
Write-Host ''
Write-Host '========================================'
Write-Host ' Empacotando nova versão da extensão...'
Write-Host '========================================'
Write-Host ''

try {
    vsce package
    $vsixFile = Get-ChildItem -Path "$extensionName-*.vsix" |
                Sort-Object LastWriteTime -Descending |
                Select-Object -First 1

    if (-not $vsixFile) {
        throw 'Nenhum .vsix encontrado após o package.'
    }

    Write-Host "✅ Pacote criado: $($vsixFile.Name)" -ForegroundColor Green
}
catch {
    Write-Host '❌ Erro ao empacotar:' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Read-Host 'Pressione Enter para sair...'
    exit
}

# --- 3) Instala extensão no VS Code ---
Write-Host ''
Write-Host '========================================'
Write-Host ' Instalando extensão no VS Code...'
Write-Host '========================================'
Write-Host ''

try {
    code --install-extension $vsixFile.FullName --force
    Write-Host '✅ Extensão instalada com sucesso.' -ForegroundColor Green
}
catch {
    Write-Host '❌ Erro na instalação:' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Read-Host 'Pressione Enter para sair...'
    exit
}

Write-Host ''
Read-Host 'Pressione Enter para finalizar...'
