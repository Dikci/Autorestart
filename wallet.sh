#!/bin/bash

# Путь к файлу конфигурации
CONFIG_FILE="/root/drosera/drosera.toml"

# Проверка существования файла
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Ошибка: файл $CONFIG_FILE не найден!"
    exit 1
fi

# Создаем временный файл
TMP_ENV=$(mktemp)

# Копируем существующий environment (исключая старые определения)
[ -f "/etc/environment" ] && grep -vE '^(TRAP|HOLESKY)=' /etc/environment > "$TMP_ENV"

# Функция для извлечения значений из TOML
extract_value() {
    key=$1
    grep "^${key} =" "$CONFIG_FILE" | cut -d= -f2- | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//"
}

# Извлекаем и добавляем TRAP (address)
TRAP_VALUE=$(extract_value "address")
if [ -n "$TRAP_VALUE" ]; then
    echo "TRAP=\"$TRAP_VALUE\"" >> "$TMP_ENV"
    echo "Добавлено: TRAP=\"$TRAP_VALUE\""
else
    echo "Предупреждение: address не найден в конфиге"
fi

# Извлекаем и добавляем HOLESKY (ethereum_rpc)
HOLESKY_VALUE=$(extract_value "ethereum_rpc")
if [ -n "$HOLESKY_VALUE" ]; then
    echo "HOLESKY=\"$HOLESKY_VALUE\"" >> "$TMP_ENV"
    echo "Добавлено: HOLESKY=\"$HOLESKY_VALUE\""
else
    echo "Предупреждение: ethereum_rpc не найден в конфиге"
fi

# Применяем изменения
sudo mv "$TMP_ENV" /etc/environment
sudo chmod 644 /etc/environment

echo "Изменения применены к /etc/environment"
echo "Для применения может потребоваться перезагрузка"
