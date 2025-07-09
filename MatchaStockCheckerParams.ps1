<#  Matcha-Ping.ps1 — chequeo único + aviso Telegram  #>

param (
    [string]$token  = $env:TELEGRAM_TOKEN,
    [string]$chatID = $env:TELEGRAM_CHATID
)

# 1⟶ Obliga a TLS 1.2 (Telegram lo exige)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 2⟶ Configuración mínima
$uri = 'https://global.ippodo-tea.co.jp/collections/matcha/products/matcha175512'
# $uri = 'https://global.ippodo-tea.co.jp/collections/matcha/products/matcha642402'

# 3⟶ Lógica
try {
    $htmlRaw  = (Invoke-WebRequest -Uri $uri -UseBasicParsing -TimeoutSec 15).Content
    $hayStock = $htmlRaw -match '<span[^>]*?>\s*Add\s+to\s+cart\s*</span>'

    if ($hayStock) {
        Write-Host 'HAY STOCK' -ForegroundColor Green

        # ——— Telegram ping ———
        $mensaje = "¡Hay matcha en stock!`n$uri`n(" + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + ")"

        $body = @{
            chat_id                 = $chatID
            text                    = $mensaje
            disable_web_page_preview = $true
        } | ConvertTo-Json

        $url = "https://api.telegram.org/bot$token/sendMessage"
        Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType 'application/json' | Out-Null

        Write-Host '→ Aviso enviado a Telegram' -ForegroundColor Cyan
    }
    else {
        Write-Host 'SIN STOCK' -ForegroundColor Red
    }
}
catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    Write-Host "Detalles: $($_.Exception.Message)" -ForegroundColor Red
}
