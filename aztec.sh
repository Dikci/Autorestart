#!/bin/bash

    echo -e "${GREEN}Установка зависимостей...${NC}"
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt install -y iptables-persistent curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip

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

    sudo iptables -I INPUT -p tcp --dport 40400 -j ACCEPT
    sudo iptables -I INPUT -p udp --dport 40400 -j ACCEPT
    sudo iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
    sudo sh -c "iptables-save > /etc/iptables/rules.v4"

    mkdir -p "$HOME/aztec-sequencer"
    cd "$HOME/aztec-sequencer"

    docker pull aztecprotocol/aztec:latest

    read -p "Вставьте ваш URL RPC Sepolia: " RPC
    read -p "Вставьте ваш URL Beacon Sepolia: " CONSENSUS
    read -p "Вставьте приватный ключ от вашего кошелька (0x…): " PRIVATE_KEY
    read -p "Вставьте адрес вашего кошелька (0x…): " WALLET

    SERVER_IP=$(curl -s https://api.ipify.org)

    cat > .env <<EOF
ETHEREUM_HOSTS=$RPC
L1_CONSENSUS_HOST_URLS=$CONSENSUS
VALIDATOR_PRIVATE_KEY=$PRIVATE_KEY
P2P_IP=$SERVER_IP
WALLET=$WALLET
GOVERNANCE_PROPOSER_PAYLOAD_ADDRESS=0x54F7fe24E349993b363A5Fa1bccdAe2589D5E5Ef
EOF

    mkdir -p "$HOME/aztec-sequencer/data"

    docker run -d \
      --name aztec-sequencer \
      --network host \
      --entrypoint /bin/sh \
      --env-file "$HOME/aztec-sequencer/.env" \
      -e DATA_DIRECTORY=/data \
      -e LOG_LEVEL=debug \
      -v "$HOME/aztec-sequencer/data":/data \
      aztecprotocol/aztec:latest \
      -c 'node --no-warnings /usr/src/yarn-project/aztec/dest/bin/index.js start --network alpha-testnet --node --archiver --sequencer'

    echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
    echo -e "${YELLOW}Команда для проверки логов:${NC}" 
    echo "docker logs --tail 100 -f aztec-sequencer"
    echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
    echo -e "${GREEN}Процесс завершён.${NC}"
    sleep 2
    docker logs --tail 100 -f aztec-sequencer
