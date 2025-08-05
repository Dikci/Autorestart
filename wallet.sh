#!/bin/bash

# Путь к файлу .env
ENV_FILE="/root/aztec-sequencer/.env"

# Проверка файла
if [ ! -f "$ENV_FILE" ]; then
    echo "Ошибка: файл $ENV_FILE не найден!"
    exit 1
fi

# Извлекаем значение WALLET и сохраняем как EVM
EVM_VALUE=$(grep '^WALLET=' "$ENV_FILE" | cut -d= -f2- | sed 's/^["'\'']//; s/["'\'']$//')

if [ -z "$EVM_VALUE" ]; then
    echo "Ошибка: переменная WALLET не найдена в исходном файле"
    exit 1
fi

# Создаем временный файл
TMP_ENV=$(mktemp)

# Копируем существующий environment (исключая старые EVM)
[ -f "/etc/environment" ] && grep -v '^EVM=' /etc/environment > "$TMP_ENV"

# Добавляем новое значение
echo "EVM=\"$EVM_VALUE\"" >> "$TMP_ENV"

# Применяем изменения
sudo mv "$TMP_ENV" /etc/environment
sudo chmod 644 /etc/environment

echo "Успешно! Переменная EVM добавлена:"
echo "EVM=\"$EVM_VALUE\""
echo "Перезагрузите систему для применения изменений."
