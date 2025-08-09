#!/bin/bash

# Выход при первой ошибке
set -e

PROJECT_DIR="The-Dawn-Bot"
SERVICE_NAME="dawn.service"
SCRIPT_NAME="setup_dawn_bot.sh"

echo "Starting setup script: $SCRIPT_NAME"

# Проверка и переход в директорию проекта
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: Directory '$PROJECT_DIR' not found in current path."
    echo "Please ensure this script is run from the parent directory of '$PROJECT_DIR' (e.g., /root/)."
    exit 1
fi
echo "Navigating to $PROJECT_DIR..."
cd "$PROJECT_DIR"

# Установка виртуального окружения и зависимостей
echo "Setting up Python virtual environment and installing dependencies..."
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
# Проверка существования requirements.txt перед установкой
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
else
    echo "Warning: requirements.txt not found. Skipping dependency installation."
fi

# Перезаписываем auto_farm.py
echo "Overwriting auto_farm.py with new content..."
cat > auto_farm.py << 'EOF'
import asyncio
import sys

from application import ApplicationManager
from utils import setup
from loader import config


def main():
    """Автоматический запуск Dawn Farm без интерактивного меню"""
    if sys.platform == "win32":
        asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

    setup()

    # Принудительно устанавливаем модуль FARM
    config.module = "farm"

    # Создаем экземпляр ApplicationManager
    app = ApplicationManager()

    # Запускаем инициализацию и основной процесс
    asyncio.run(run_farm_only(app))


async def run_farm_only(app: ApplicationManager):
    """Запуск только фарминга без показа меню"""
    await app.initialize()

    # Проверяем, что модуль farm существует
    if config.module not in app.module_map:
        print(f"❌ Модуль {config.module} не найден!")
        return

    # Загружаем прокси и аккаунты для фарминга
    from loader import proxy_manager # <-- ОБРАТИТЕ ВНИМАНИЕ: это та строка, которая может вызвать ImportError!
    proxy_manager.load_proxy(config.proxies)

    accounts, process_func = app.module_map[config.module]

    if not accounts:
        print("❌ Нет аккаунтов для фарминга!")
        return

    print(f"🌾 Запуск автоматического фарминга для {len(accounts)} аккаунтов...")

    # Запускаем бесконечный фарминг
    await app._farm_continuously(accounts)


if __name__ == "__main__":
    main()
EOF

# Делаем auto_farm.py исполняемым
echo "Making auto_farm.py executable..."
chmod +x auto_farm.py

# Создаем/обновляем системный сервис systemd
echo "Creating/updating systemd service file: $SERVICE_NAME..."
sudo tee "/etc/systemd/system/$SERVICE_NAME" > /dev/null << EOF
[Unit]
Description=Dawn Farm Bot - Auto Mode
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
User=root
WorkingDirectory=/root/The-Dawn-Bot
ExecStart=/root/The-Dawn-Bot/venv/bin/python /root/The-Dawn-Bot/auto_farm.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
Environment="PYTHONPATH=/root/The-Dawn-Bot"
Environment="PYTHONUNBUFFERED=1"

[Install]
WantedBy=multi-user.target
EOF

# Перечитываем конфиги systemd, включаем и перезапускаем сервис
echo "Reloading systemd daemon, enabling and restarting service..."
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl restart "$SERVICE_NAME"

# Деактивация виртуального окружения для текущей оболочки скрипта
deactivate &>/dev/null || true

echo "Setup complete. Service '$SERVICE_NAME' has been restarted."
echo "To check its status and logs, run: sudo journalctl -u $SERVICE_NAME -f"
