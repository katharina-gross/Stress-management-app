# PowerShell скрипт для тестирования WebSocket
$uri = "ws://localhost:8080/ws"

try {
    Write-Host "Попытка подключения к WebSocket: $uri"
    
    # Создаем WebSocket подключение
    $ws = New-Object System.Net.WebSockets.ClientWebSocket
    
    # Подключаемся
    $task = $ws.ConnectAsync($uri, $null)
    $task.Wait()
    
    if ($ws.State -eq "Open") {
        Write-Host "✅ WebSocket подключение успешно установлено!" -ForegroundColor Green
        Write-Host "Состояние: $($ws.State)"
        
        //
        # Закрываем подключение
        $ws.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "Test completed", $null).Wait()
        Write-Host "WebSocket подключение закрыто"
    } else {
        Write-Host "❌ WebSocket подключение не удалось" -ForegroundColor Red
        Write-Host "Состояние: $($ws.State)"
    }
} catch {
    Write-Host "❌ Ошибка при подключении к WebSocket: $($_.Exception.Message)" -ForegroundColor Red
} 