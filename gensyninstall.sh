#!/bin/bash

rm -rf rl-swarm && git clone https://github.com/Dikci/rl-swarm && cd rl-swarm
rm -rf /root/rl-swarm/modal-login/app/Page.tsx
wget -O /root/rl-swarm/modal-login/app/Page.tsx https://raw.githubusercontent.com/Dikci/Autorestart/refs/heads/main/Page.tsx
rm -rf hivemind_exp/configs/mac/grpo-qwen-2.5-0.5b-deepseek-r1.yaml
wget -O hivemind_exp/configs/mac/grpo-qwen-2.5-0.5b-deepseek-r1.yaml https://raw.githubusercontent.com/Dikci/Autorestart/refs/heads/main/grpo-qwen-2.5-0.5b-deepseek-r1.yaml
sed -i 's/bf16: true/bf16: false/' hivemind_exp/configs/mac/grpo-qwen-2.5-0.5b-deepseek-r1.yaml
grep -rl "bf16: true" hivemind_exp/configs/gpu/ | xargs sed -i 's/bf16: true/bf16: false/g'
rm -rf run_rl_swarm.sh
wget -O /root/rl-swarm/run_rl_swarm.sh https://raw.githubusercontent.com/Dikci/Autorestart/refs/heads/main/run_rl_swarm.sh && chmod +x run_rl_swarm.sh && ./run_rl_swarm.sh
