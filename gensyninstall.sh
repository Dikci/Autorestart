#!/bin/bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-venv python3-pip curl wget screen git lsof nano unzip iproute2
sudo apt remove -y nodejs npm
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
npm install -g yarn
npm install -g localtunnel
mkdir -p backuppp 
cp /root/rl-swarm/swarm.pem /root/backuppp
rm -rf rl-swarm
npm install -g yarn --force
yarn install
git clone https://github.com/gensyn-ai/rl-swarm
cd rl-swarm
python3 -m venv .venv && source .venv/bin/activate
rm -rf run_rl_swarm.sh
cp /root/backuppp/swarm.pem /root/rl-swarm/swarm.pem
sed -i '$ a PORT=3999' /root/rl-swarm/modal-login/.env
wget https://raw.githubusercontent.com/Dikci/Autorestart/refs/heads/main/run_rl_swarm.sh
sudo ufw allow 3999/tcp
sudo ufw allow 3999
sed -i 's|http://localhost:3000|http://localhost:3999|g' $(grep -rl "http://localhost:3000" ~/rl-swarm)
sed -i '/rm -r \$ROOT_DIR\/modal-login\/temp-data\/\*\.json/d' run_rl_swarm.sh 
chmod +x run_rl_swarm.sh
python3 -m venv .venv && source .venv/bin/activate
./run_rl_swarm.sh
