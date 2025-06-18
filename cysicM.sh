#!/bin/bash

cd ~/cysic-verifier/

while true; do
    echo "Запускаю ноду..."
    
    # Запускаем ноду и сразу перенаправляем вывод в лог-файл
    bash start.sh 2>&1 | tee output.log

    # После завершения ноды — анализируем лог
    if grep -q "repeated read on failed websocket connection" output.log; then
        echo "Найдена ошибка в логе! Перезапуск через 3 секунды..."
        sleep 3
    else
        echo "Нода завершилась без целевой ошибки. Останавливаемся."
        break
    fi
done
