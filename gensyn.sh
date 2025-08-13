#!/bin/bash

cd rl-swarm
git stash push run_rl_swarm.sh
git pull
git stash pop
rm -rf run_rl_swarm.sh
wget https://raw.githubusercontent.com/Dikci/Autorestart/refs/heads/main/run_rl_swarm.sh
chmod +x run_rl_swarm.sh
curl -sSL https://raw.githubusercontent.com/zunxbt/installation/main/node.sh | bash
sudo rm -f /usr/local/bin/yarn
sudo rm -f /usr/bin/yarn
sudo rm -rf ~/.yarn
sudo rm -rf ~/.config/yarn
sudo rm -rf ~/.npm/_npx
sudo npm uninstall -g corepack || true
sudo npm install -g corepack
corepack enable
corepack prepare yarn@4.9.2 --activate
yarn -v
cd modal-login
rm -rf node_modules .yarn yarn.lock
sed -i 's/"viem": *"[^"]*"/"viem": "2.33.3"/' package.json
yarn up viem@2.33.3 -E -i
yarn add @alchemy/aa-core@latest @alchemy/aa-alchemy@latest
yarn install
yarn add eventemitter3 @account-kit/logging ox
yarn add lit-html @wagmi/core @aa-sdk/core
yarn add @tanstack/query-core pino-pretty
yarn add encoding
rm -rf .yarn/cache .yarn/install-state.gz .yarn/virtual yarn.lock
yarn add @account-kit/core@4.53.1
cd ..
python3 -m venv .venv && source .venv/bin/activate
pip install --force-reinstall transformers==4.51.3 trl==0.19.1
pip freeze
export CUDA_VISIBLE_DEVICES="" && ./run_rl_swarm.sh
