#!/bin/bash

# Загружаем системные переменные окружения
source /etc/environment

# Проверка, что PRIVEVM загружен
if [[ -z "$PRIVEVM" ]]; then
  echo "❌ Ошибка: переменная PRIVEVM не найдена в /etc/environment"
  exit 1
fi

# === НАСТРОЙКИ ===
# Количество транзакций в день (от 5 до 10)
TX_COUNT=$((5 + RANDOM % 6))

# RPC provider
RPC_PROVIDER="https://0xrpc.io/sep"

# === ЛОГИКА ===
echo "Запускаю $TX_COUNT транзакций в течение дня..."
echo "Используется ключ из /etc/environment"

for ((i=1; i<=TX_COUNT; i++)); do
    # Случайная задержка между транзакциями: от 30 мин до 2 часов
    DELAY=$((1800 + RANDOM % 5400))
    echo "[$(date '+%H:%M:%S')] Транзакция $i/$TX_COUNT — ожидание $DELAY сек..."
    sleep $DELAY

    # Отправляем транзакцию
    echo "[$(date '+%H:%M:%S')] Отправляю транзакцию #$i..."
    irys upload rpc.sh \
      -n devnet \
      -t ethereum \
      -w "$PRIVEVM" \
      --tags rpc.sh rpc.sh \
      --provider-url "$RPC_PROVIDER"

    echo "[$(date '+%H:%M:%S')] Транзакция #$i завершена."
done

echo "✅ Все $TX_COUNT транзакций за день выполнены!"
