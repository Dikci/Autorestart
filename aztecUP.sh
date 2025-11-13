#!/bin/bash

sed -i '/^ETHEREUM_HOSTS=/c\ETHEREUM_HOSTS=http://46.38.234.124:8545' ~/aztec-sequencer/.env
sed -i '/^L1_CONSENSUS_HOST_URLS=/c\L1_CONSENSUS_HOST_URLS=http://46.38.234.124:3500' ~/aztec-sequencer/.env

#!/bin/bash
set -eu

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

show_header() {
  clear
  echo -e "${CYAN}==============================================================="
  echo "                     🚀 AZTEC AUTO INSTALL 🚀"
  echo "                  Simplified Auto Installer"
  echo -e "===============================================================${NC}"
}

install_aztec_node() {
  show_header
  echo -e "${CYAN}Starting Full Aztec Node Installation...${NC}"

  sudo sh -c 'echo "• Root Access Enabled ✔"'

  echo -e "${CYAN}Updating system...${NC}"
  sudo apt-get update -y && sudo apt-get upgrade -y

  echo -e "${CYAN}Installing prerequisites...${NC}"
  sudo apt install -y curl iptables build-essential git wget lz4 jq make gcc nano \
    automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev \
    tar clang bsdmainutils ncdu unzip ufw screen gawk netcat-openbsd sysstat ifstat
  echo -e "${GREEN}✅ Prerequisites installed${NC}"

  if ! command -v docker &>/dev/null; then
    echo -e "${CYAN}Docker not found. Installing Docker...${NC}"
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    sudo install -m 0755 -d /etc/apt/keyrings
    . /etc/os-release
    repo_url="https://download.docker.com/linux/$ID"
    curl -fsSL "$repo_url/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] $repo_url $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update -y && sudo apt upgrade -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable docker
    sudo systemctl restart docker
    echo -e "${GREEN}✅ Docker installed successfully${NC}"
  else
    echo -e "${GREEN}✅ Docker already installed: $(docker --version)${NC}"
  fi

  sudo usermod -aG docker $USER

  echo -e "${CYAN}Checking for existing Aztec setup...${NC}"
  AZTEC_CONTAINERS=$(sudo docker ps -aq --filter ancestor=aztecprotocol/aztec 2>/dev/null || true)
  if [ -n "$AZTEC_CONTAINERS" ]; then
    echo -e "${YELLOW}⚠️ Removing old Aztec containers...${NC}"
    echo "$AZTEC_CONTAINERS" | xargs -r sudo docker stop || true
    echo "$AZTEC_CONTAINERS" | xargs -r sudo docker rm || true
  fi

  AZTEC_IMAGES=$(sudo docker images --format "{{.Repository}}:{{.Tag}}" | grep "aztecprotocol/aztec" || true)
  if [ -n "$AZTEC_IMAGES" ]; then
    echo -e "${YELLOW}⚠️ Removing old Aztec images...${NC}"
    echo "$AZTEC_IMAGES" | xargs -r sudo docker rmi -f || true
  fi

  rm -rf ~/aztec ~/.aztec || true
  echo -e "${GREEN}✅ Clean environment ready${NC}"

  echo -e "${CYAN}Configuring firewall...${NC}"
  sudo apt install -y ufw >/dev/null 2>&1
  sudo ufw allow 22 && sudo ufw allow ssh
  sudo ufw allow 40400/tcp && sudo ufw allow 40400/udp && sudo ufw allow 8080
  yes | sudo ufw enable || sudo ufw --force enable
  sudo ufw reload
  echo -e "${GREEN}✅ Firewall configured${NC}"

  mkdir -p ~/aztec && cd ~/aztec

  # ✅ Исправлено — теперь ищет .env в $HOME/aztec-sequencer/.env
  if [ -f "$HOME/aztec-sequencer/.env" ]; then
    cp "$HOME/aztec-sequencer/.env" ~/aztec/.env
    echo -e "${GREEN}✅ .env file copied from $HOME/aztec-sequencer/.env${NC}"
  else
    echo -e "${RED}❌ .env file not found at $HOME/aztec-sequencer/.env${NC}"
    exit 1
  fi

  # Используем latest образ
  cat > docker-compose.yml <<'EOF'
services:
  aztec-node:
    container_name: aztec-sequencer
    image: aztecprotocol/aztec:latest
    restart: unless-stopped
    network_mode: host
    env_file:
      - .env
    environment:
      LOG_LEVEL: info
    entrypoint: >
      sh -c 'node --no-warnings /usr/src/yarn-project/aztec/dest/bin/index.js start --network testnet --node --archiver --sequencer'
    ports:
      - 40400:40400/tcp
      - 40400:40400/udp
      - 8080:8080
    volumes:
      - ${HOME}/.aztec/testnet/data/:/data
EOF

  echo -e "${CYAN}Starting Aztec node (latest)...${NC}"
  sudo docker compose -f ~/aztec/docker-compose.yml up -d

  echo ""
  echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║  ✅ Aztec Node Installed (latest) 🚀  ║${NC}"
  echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${CYAN}Use the following commands to manage your node:${NC}"
  echo "  • docker ps      → Check running container"
  echo "  • docker logs -f aztec-sequencer  → View logs"
  echo ""
}

install_aztec_node
