#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "Устанавливаем софт (временной диапазон ожидания ~5-20 min.)"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
sudo apt install iptables jq gcc automake autoconf nvme-cli libgbm1 pkg-config libleveldb-dev tar bsdmainutils libleveldb-dev -y &>/dev/null
echo "Dependencies установлены"

[ -f /root/.profile ] || touch /root/.profile

echo "Ставим Drosera CLI"
curl -s -L https://app.drosera.io/install | bash > /dev/null 2>&1
echo 'export PATH="$PATH:/root/.drosera/bin"' >> /root/.profile
echo 'export PATH="/root/.drosera/bin:$PATH"' >> /root/.bashrc
source /root/.profile
source /root/.bashrc
export PATH="$PATH:/root/.drosera/bin"
droseraup &>/dev/null

echo "Ставим Foundry CLI"
curl -s -L https://foundry.paradigm.xyz | bash &>/dev/null
echo 'export PATH="$PATH:/root/.foundry/bin"' >> /root/.profile
source /root/.profile
foundryup &>/dev/null

curl -fsSL https://bun.sh/install | bash &>/dev/null
echo 'export BUN_INSTALL="$HOME/.bun"' >> /root/.profile
echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> /root/.profile
source /root/.profile
export PATH="$PATH:$HOME/.bun/bin"

echo "Создаем и компилируем Trap"
mkdir -p drosera
cd drosera
forge init -t drosera-network/trap-foundry-template &>/dev/null
bun install &>/dev/null
source /root/.bashrc
forge build &>/dev/null

# Загружаем переменные из окружения
source /etc/environment

# Используем уже существующие переменные
pubkey="$EVM"
privkey="$PRIVEVM"
existing_trap="$TRAP"

if [ -n "$existing_trap" ]; then
    trap_addr="$existing_trap"
    echo "Вписали $existing_trap в файл drosera.toml"
    echo "address = \"$existing_trap\"" >> drosera.toml
else
    trap_addr="NEW_TRAP"
    echo "Созадаем новую трапу."
fi

# RPC всегда публичный — не спрашиваем у пользователя
new_rpc="https://ethereum-hoodi-rpc.publicnode.com"

config_file=~/drosera/drosera.toml
sed -i "s|^ethereum_rpc = \".*\"|ethereum_rpc = \"$new_rpc\"|" "$config_file"
sed -i "s|^block_sample_size = .*|block_sample_size = 5|" "$config_file"

echo "Обновляем Drosera.toml whitelist"
sed -i "s/^whitelist = .*/whitelist = [\"$pubkey\"]/" drosera.toml
if grep -q "^private_trap" drosera.toml; then
    sed -i 's/^private_trap.*/private_trap = true/' drosera.toml
else
    echo 'private_trap = true' >> drosera.toml
fi

# Автоматически отвечаем "ofc" на интерактивный запрос drosera apply
echo 'ofc' | DROSERA_PRIVATE_KEY="$privkey" /root/.drosera/bin/drosera apply

/root/.drosera/bin/drosera dryrun
echo "Сделали Трапу приватной и привязали к кошельку"
cd ~

/root/.drosera/bin/drosera-operator register --eth-rpc-url "$new_rpc" --eth-private-key "$privkey"

echo "Оператор установлен. Создаем системный сервис"
ip_address=$(hostname -I | awk '{print $1}')

if systemctl list-units --type=service --all | grep -q drosera.service; then
    sudo systemctl stop drosera.service
    sudo systemctl disable drosera.service
    if [ -f /etc/systemd/system/drosera.service ]; then
        sudo rm /etc/systemd/system/drosera.service
    fi
    sudo systemctl daemon-reload
    echo "Существующий drosera.service удален."
fi

sudo tee /etc/systemd/system/drosera.service > /dev/null <<EOF
[Unit]
Description=drosera node service
After=network-online.target

[Service]
User=$USER
Restart=always
RestartSec=15
LimitNOFILE=65535
ExecStart=/root/.drosera/bin/drosera-operator node --db-file-path $HOME/.drosera.db --network-p2p-port 31313 --server-port 31314 \
    --eth-rpc-url $new_rpc \
    --eth-backup-rpc-url https://ethereum-hoodi-rpc.publicnode.com \
    --drosera-address 0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D \
    --eth-private-key $privkey \
    --listen-address 0.0.0.0 \
    --network-external-p2p-address $ip_address \
    --disable-dnr-confirmation true

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable drosera
sudo systemctl start drosera

echo "✅ Установка завершена. Сервис запущен."
echo "📜 Смотреть логи: journalctl -u drosera.service -f"
