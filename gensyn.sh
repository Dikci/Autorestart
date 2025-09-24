#!/bin/bash

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
sed -i '/rm -r \$ROOT_DIR\/modal-login\/temp-data\/\*\.json/d' run_rl_swarm.sh 
chmod +x run_rl_swarm.sh
./run_rl_swarm.sh
