#!/bin/bash
# убираем set -e чтобы сервер не крашился

# Загружаем переменные окружения
set -a
source /etc/environment
set +a

trap_dir="/root/drosera/src"
toml_file="/root/drosera/drosera.toml"
discord_nick="${DISCORD}"
evm_addr="${EVM}"
priv_key="${PRIVEVM}"
rpc_url="https://ethereum-hoodi-rpc.publicnode.com"

echo "[*] Создаем файл Trap.sol с Discord ником: $discord_nick"

mkdir -p "$trap_dir"

cat > "$trap_dir/Trap.sol" <<EOF
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface IMockResponse {
    function isActive() external view returns (bool);
}

contract Trap is ITrap {
    address public constant RESPONSE_CONTRACT = 0x25E2CeF36020A736CF8a4D2cAdD2EBE3940F4608;
    string constant discordName = "$discord_nick";

    function collect() external view returns (bytes memory) {
        bool active = IMockResponse(RESPONSE_CONTRACT).isActive();
        return abi.encode(active, discordName);
    }

    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        (bool active, string memory name) = abi.decode(data[0], (bool, string));
        if (!active || bytes(name).length == 0) {
            return (false, bytes(""));
        }
        return (true, abi.encode(name));
    }
}
EOF

echo "[*] Правим drosera.toml"
sed -i 's|^path = .*|path = "out/Trap.sol/Trap.json"|' "$toml_file"
sed -i 's|^response_contract = .*|response_contract = "0x25E2CeF36020A736CF8a4D2cAdD2EBE3940F4608"|' "$toml_file"
sed -i 's|^response_function = .*|response_function = "respondWithDiscordName(string)"|' "$toml_file"
sed -i 's|^block_sample_size = .*|block_sample_size = 10|' "$toml_file"

echo "[*] Обновляем PATH"
export PATH=$PATH:/root/.drosera/bin:/root/.foundry/bin:$HOME/.bun/bin

cd /root/drosera || { echo "[!] Нет директории /root/drosera"; exit 1; }

echo "[*] Сборка проекта forge build"
forge build || echo "[!] Ошибка компиляции Trap.sol — проверь код!"

echo "[*] Запускаем drosera dryrun"
drosera dryrun || echo "[!] Ошибка при dryrun"

echo "[*] Применяем изменения drosera apply с авто-ответом 'ofc'"
printf "ofc\n" | DROSERA_PRIVATE_KEY="$priv_key" drosera apply || echo "[!] Ошибка при drosera apply"

echo "[*] Проверяем роль с помощью cast call"
source /root/.bashrc
responder_check=$(cast call 0x25E2CeF36020A736CF8a4D2cAdD2EBE3940F4608 "isResponder(address)(bool)" "$evm_addr" --rpc-url "$rpc_url" || echo "false")

if [[ "$responder_check" == "true" ]]; then
    echo "[+] Роль drosera успешно получена (isResponder == true)"
else
    echo "[-] Роль drosera НЕ получена (isResponder == false)"
fi

# === ВАЖНО: сначала перезапуск, потом сон, потом проверка по дискорду ===
echo "[*] Перезапускаем drosera сервис"
sudo systemctl restart drosera || echo "[!] Не удалось перезапустить сервис drosera"

echo "[*] Ждём 60 секунд, чтобы сервис успел подняться..."
sleep 60

echo "[*] Проверяем наличие ника $discord_nick в getDiscordNamesBatch"
names_list=$(cast call 0x25E2CeF36020A736CF8a4D2cAdD2EBE3940F4608 "getDiscordNamesBatch(uint256,uint256)(string[])" 0 2000 --rpc-url "$rpc_url" || echo "")

if echo "$names_list" | grep -q "$discord_nick"; then
    echo "[+] Ник $discord_nick найден в списке"
else
    echo "[-] Ник $discord_nick НЕ найден в списке"
fi

echo "[*] Скрипт завершен."
