#!/bin/bash

# Проверяем права
if [ "$EUID" -ne 0 ]; then
  echo "❌ Пожалуйста, запустите скрипт от root (sudo)."
  exit 1
fi

# Список переменных (без TITAN и CONSENSUS)
VARS=("TRAP" "EVM" "PRIVEVM" "DATAGRAM" "ID")

# Создаем временный файл
TMP_FILE=$(mktemp)

# Копируем текущее содержимое /etc/environment во временный файл
cp /etc/environment "$TMP_FILE"

echo "Введите значения переменных (оставьте пустым, чтобы пропустить):"

for VAR in "${VARS[@]}"; do
  read -p "$VAR=" VALUE

  # Если значение не пустое — обновляем или добавляем
  if [ -n "$VALUE" ]; then
    # Если переменная уже есть — заменяем строку
    if grep -q "^$VAR=" "$TMP_FILE"; then
      sed -i "s|^$VAR=.*|$VAR=\"$VALUE\"|" "$TMP_FILE"
    else
      echo "$VAR=\"$VALUE\"" >> "$TMP_FILE"
    fi
  fi
done

# Переносим изменения обратно
cp "$TMP_FILE" /etc/environment
rm "$TMP_FILE"

echo "✅ Переменные успешно добавлены/обновлены в /etc/environment"

# Cкачиваем пакеты нужные
apt install nano -y && apt install tmux -y && . <(wget -qO- https://raw.githubusercontent.com/g7AzaZLO/server_primary_setting/refs/heads/main/server_primary_setting.sh)
echo -e "${GREEN}Установка зависимостей...${NC}"
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install -y iptables-persistent curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-venv python3-pip curl wget screen git lsof nano unzip iproute2
sudo apt remove -y nodejs npm
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
npm install -g yarn
npm install -g localtunnel
useradd --no-create-home --shell /bin/false node_exporter
cd
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar xvf node_exporter-1.5.0.linux-amd64.tar.gz

# скопируем бинарные файлы в /usr/local/bin
cp node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin
chown node_exporter:node_exporter /usr/local/bin/node_exporter
node_exporter --version
#node_exporter, version 1.5.0 (branch: HEAD, revision: 1b48970ffcf5630534fb00bb0687d73c66d1c959)

# удаляем ненужные файлы
rm -r node_exporter-*

tee /etc/systemd/system/node_exporterd.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF
systemctl daemon-reload
systemctl enable node_exporterd
systemctl restart node_exporterd

# Установка Docker, если не установлен
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker "$USER"
fi

if ! getent group docker > /dev/null; then
  sudo groupadd docker
fi
sudo usermod -aG docker "$USER"

sudo systemctl start docker
sudo chmod 666 /var/run/docker.sock

# Настройка портов
sudo iptables -I INPUT -p tcp --dport 40400 -j ACCEPT
sudo iptables -I INPUT -p udp --dport 40400 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
sudo sh -c "iptables-save > /etc/iptables/rules.v4"

wget --no-cache -q -O docker_main.sh https://raw.githubusercontent.com/noxuspace/cryptofortochka/main/docker/docker_main.sh && sudo chmod +x docker_main.sh && ./docker_main.sh


wget https://raw.githubusercontent.com/Dikci/Autorestart/refs/heads/main/irys.sh && chmod +x irys.sh && ./irys.sh
docker stop nexus && docker rm nexus && docker pull nexusxyz/nexus-cli:latest
tmux new-session -d -s nexus bash -c 'bash -c "set -a; . /etc/environment; set +a; docker stop nexus; docker rm nexus; docker run -it --init --name nexus nexusxyz/nexus-cli:latest start --node-id \$ID; exec bash"'

tmux kill-session -t gensyn
rm -rf gensyn.sh
tmux new-session -d -s gensyn  "bash -c 'wget https://raw.githubusercontent.com/Dikci/Autorestart/refs/heads/main/gensyninstall.sh  && chmod +x gensyninstall.sh && ./gensyninstall.sh; exec bash'"
tmux kill-session -t drosera
rm -rf droseranew.sh
tmux new-session -d -s drosera  "bash -c 'wget https://raw.githubusercontent.com/Dikci/Autorestart/refs/heads/main/droseranew.sh  && chmod +x droseranew.sh && ./droseranew.sh; exec bash'"
tmux new-session -d -s aztec  "bash -c 'wget https://raw.githubusercontent.com/Dikci/Autorestart/refs/heads/main/aztec.sh && chmod +x aztec.sh && ./aztec.sh; exec bash'"
tmux new-session -d -s dria "bash --login -c 'curl -fsSL https://dria.co/launcher | bash && curl -fsSL https://ollama.com/install.sh | sh && echo \"export PATH=\\\"\\\$PATH:/root/.dria/bin\\\"\" | sudo tee -a /etc/profile.d/dria.sh && sudo chmod +x /etc/profile.d/dria.sh && source /etc/profile.d/dria.sh && dkn-compute-launcher start'"
tmux new-session -d -s waku  "bash -c 'rm -rf install.sh && wget https://raw.githubusercontent.com/DOUBLE-TOP/guides/refs/heads/main/waku/install.sh && chmod +x install.sh && ./install.sh; exec bash'"



# Скачиваем скрипт
rm -f /root/Monitoring.sh
wget -q https://raw.githubusercontent.com/Dikci/vps2-3/refs/heads/main/Monitoring.sh -O /root/Monitoring.sh

# Создаем файл юнита
sudo tee /etc/systemd/system/monitoring.service > /dev/null <<'EOF'
[Unit]
Description=Monitoring Script
After=network.target

[Service]
ExecStart=/bin/bash /root/Monitoring.sh
Restart=always
User=root
WorkingDirectory=/root
# Пусть скрипт сам пишет в лог через tee
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target

# Применяем и запускаем сервис
sudo systemctl daemon-reload
sudo systemctl enable monitoring.service
sudo systemctl restart monitoring.service

tmux new-session -d -s datagram "sudo apt update && sudo apt install -y qemu-user-static debootstrap wget curl && sudo mkdir -p ./x86_root && sudo debootstrap --arch=amd64 --foreign jammy ./x86_root http://archive.ubuntu.com/ubuntu && sudo cp /usr/bin/qemu-x86_64-static ./x86_root/usr/bin/ && sudo chroot ./x86_root /bin/bash -c \"/debootstrap/debootstrap --second-stage && apt update && apt install -y curl wget && set -a; . /etc/environment; set +a; wget -q https://github.com/Datagram-Group/datagram-cli-release/releases/latest/download/datagram-cli-x86_64-linux && chmod +x ./datagram-cli-x86_64-linux && ./datagram-cli-x86_64-linux run -- -key \$DATAGRAM\""
