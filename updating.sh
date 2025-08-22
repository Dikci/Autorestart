#!/bin/bash

# Убиваем старую tmux‑сессию (если есть)
tmux kill-session -t nexus 2>/dev/null

# Перезапускаем контейнер
docker stop nexus && docker rm nexus && docker pull nexusxyz/nexus-cli:latest

# Запускаем новую tmux‑сессию и внутри неё стартуем контейнер.
# Обратите внимание: одинарная кавычка закрывается после exec bash
tmux new-session -d -s nexus bash -c '
    bash -c "
        set -a
        . /etc/environment
        set +a
        docker stop nexus
        docker rm nexus
        docker run -it --init --name nexus nexusxyz/nexus-cli:latest \
            start --node-id $ID
        exec bash
    "
'

# Устанавливаем pm2 глобально
npm install pm2 -g

# Перезапускаем процесс gensyn через pm2
pm2 delete gensyn 2>/dev/null
pm2 start /root/rl-swarm/run_rl_swarm.sh \
    --name gensynes \
    --interpreter bash \
    --cwd /root/rl-swarm

pm2 save
pm2 logs gensyn
