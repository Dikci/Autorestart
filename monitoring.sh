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

# Функция для проверки и перезапуска сервиса
function check_and_restart_service() {
    local service_name=$1
    service_status=$(systemctl is-active "$service_name")

    # Если статус не active, выполняем перезапуск
    if [ "$service_status" != "active" ]; then
        echo "Сервис $service_name не работает (статус: $service_status). Выполняется перезапуск..."
        systemctl restart "$service_name"
        if [ $? -eq 0 ]; then
            echo "Сервис $service_name успешно перезапущен."
        else
            echo "Ошибка при перезапуске сервиса $service_name."
        fi
    else
        echo "Сервис $service_name работает корректно (статус: $service_status)."
    fi
}

# Функция для проверки порта 8080
function check_and_restart_node_on_port() {
    lsof_output=$(sudo lsof -i :8080)

    # Проверка, содержится ли слово "node" в выводе
    if [[ ! "$lsof_output" =~ "node" ]]; then
        echo "Слово 'node' не найдено в выводе команды lsof. Выполняется остановка и запуск..."

        # Остановка node
        cd ~/ubuntu-node || { echo "Не удалось перейти в каталог ubuntu-node"; return; }
        sudo bash manager.sh down

        # Запуск node
        sudo bash manager.sh up
        echo "Процесс node перезапущен."
    else
        echo "Слово 'node' найдено в выводе команды lsof. Статус порта 8080 корректен."
    fi
}

# Функция для проверки наличия сессии tmux с именем "rivalz"
function check_and_create_tmux_session_rivalz() {
    tmux_sessions=$(tmux ls 2>/dev/null)

    # Проверяем, есть ли сессия с именем "rivalz"
    if [[ "$tmux_sessions" != *"rivalz"* ]]; then
        echo "Сессия tmux с именем 'rivalz' не найдена. Создаю новую сессию..."
        tmux new-session -d -s rivalz 'rivalz run'
        echo "Сессия tmux с именем 'rivalz' успешно создана."
    else
        echo "Сессия tmux с именем 'rivalz' уже существует."
    fi
}

# Функция для проверки наличия сессии tmux с именем "cysic"
function check_and_create_tmux_session_cysic() {
    tmux_sessions=$(tmux ls 2>/dev/null)

    # Проверяем, есть ли сессия с именем "cysic"
    if [[ "$tmux_sessions" != *"cysic"* ]]; then
        echo "Сессия tmux с именем 'cysic' не найдена. Создаю новую сессию..."
        tmux new-session -d -s cysic 'cd ~/cysic-verifier/ && bash start.sh'
        echo "Сессия tmux с именем 'cysic' успешно создана."
    else
        echo "Сессия tmux с именем 'cysic' уже существует."
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
    "hubble-hubble-1"
    "hubble-grafana-1"
    "fizz-fizz-1"
)

# Список сервисов для проверки
services=(
    "sonaricd.service"
    "docker.service"
    "blockmesh.service"
)

# Бесконечный цикл проверки
while true; do
    # Проверка статуса контейнеров
    echo "Проверка статуса контейнеров..."
    for container in "${containers[@]}"; do
        check_and_restart_container "$container"
    done

    # Проверка статуса сервисов
    echo "Проверка статуса сервисов..."
    for service in "${services[@]}"; do
        check_and_restart_service "$service"
    done

    # Проверка порта 8080 на наличие процесса node
    echo "Проверка порта 8080 на наличие процесса node..."
    check_and_restart_node_on_port

    # Проверка наличия сессии tmux с именем "rivalz"
    echo "Проверка наличия сессии tmux 'rivalz'..."
    check_and_create_tmux_session_rivalz

    # Проверка наличия сессии tmux с именем "cysic"
    echo "Проверка наличия сессии tmux 'cysic'..."
    check_and_create_tmux_session_cysic

    echo "Ожидание перед следующей проверкой..."
    sleep 5000s # Интервал между проверками (можно изменить)
done
