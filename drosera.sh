#!/bin/bash

set -a
source /etc/environment
set +a

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "Устанавливаем софт (временной диапазон ожидания ~5-20 min.)"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
sudo apt install iptables jq gcc automake autoconf nvme-cli libgbm1 pkg-config libleveldb-dev tar bsdmainutils libleveldb-dev -y &>/dev/null
echo "Dependencies установлены"

# создаем файл .profile если его нет в системе
[ -f /root/.profile ] || touch /root/.profile

echo "Ставим Drosera CLI"
curl -s -L https://app.drosera.io/install | bash > /dev/null 2>&1
export PATH=$PATH:/root/.drosera/bin

echo "Ставим Foundry CLI"
curl -s -L https://foundry.paradigm.xyz | bash &>/dev/null
export PATH=$PATH:/root/.foundry/bin

curl -fsSL https://bun.sh/install | bash &>/dev/null
echo 'export BUN_INSTALL="$HOME/.bun"' >> /root/.profile
echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> /root/.profile
export PATH=$PATH:$HOME/.bun/bin
export PATH=$PATH:/root/.drosera/bin:/root/.foundry/bin:$HOME/.bun/bin

echo "Создаем и компилируем Trap"
mkdir -p ~/drosera
cd ~/drosera
forge init -t drosera-network/trap-foundry-template &>/dev/null
bun install &>/dev/null
source /root/.bashrc
forge build &>/dev/null

echo "Размещаем Trap"
pubkey=${EVM}
privkey=${PRIVEVM}
existing_trap=""

new_rpc=${HOODI:-"https://ethereum-hoodi-rpc.publicnode.com"}

echo "Используем адрес кошелька: $pubkey"
echo "Используем приватник: [скрыт]"
echo "Адрес существующей Трапы: (создаем новую)"
echo "Используем RPC адрес: $new_rpc"

config_file=~/drosera/drosera.toml

if [ -n "$existing_trap" ]; then
    echo "Вписали $existing_trap в файл drosera.toml"
    echo "address = \"$existing_trap\"" >> "$config_file"
else
    echo "Создаём новую трапу."
fi

if grep -q '^ethereum_rpc =' "$config_file"; then
    sed -i "s|^ethereum_rpc = \".*\"|ethereum_rpc = \"$new_rpc\"|" "$config_file"
else
    echo "ethereum_rpc = \"$new_rpc\"" >> "$config_file"
fi

if grep -q '^block_sample_size =' "$config_file"; then
    sed -i "s|^block_sample_size = .*|block_sample_size = 5|" "$config_file"
fi

echo "Обновляем Drosera.toml whitelist"
if grep -q '^whitelist =' "$config_file"; then
    sed -i "s|^whitelist = .*|whitelist = [\"$pubkey\"]|" "$config_file"
else
    echo "whitelist = [\"$pubkey\"]" >> "$config_file"
fi

if grep -q "^private_trap" "$config_file"; then
    sed -i 's/^private_trap.*/private_trap = true/' "$config_file"
else
    echo 'private_trap = true' >> "$config_file"
fi

export PATH=$PATH:/root/.drosera/bin:/root/.foundry/bin:$HOME/.bun/bin

printf "ofc\n" | DROSERA_PRIVATE_KEY="$privkey" drosera apply
drosera dryrun
echo "Сделали Трапу приватной и привязали к кошельку"

cd ~

drosera-operator register --eth-rpc-url "$new_rpc" --eth-private-key "$privkey"

echo "Оператор установлен. Создаем системный сервис"
ip_address=$(hostname -I | awk '{print $1}')

if systemctl list-units --type=service --all | grep -q drosera.service; then
    sudo systemctl stop drosera.service
    sudo systemctl disable drosera.service
    sudo rm -f /etc/systemd/system/drosera.service
    sudo systemctl daemon-reload
    echo "Существующий drosera.service удален."
fi

sudo tee /etc/systemd/system/drosera.service > /dev/null <<EOF
[Unit]
Description=drosera node service
After=network-online.target

[Service]
User=root
Restart=always
RestartSec=15
LimitNOFILE=65535
ExecStart=$(which drosera-operator) node --db-file-path /root/.drosera.db --network-p2p-port 31313 --server-port 31314 \\
    --eth-rpc-url https://rpc.hoodi.ethpandaops.io \\
    --eth-backup-rpc-url https://ethereum-hoodi-rpc.publicnode.com \\
    --drosera-address 0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D \\
    --eth-private-key $privkey \\
    --listen-address 0.0.0.0 \\
    --network-external-p2p-address $ip_address \\
    --disable-dnr-confirmation true

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable drosera
sudo systemctl start drosera

echo "Установка завершена. Сервис запущен. Смотреть логи можно через journalctl -u drosera.service -f"
