#!/bin/bash

sudo apt install -y python3 python3-venv python3-pip curl screen git yarn
curl -sSL https://raw.githubusercontent.com/zunxbt/installation/main/node.sh | bash
sudo apt update && sudo apt install -y python3 python3-venv python3-pip curl wget screen git lsof nano unzip iproute2
swapon --show
sudo fallocate -l 16G /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
rm -rf rl-swarm && git clone https://github.com/gensyn-ai/rl-swarm.git && cd rl-swarm
rm -rf /root/rl-swarm/modal-login/app/Page.tsx
wget -O /root/rl-swarm/modal-login/app/Page.tsx https://raw.githubusercontent.com/Dikci/Autorestart/refs/heads/main/Page.tsx
rm -rf hivemind_exp/configs/mac/grpo-qwen-2.5-0.5b-deepseek-r1.yaml
wget -O hivemind_exp/configs/mac/grpo-qwen-2.5-0.5b-deepseek-r1.yaml https://raw.githubusercontent.com/Dikci/Autorestart/refs/heads/main/grpo-qwen-2.5-0.5b-deepseek-r1.yaml
sed -i 's/bf16: true/bf16: false/' hivemind_exp/configs/mac/grpo-qwen-2.5-0.5b-deepseek-r1.yaml
grep -rl "bf16: true" hivemind_exp/configs/gpu/ | xargs sed -i 's/bf16: true/bf16: false/g'
rm -rf run_rl_swarm.sh
wget -O /root/rl-swarm/run_rl_swarm.sh https://raw.githubusercontent.com/Dikci/Autorestart/refs/heads/main/run_rl_swarm.sh && chmod +x run_rl_swarm.sh && ./run_rl_swarm.sh
