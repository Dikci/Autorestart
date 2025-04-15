#!/bin/bash

# === Лог-файл ===
LOG_FILE="/var/log/monitoring.log"
LAST_CLEAR_FILE="/tmp/last_log_clear"  # Файл для хранения времени последней очистки

# === Функция логирования ===
log() {
    local message="$1"
    echo "[$(date)] $message" | tee -a "$LOG_FILE"
}

# === Очистка лог-файла раз в сутки ===
clear_log_daily() {
    local now
    now=$(date +%s)

    if [[ -f "$LAST_CLEAR_FILE" ]]; then
        local last_clear
        last_clear=$(cat "$LAST_CLEAR_FILE")
    else
        local last_clear=0
    fi

    # Проверяем, прошло ли 24 часа (86400 секунд) с последней очистки
    if (( now - last_clear >= 86400 )); then
        log "🧹 Очистка лог-файла $LOG_FILE..."
        > "$LOG_FILE"
        echo "$now" > "$LAST_CLEAR_FILE"
        log "✅ Лог-файл очищен."
    fi
}

# === Проверка и создание tmux-сессии Pipe ===
log "🔍 Проверка Pipe..."
check_and_create_tmux_session_Pipe() {
    if ! tmux has-session -t Pipe 2>/dev/null; then
        log "⚠️Сессия tmux 'pipe не найдена. Создаю новую..."
        tmux new-session -d -s pipe './pop'
        log "✅Сессия tmux 'pipe' успешно создана."
    else
        log "✅Сессия tmux 'pipe' уже работает."
    fi
}

# === Проверка и создание tmux-сессии dria ===
log "🔍 Проверка dria..."
check_and_create_tmux_session_dria() {
    if ! tmux has-session -t dria 2>/dev/null; then
        log "⚠️Сессия tmux 'dria не найдена. Создаю новую..."
        tmux new-session -d -s dria "dkn-compute-launcher start; bash"
        log "✅Сессия tmux 'dria' успешно создана."
    else
        log "✅Сессия tmux 'dria' уже работает."
    fi
}


# === Проверка и перезапуск multiple-node ===
log "🔍 Проверка Multiple..."
check_multiple_status() {
    cd ~/multipleforlinux || { log "❌Ошибка: не удалось перейти в ~/multipleforlinux"; return; }

    local status_output
    status_output=$(timeout 60s ./multiple-cli status)

    if [[ $? -eq 124 ]]; then
        log "❌Ошибка: multiple-cli status не завершился за 60 сек."
        return
    fi

    if [[ $status_output != *"Node Statistical"* ]]; then
        log "⚠️multiple-node не работает. Перезапускаю..."
        nohup ./multiple-node > output.log 2>&1 &
        log "✅multiple-node был успешно запущен."
    else
        log "✅multiple-node работает нормально."
    fi
}

# === Проверка, запуск Docker и перезапуск остановленных контейнеров ===
check_docker_containers() {
    log "🔍 Проверка Docker-демона..."
    
    if ! systemctl is-active --quiet docker; then
        log "⚠️ Docker-демон не работает. Запускаю..."
        systemctl start docker
        sleep 5  # Даем Docker время на запуск
        if ! systemctl is-active --quiet docker; then
            log "❌ Ошибка: не удалось запустить Docker-демон!"
            return
        fi
        log "✅ Docker-демон успешно запущен."
    fi

    log "🔍 Проверка Docker-контейнеров..."
    local non_up_containers
    non_up_containers=$(docker ps -a --filter "status=exited" --filter "status=created" --filter "status=paused" --format "{{.ID}} {{.Names}}")

    if [[ -n "$non_up_containers" ]]; then
        log "⚠️ Обнаружены остановленные контейнеры:"
        echo "$non_up_containers" | awk '{print $2}' | tee -a "$LOG_FILE"

        while IFS= read -r container; do
            local container_id container_name
            container_id=$(echo "$container" | awk '{print $1}')
            container_name=$(echo "$container" | awk '{print $2}')
            log "🔄 Перезапуск контейнера: $container_name..."
            docker restart "$container_id" >> "$LOG_FILE" 2>&1
            log "✅ Контейнер '$container_name' успешно перезапущен."
        done <<< "$non_up_containers"
    else
        log "✅ Все контейнеры работают."
    fi
}

# === Проверка и перезапуск всех неактивных systemd-сервисов ===
check_services() {
    log "🔍 Проверка systemd-сервисов..."
    
    local services
    services=$(systemctl list-units --type=service --state=failed --no-pager --no-legend | awk '{print $1}' | grep -v '^●')

    if [[ -z "$services" ]]; then
        log "✅ Все сервисы работают нормально."
        return
    fi

    log "⚠️ Обнаружены неактивные сервисы:"
    log "$services"

    while read -r service; do
        [[ -z "$service" ]] && continue
        log "🔄 Перезапуск сервиса: $service..."
        systemctl restart "$service" >> "$LOG_FILE" 2>&1

        local new_status
        new_status=$(systemctl is-active "$service")
        if [[ "$new_status" == "active" ]]; then
            log "✅ Сервис '$service' успешно перезапущен."
        else
            log "❌ Ошибка: сервис '$service' не удалось запустить (новый статус: $new_status)."
        fi
    done <<< "$services"
}

# === Основной цикл ===
while true; do
    log "🟢 Начало новой проверки..."
    
    clear_log_daily
    check_and_create_tmux_session_Pipe
    check_and_create_tmux_session_dria
    check_multiple_status
    check_docker_containers
    check_services

    log "✅ Проверка завершена. Ожидание перед следующей проверкой..."
    sleep 250
done
