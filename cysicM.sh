#!/bin/bash

cd ~/cysic-verifier/

while true; do
    echo "Запускаю ноду..."
    
    # Запускаем ноду и сохраняем лог в переменную
    LOG=$(bash start.sh 2>&1)

    echo "$LOG"

    # Проверка на ключевую фразу ошибки
    if echo "$LOG" | grep -q "repeated read on failed websocket connection"; then
        echo "Найдена ошибка! Перезапуск через 3 секунды..."
        sleep 3
    else
        echo "Нода завершилась без целевой ошибки. Останавливаемся."
        break
    fi
done
