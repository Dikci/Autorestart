#!/bin/bash

# Путь к файлу .env
ENV_FILE="/root/aztec-sequencer/.env"

# Проверка существования файла
if [ ! -f "$ENV_FILE" ]; then
    echo "Ошибка: файл $ENV_FILE не найден!"
    exit 1
fi

# Извлекаем значение VALIDATOR_PRIVATE_KEY (удаляем 0x в начале если есть)
PRIVEVM_VALUE=$(grep '^VALIDATOR_PRIVATE_KEY=' "$ENV_FILE" | cut -d= -f2- | sed 's/^0x//' | tr -d '"'"'")

# Проверяем что значение не пустое
if [ -z "$PRIVEVM_VALUE" ]; then
    echo "Ошибка: VALIDATOR_PRIVATE_KEY не найдена или пуста"
    exit 1
fi

# Создаем временный файл
TMP_ENV=$(mktemp)

# Копируем существующий environment (исключая старые PRIVEVM)
[ -f "/etc/environment" ] && grep -v '^PRIVEVM=' /etc/environment > "$TMP_ENV"

# Добавляем новое значение
echo "PRIVEVM=\"$PRIVEVM_VALUE\"" >> "$TMP_ENV"

# Применяем изменения
sudo mv "$TMP_ENV" /etc/environment
sudo chmod 644 /etc/environment

echo "Успешно! Переменная PRIVEVM добавлена в /etc/environment"
echo "Значение: PRIVEVM=\"$PRIVEVM_VALUE\""
echo "Для применения изменений может потребоваться перезагрузка."
