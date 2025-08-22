#!/bin/bash

# Убить старую tmux-сессию
tmux kill-session -t nexus

# Остановить и удалить старый контейнер, если он есть
docker stop nexus 2>/dev/null || true
docker rm nexus 2>/dev/null || true

# Обновить образ
docker pull nexusxyz/nexus-cli:latest

# Запустить новую tmux-сессию
tmux new-session -d -s nexus bash -c 'bash -c "set -a; . /etc/environment; set +a; docker run -it --init --name nexus nexusxyz/nexus-cli:latest start --node-id \$ID; exec bash"'

# Установить pm2 и запустить gensyn
npm install pm2 -g
pm2 delete gensyn 2>/dev/null || true
pm2 start /root/rl-swarm/run_rl_swarm.sh \
  --name gensyn \
  --interpreter bash \
  --cwd /root/rl-swarm
pm2 save
pm2 logs gensyn
