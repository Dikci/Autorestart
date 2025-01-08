#!/bin/bash

# Зацикливаем выполнение скрипта
while true; do
    # Перейти в нужную директорию
    cd ~/multipleforlinux

    # Проверка статуса
    status_output=$(./multiple-cli status)

    # Проверка наличия слов "Node Statistical"
    if [[ $status_output != *"Node Statistical"* ]]; then
        # Перезапуск
        nohup ./multiple-node > output.log 2>&1 &
        echo "Сервис был перезапущен."
    else
        echo "Все в порядке, сервис работает."
    fi

    # Подождать некоторое время перед следующей проверкой
    sleep 5000
done
