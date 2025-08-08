#!/bin/bash

ENV_FILE="/etc/environment"

# Подгружаем переменные из /etc/environment
set -a
source $ENV_FILE
set +a

# Формируем новую переменную HOODI
HOODI="${HOLESKY//eth_holesky/eth_hoodi}"

# Проверяем, есть ли HOODI в файле
if grep -q "^HOODI=" "$ENV_FILE"; then
    # Обновляем строку с HOODI
    sudo sed -i "s|^HOODI=.*|HOODI=\"$HOODI\"|" "$ENV_FILE"
else
    # Добавляем новую переменную HOODI в конец файла
    echo "HOODI=\"$HOODI\"" | sudo tee -a "$ENV_FILE" > /dev/null
fi

echo "Переменная HOODI обновлена в $ENV_FILE:"
grep "^HOODI=" "$ENV_FILE"
