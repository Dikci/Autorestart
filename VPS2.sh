#!/bin/bash

# Функция для проверки и перезапуска контейнера
function check_and_restart_container() {
    local container_name=$1
    container_status=$(docker inspect -f '{{.State.Status}}' "$container_name" 2>/dev/null)

    if [ -z "$container_status" ]; then
        echo "Контейнер $container_name не найден."
    elif [ "$container_status" == "stopped" ] || [ "$container_status" == "exited" ] || [ "$container_status" == "created" ]; then
        echo "Контейнер $container_name имеет статус $container_status. Выполняется перезапуск..."
        docker restart "$container_name"
        if [ $? -eq 0 ]; then
            echo "Контейнер $container_name успешно перезапущен."
        else
            echo "Ошибка при перезапуске контейнера $container_name."
        fi
    else
        echo "Контейнер $container_name в статусе $container_status."
    fi
}

# Список контейнеров для проверки
containers=(
    "brinxai_relay"
    "root-worker-1"
    "hyperlane"
    "elixir-node"
    "nwaku-compose-grafana-1"
    "nwaku-compose-waku-frontend-1"
    "nwaku-compose-postgres-exporter-1"
    "nwaku-compose-postgres-1"
    "docker-watchtower-1"
    "mongodb"
    "ipfs_node"
    "orchestrator"
    "gaianet_chat"
    "unichain-node-op-node-1"
    "unichain-node-execution-client-1"
    "nwaku-compose-prometheus-1"
    "fizz-fizz-1"
)

# Бесконечный цикл проверки
while true; do
    echo "Проверка статуса контейнеров..."
    for container in "${containers[@]}"; do
        check_and_restart_container "$container"
    done
    echo "Ожидание перед следующей проверкой..."
    sleep 5000s # Интервал между проверками (можно изменить)
done
